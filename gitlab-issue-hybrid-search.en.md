# [Feature] Hybrid retrieval (FTS5 + Vector) for PKM search and agent semantic discovery

[中文](gitlab-issue-hybrid-search.md) | English

## 1. Background and problem

Memex's current knowledge-base search uses simple file traversal plus string matching (`toLowerCase().contains()`), which has the following problems:

1. **No semantic understanding**: searching "database optimization" does not find "MySQL performance tuning"
2. **No index**: after the number of files grows, I/O cost grows linearly with file count
3. **Agent search is one-dimensional**: only `Grep` (keyword matching) is available; semantic associations cannot be discovered

## 2. Goals

1. Replace the existing string-matching search with **local hybrid retrieval** (FTS5 + Vector), covering PKM files
2. **Zero change for upper-layer callers** — `FileSystemService.searchPkmFiles()` keeps its existing signature
3. Provide the Agent with a new **semantic search tool**, complementary to the existing `Grep`
4. Support **multiple Embedding Providers** (OpenAI, Zhipu, Ollama)
5. Expose **index management** (rebuild / clear) in Settings

## 3. Non-goals

- Timeline Card content search (out of scope for this issue)
- Cross-device index sync
- Image/audio semantic search
- Local ONNX offline Embedding (as Phase 2)

## 4. Functional changes

### 4.1 Search experience upgrades

| Scenario | Current behavior | New behavior |
|------|----------|--------|
| User searches "database optimization" | Only matches file names/content containing that string | Also returns semantically related files such as "MySQL performance tuning" |
| 1000+ PKM files | Every search traverses all files | Millisecond-level index queries |
| Agent organizing new input | Uses Grep to find keyword associations | Can use SemanticSearch to discover semantically related historical records |

### 4.2 Automatic index maintenance

| Trigger | Behavior | User-visible effect |
|----------|------|----------|
| First launch with existing PKM data | Full build in the background | First search shows "Preparing search..." |
| PKM file create/update/delete | Incremental index update | Not noticeable |
| Switch Embedding Provider | Automatic rebuild (dimension change) | "Rebuilding index for the new model..." |
| App resume (interval >N hours) | Incremental sync check | Not noticeable |

### 4.3 Settings page additions

- **Embedding model configuration**: add/edit/delete Providers; set default; test connection; show dimensions
- **Search index management**: show index stats (file count, vector count, size, last updated); rebuild button; clear button (requires confirmation)

### 4.4 Agent capability enhancements

Add a `SemanticSearch` tool:

```
Name: SemanticSearch
Description: Search the PKM knowledge base using natural-language semantics.
  Use this when you need to discover conceptually related content, not just exact keyword matches.
Parameters:
  - query: string (natural-language description)
  - scope: "pkm" | "all" (default: "pkm")
  - limit: int (default: 10, max: 50)
Returns:
  List of {source, snippet, similarity_score, fact_ids}
```

PKM Agent Prompt update: add a SemanticSearch usage suggestion in the "Categorize" step:

```
2. Categorize: Determine the storage location based on LS results.
   If information is insufficient, use Grep and Read to gather context.
   [NEW] Use SemanticSearch to discover semantically related historical records whose keywords are not obvious.
```

## 5. Interface and module changes

### 5.1 New modules

| Module | File path | Responsibility |
|------|----------|------|
| `SearchCore` | `lib/search/search_core.dart` | Unified retrieval entry point; hybrid scoring (vectorWeight=0.7, textWeight=0.3) |
| `IndexManager` | `lib/search/index_manager.dart` | Index lifecycle: build, incremental update, delete, rebuild |
| `EmbeddingProvider` (abstract) | `lib/search/embedding_provider.dart` | Interface: `embed(String) → List<double>` |
| `OpenAIEmbeddingProvider` | `lib/search/providers/openai_provider.dart` | OpenAI `text-embedding-3-small` / `text-embedding-3-large` |
| `ZhipuEmbeddingProvider` | `lib/search/providers/zhipu_provider.dart` | Zhipu `embedding-3` |
| `OllamaEmbeddingProvider` | `lib/search/providers/ollama_provider.dart` | Local Ollama API |
| `EmbeddingConfig` | `lib/domain/models/embedding_config.dart` | Config model: provider, model, apiKey, baseUrl, dimensions |

### 5.2 Modified modules

| Module | Change |
|------|----------|
| `FileSystemService.searchPkmFiles()` | Replace the internal implementation with a call to `SearchCore`; keep the existing signature and return format `{name, path, snippet, name_match}` |
| `FileSystemService` (write operations) | Notify `IndexManager` for incremental updates on file create/modify/delete |
| `AppDatabase` (Drift) | Schema upgrade to v9: add `fts_index` FTS5 virtual table, `vector_index` vector table, `index_meta` metadata table |
| `SettingsPage` | Add two entry points: "Embedding model configuration" → `EmbeddingConfigPage`; "Search index management" → `IndexManagementPage` |
| `agent/built_in_tools/file_tools.dart` | Add `SemanticSearchTool` |
| `agent/prompts.dart` | Update `pkmSkillSystemPrompt`; add a SemanticSearch usage suggestion in the Discover step |

### 5.3 New UI pages

| Page | Path | Function |
|------|------|------|
| `EmbeddingConfigPage` | `lib/ui/settings/widgets/embedding_config_page.dart` | Add/edit/delete Providers; set default; test connection; show dimensions |
| `IndexManagementPage` | `lib/ui/settings/widgets/index_management_page.dart` | Index stats; rebuild button; clear button (requires confirmation) |

### 5.4 Architecture diagram

```
KnowledgeSearchDelegate ──► MemexRouter.searchPkmFiles(q)
                                    │
                                    ▼
                         FileSystemService.searchPkmFiles()
                                    │
                                    ▼
                              ┌───────────┐
                              │ SearchCore│  (NEW)
                              │  (Dart)   │
                              └─────┬─────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              ▼                     ▼                     ▼
        ┌──────────┐        ┌──────────┐          ┌──────────┐
        │ FTS5     │        │ Vector   │          │ Metadata │
        │ Virtual  │        │ Table    │          │ (Drift)  │
        │ Table    │        │          │          │          │
        └──────────┘        └──────────┘          └──────────┘
                                    │
                                    ▼
                         ┌─────────────────┐
                         │ EmbeddingProvider│  (NEW, pluggable)
                         │  - OpenAI        │
                         │  - Zhipu/GLM     │
                         │  - Ollama        │
                         └─────────────────┘
```

## 6. Embedding Provider presets

| Provider | Default model | Dimensions | Type |
|----------|----------|------|------|
| OpenAI | `text-embedding-3-small` | 1536 | Remote |
| Zhipu | `embedding-3` | 2048 | Remote |
| Ollama | `nomic-embed-text` | 768 | Local (requires Ollama service) |

> ONNX local offline Embedding (`bge-small-zh-v1.5`, etc.) will be implemented as Phase 2.

## 7. API compatibility

**Zero breaking change** for existing callers:

```dart
// API is identical before and after the change
Future<List<Map<String, dynamic>>> searchPkmFiles(
  String userId,
  String query, {
  int limit = 50,
});
```

Return format remains `{name, path, snippet, name_match}`.

## 8. Test checklist

- [ ] FTS5 index correctly builds PKM Markdown files
- [ ] Vector index builds correctly under each Provider
- [ ] Hybrid scoring produces reasonable ranking results
- [ ] Incremental updates reflect file changes in real time
- [ ] Switching Provider automatically triggers a rebuild
- [ ] Agent `SemanticSearch` tool returns valid results
- [ ] Settings pages work correctly on iOS and Android
- [ ] Full clear-index + rebuild flow works correctly
- [ ] Graceful degradation when a Provider is unavailable (fall back to basic matching)

## 9. Technical evaluation

### 9.1 Evaluation scope

This evaluation covers all viable local vector-search options in the Flutter/Dart ecosystem, grouped into three categories by implementation approach:

| Category | Representative option | Core characteristics |
|------|----------|------|
| **SQLite extension** | sqlite-vec | Built-in vector virtual table inside SQLite; requires FFI loading |
| **Native database (with HNSW)** | ObjectBox | Standalone NoSQL database with a native C++ HNSW implementation |
| **Pure Dart implementation** | Pure Dart linear scan, local_hnsw | Zero native dependencies; fully controllable code |

### 9.2 sqlite-vec evaluation

| Dimension | Assessment |
|------|----------|
| Official Dart/Flutter bindings | ❌ **Do not exist**. asg017 does not officially provide Dart bindings (supported languages: Python/Node.js/Ruby/Go/Rust/C/C++/WASM) |
| Community PR | ⚠️ [PR #119](https://github.com/asg017/sqlite-vec/pull/119) (rodydavis, 2024-10) is stalled; the author explicitly stated it will be replaced by Flutter/Dart Native Assets and will not be merged |
| pub.dev third-party package | ⚠️ [`sqlite_vec`](https://pub.dev/packages/sqlite_vec) `0.1.7-alpha.3` (ningpengtao-coder fork), pre-release status, very little documentation, no Drift integration examples |
| Mobile loading | Must manually package precompiled `.so`/`.dylib` into the iOS/Android project and load via `dart:ffi` |
| Drift compatibility | ❌ No native support. Requires a custom `NativeDatabase` opener that loads the extension via `sqlite3` FFI before Drift opens the database; connection lifecycle management is complex |

**Conclusion**: sqlite-vec is **not yet mature** in the Flutter/Drift ecosystem; integration cost is high and maintenance risk is large.

### 9.3 ObjectBox evaluation

ObjectBox is the **only mature option with HNSW vector index support** in the Flutter/Dart ecosystem.

#### 9.3.1 Vector search capabilities (v4.0.0+, current latest v5.3.1)

| Feature | Details |
|------|------|
| Index algorithm | HNSW (Hierarchical Navigable Small World), ANN approximate nearest neighbor |
| Annotation | `@HnswIndex(dimensions: N)`, supports `neighborsPerNode` (M, default 30), `indexingSearchCount` (efConstruction, default 100) |
| Distance metrics | Euclidean (default), Cosine, DotProduct, DotProductNonNormalized, Geo |
| Query API | `nearestNeighborsF32(queryVector, maxResultCount)` + `findWithScores()` returns distance scores |
| Incremental updates | ✅ Supported. Only the delta is persisted on data changes |
| Dimension limit | Not explicitly limited; docs describe it as "typically hundreds or thousands" |

#### 9.3.2 Advantages

- **HNSW index**: O(log n) search complexity; sub-millisecond latency at tens of thousands to hundreds of thousands of vectors
- **Mature and stable**: vector search shipped in v4.0.0 (2024-05); v5.3.1 continues to iterate
- **ACID persistence**: vector data and business data stored together; automatic schema migration
- **Hybrid queries**: vector conditions can be combined with ordinary conditions (`and()`/`or()`)

#### 9.3.3 Disadvantages and risks

| Disadvantage | Details |
|------|------|
| **Introduces a second database** | Memex currently uses Drift/SQLite; introducing ObjectBox means maintaining two database connections, two schemas, and two migration paths |
| **APK size increase** | Native library about +2 MB (AAB distribution), but a universal APK may inflate by 25+ MB (need split-per-abi or AAB to avoid this) |
| **Incompatible with Drift** | ObjectBox and Drift are independent ORMs; they cannot share transactions or a connection pool |
| **Architectural complexity** | FTS5 remains in SQLite/Drift while the vector index lives in ObjectBox; hybrid queries require cross-database coordination |
| **Learning cost** | The team must learn ObjectBox's Entity/Box/Query model |

### 9.4 local_hnsw evaluation

[`local_hnsw`](https://pub.dev/packages/local_hnsw) is a pure Dart HNSW implementation (v1.0.0).

| Dimension | Assessment |
|------|----------|
| Algorithm | HNSW, supports Cosine / Euclidean |
| Persistence | `save()`/`load()` export as `Map<String, dynamic>`; serialization must be managed by the caller |
| Memory model | **Pure in-memory**; no disk page cache; at large scale, memory usage = vector data + index structure |
| Version activity | v1.0.0, released 12 months ago; low update frequency |
| Performance data | No public benchmark |

**Conclusion**: although it has an HNSW algorithm, it is in-memory only, has no native persistence, and has low maintenance activity — not suitable for production.

### 9.5 Pure Dart linear scan approach

#### 9.5.1 Performance estimates

Based on Memex's actual data scale (file-level vectors):

| Metric | Value |
|------|------|
| Single vector comparison | O(n × d), n=10,000, d=1536 ≈ 15 million floating-point operations |
| Dart execution time (modern mobile devices) | ~10~40ms |
| Memory usage | 10,000 × 1536 × 4B ≈ 60MB (raw vectors) |

> Note: if chunk-level vectors are adopted later (2~5 chunks per file), 10,000 files → 20,000~50,000 vectors, scan time about 50~200ms, still within an acceptable range.

#### 9.5.2 Advantages

- Zero extra native dependencies; no APK/IPA size increase
- Seamless integration with Drift; single database, single transaction
- Fully controllable code; no risk of an external project stalling
- Simple to implement (cosine similarity in about 10 lines of code + min-heap Top-K)

#### 9.5.3 Disadvantages

- No ANN index; every search computes over the full set
- Latency may exceed 100ms when vector count >50,000

### 9.6 Comparative summary

| Dimension | sqlite-vec | ObjectBox | local_hnsw | Pure Dart linear scan |
|------|:----------:|:---------:|:----------:|:----------------:|
| ANN index (HNSW) | ✅ | ✅ | ✅ | ❌ |
| Search complexity | O(log n) | O(log n) | O(log n) | O(n) |
| Latency at 10k vectors | <1ms | <1ms | Unknown | ~20ms |
| Latency at 100k vectors | <1ms | <1ms | Unknown | ~200ms |
| Drift/SQLite compatibility | ❌ Requires FFI hack | ❌ Independent database | N/A | ✅ Seamless |
| Single-database architecture | ✅ | ❌ | ✅ (in-memory) | ✅ |
| Zero extra dependencies | ❌ | ❌ | ✅ | ✅ |
| APK size increase | ~1MB | ~2MB | 0 | 0 |
| Production maturity | ❌ Immature | ✅ Mature | ⚠️ Low | ✅ Fully controllable |
| Maintenance risk | High | Medium | High | Extremely low |

### 9.7 Final recommendation

**Adopt the "FTS5 + pure Dart vector retrieval" approach**, for the following reasons:

1. **Architectural simplicity**: FTS5 (Drift/SQLite) + vector table (Drift/SQLite) = **single-database architecture**. Introducing ObjectBox would become a dual-database architecture; hybrid queries would require cross-database coordination, with complexity far exceeding the benefit.

2. **Current scale is fully sufficient**: for Memex PKM file-level vectors, even if growth reaches 10,000+ files per year, pure Dart linear-scan latency remains 20~40ms, unnoticeable to users.

3. **Zero dependencies, zero size increase**: no new native libraries; APK/IPA size unchanged.

4. **Fully controllable code**: cosine similarity + min-heap implementation is under 50 lines of Dart, with no external-dependency risk.

5. **Upgrade path reserved**:
   - When vector count exceeds 50,000 and latency becomes unacceptable, we can migrate smoothly to ObjectBox (HNSW index)
   - When official sqlite-vec Dart bindings mature, we can migrate to sqlite-vec (return to a single-database architecture)

### 9.8 Vector storage schema design

```dart
// Drift Table (ordinary table, not a virtual table)
class VectorIndex extends Table {
  TextColumn get filePath => text()();      // PKM file relative path (PK)
  TextColumn get fileHash => text()();      // Content hash, used to decide incremental updates
  BlobColumn get embedding => blob()();     // Serialized Float32List
  IntColumn get dimension => integer()();   // Dimensions (1536/2048/768, etc.)
  IntColumn get updatedAt => integer()();   // Last-updated timestamp

  @override
  Set<Column> get primaryKey => {filePath};
}
```

### 9.9 Hybrid scoring algorithm

```dart
// Pseudocode
Future<List<SearchResult>> hybridSearch(String query, {int limit = 50}) async {
  // 1. FTS5 keyword search
  final ftsResults = await ftsSearch(query, limit: limit * 2);

  // 2. Vector semantic search (only when query length > 2, to avoid wasting Embedding API calls on short terms)
  List<VectorResult> vectorResults = [];
  if (query.trim().length > 2) {
    final queryEmbedding = await embeddingProvider.embed(query);
    vectorResults = await vectorSearch(queryEmbedding, limit: limit * 2);
  }

  // 3. Weighted fusion (RRF or linear weighting)
  return mergeResults(
    ftsResults, weight: 0.3,
    vectorResults, weight: 0.7,
    limit: limit,
  );
}
```

## 10. Chunking strategy

| Approach | Description | Choice |
|------|------|------|
| File-level vectors | Generate one vector per Markdown file | ✅ **Recommended** (PKM files are usually topic-focused; granularity is appropriate) |
| Chunk-level vectors | Split files into 400 tokens/80 overlap chunks, one vector per chunk | Future extension; file-level is sufficient for now |

> Advantages of file-level vectors: same document granularity as FTS5, simple hybrid scoring logic; fewer Embedding API calls and less storage.

---

**Labels**: `enhancement`, `search`, `performance`, `agent`
