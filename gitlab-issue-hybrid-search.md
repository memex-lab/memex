# [Feature] 引入混合检索（FTS5 + Vector）提升 PKM 搜索与 Agent 语义发现能力

## 一、背景与问题

Memex 当前的知识库搜索使用简单的文件遍历 + 字串匹配（`toLowerCase().contains()`），存在以下问题：

1. **无语义理解**："数据库优化"搜不到"MySQL 性能调优"
2. **无索引**：文件多了之后 IO 开销随文件数量线性增长
3. **Agent 搜索能力单一**：只有 `Grep`（关键词匹配），无法发现语义关联

## 二、目标

1. 将现有字串匹配搜索替换为**本地混合检索**（FTS5 + Vector），覆盖 PKM 文件
2. **上层调用方零改动** — `FileSystemService.searchPkmFiles()` 保持原有签名
3. 为 Agent 提供新的**语义搜索工具**，与现有 `Grep` 互补
4. 支持**多 Embedding Provider**（OpenAI、智谱、Ollama）
5. 在设置中暴露**索引管理**（重建 / 清空）入口

## 三、非目标

- Timeline Card 内容搜索（超出本 issue 范围）
- 跨设备索引同步
- 图片/音频语义搜索
- 本地 ONNX 离线 Embedding（作为 Phase 2）

## 四、功能上的修改

### 4.1 搜索体验升级

| 场景 | 当前行为 | 新行为 |
|------|----------|--------|
| 用户搜索"数据库优化" | 仅匹配含该字串的文件名/内容 | 同时返回"MySQL 性能调优"等语义相关文件 |
| PKM 文件 1000+ | 每次搜索遍历所有文件 | 毫秒级索引查询 |
| Agent 整理新输入 | 用 Grep 找关键词关联 | 可用 SemanticSearch 发现语义关联的历史记录 |

### 4.2 索引自动维护

| 触发条件 | 行为 | 用户感知 |
|----------|------|----------|
| 首次启动且已有 PKM 数据 | 后台全量构建 | 首次搜索时显示"正在准备搜索..." |
| PKM 文件增删改 | 增量更新索引 | 无感知 |
| 切换 Embedding Provider | 自动重建（维度变化） | "正在为新模型重建索引..." |
| 应用恢复（间隔 >N 小时） | 增量同步检查 | 无感知 |

### 4.3 设置页面新增

- **Embedding 模型配置**：添加/编辑/删除 Provider；设置默认；测试连接；显示维度
- **搜索索引管理**：显示索引统计（文件数、向量数、大小、最后更新）；重建按钮；清空按钮（需确认）

### 4.4 Agent 能力增强

新增 `SemanticSearch` 工具：

```
Name: SemanticSearch
Description: 使用自然语言语义搜索 PKM 知识库。
  当你需要发现概念上相关的内容，而不仅仅是精确关键词匹配时使用。
Parameters:
  - query: string（自然语言描述）
  - scope: "pkm" | "all"（默认: "pkm"）
  - limit: int（默认: 10, 最大: 50）
Returns:
  List of {source, snippet, similarity_score, fact_ids}
```

PKM Agent Prompt 更新：在"Categorize"步骤中增加 SemanticSearch 调用建议：

```
2. Categorize: 根据 LS 结果确定存储位置。
   如果信息不足，使用 Grep、Read 收集上下文。
   【新增】使用 SemanticSearch 发现语义相关但关键词不明显的历史记录。
```

## 五、接口和模块上的修改

### 5.1 新建模块

| 模块 | 文件路径 | 职责 |
|------|----------|------|
| `SearchCore` | `lib/search/search_core.dart` | 统一检索入口；混合打分（vectorWeight=0.7, textWeight=0.3） |
| `IndexManager` | `lib/search/index_manager.dart` | 索引生命周期：构建、增量更新、删除、重建 |
| `EmbeddingProvider`（抽象） | `lib/search/embedding_provider.dart` | 接口：`embed(String) → List<double>` |
| `OpenAIEmbeddingProvider` | `lib/search/providers/openai_provider.dart` | OpenAI `text-embedding-3-small` / `text-embedding-3-large` |
| `ZhipuEmbeddingProvider` | `lib/search/providers/zhipu_provider.dart` | 智谱 `embedding-3` |
| `OllamaEmbeddingProvider` | `lib/search/providers/ollama_provider.dart` | 本地 Ollama API |
| `EmbeddingConfig` | `lib/domain/models/embedding_config.dart` | 配置模型：provider, model, apiKey, baseUrl, dimensions |

### 5.2 修改模块

| 模块 | 改动内容 |
|------|----------|
| `FileSystemService.searchPkmFiles()` | 内部实现替换为调用 `SearchCore`，保留原有签名和返回值格式 `{name, path, snippet, name_match}` |
| `FileSystemService`（写操作） | 在文件创建/修改/删除时通知 `IndexManager` 进行增量更新 |
| `AppDatabase` (Drift) | Schema 升级至 v9：新增 `fts_index` FTS5 虚拟表、`vector_index` 向量表、`index_meta` 元数据表 |
| `SettingsPage` | 新增两个入口："Embedding 模型配置" → `EmbeddingConfigPage`；"搜索索引管理" → `IndexManagementPage` |
| `agent/built_in_tools/file_tools.dart` | 新增 `SemanticSearchTool` |
| `agent/prompts.dart` | 更新 `pkmSkillSystemPrompt`，在 Discover 步骤增加 SemanticSearch 调用建议 |

### 5.3 新建 UI 页面

| 页面 | 路径 | 功能 |
|------|------|------|
| `EmbeddingConfigPage` | `lib/ui/settings/widgets/embedding_config_page.dart` | 添加/编辑/删除 Provider；设置默认；测试连接；显示维度 |
| `IndexManagementPage` | `lib/ui/settings/widgets/index_management_page.dart` | 索引统计；重建按钮；清空按钮（需确认） |

### 5.4 架构图

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

## 六、Embedding Provider 预设

| Provider | 默认模型 | 维度 | 类型 |
|----------|----------|------|------|
| OpenAI | `text-embedding-3-small` | 1536 | 远程 |
| 智谱 (Zhipu) | `embedding-3` | 2048 | 远程 |
| Ollama | `nomic-embed-text` | 768 | 本地（需 Ollama 服务） |

> ONNX 本地离线 Embedding（`bge-small-zh-v1.5` 等）作为 Phase 2 实现。

## 七、API 兼容性

对现有调用方**零破坏**：

```dart
// 改动前后 API 完全一致
Future<List<Map<String, dynamic>>> searchPkmFiles(
  String userId,
  String query, {
  int limit = 50,
});
```

返回值格式保持 `{name, path, snippet, name_match}`。

## 八、测试清单

- [ ] FTS5 索引正确构建 PKM Markdown 文件
- [ ] Vector 索引在各 Provider 下正确构建
- [ ] 混合打分产生合理的排序��果
- [ ] 增量更新实时反映文件变更
- [ ] 切换 Provider 自动触发重建
- [ ] Agent `SemanticSearch` 工具返回有效结果
- [ ] 设置页面在 iOS 和 Android 正常工作
- [ ] 索引清空 + 重建全流程正常
- [ ] Provider 不可用时优雅降级（回退基础匹配）

## 九、技术选型评估

### 9.1 评估范围

本次评估覆盖 Flutter/Dart 生态中所有可行的本地向量搜索方案，按实现方式分为三类：

| 类别 | 代表方案 | 核心特点 |
|------|----------|----------|
| **SQLite 扩展** | sqlite-vec | 在 SQLite 内建向量虚拟表，需 FFI 加载 |
| **原生数据库（含 HNSW）** | ObjectBox | 独立 NoSQL 数据库，原生 C++ HNSW 实现 |
| **纯 Dart 实现** | 纯 Dart 线性扫描、local_hnsw | 零原生依赖，代码完全可控 |

### 9.2 sqlite-vec 评估

| 维度 | 评估结果 |
|------|----------|
| 官方 Dart/Flutter 绑定 | ❌ **不存在**。asg017 官方未提供 Dart 绑定（支持语言：Python/Node.js/Ruby/Go/Rust/C/C++/WASM） |
| 社区 PR | ⚠️ [PR #119](https://github.com/asg017/sqlite-vec/pull/119)（rodydavis，2024-10）已停滞，作者明确表示将被 Flutter/Dart Native Assets 取代，不会合并 |
| pub.dev 第三方包 | ⚠️ [`sqlite_vec`](https://pub.dev/packages/sqlite_vec) `0.1.7-alpha.3`（ningpengtao-coder fork），pre-release 状态，文档极少，无 Drift 集成示例 |
| 移动端加载方式 | 需手动将预编译的 `.so`/`.dylib` 打包进 iOS/Android 工程，通过 `dart:ffi` 加载 |
| Drift 兼容性 | ❌ 无原生支持。需自定义 `NativeDatabase` opener，在 Drift 打开数据库前通过 `sqlite3` FFI 加载扩展，存在连接生命周期管理复杂度 |

**结论**：sqlite-vec 在 Flutter/Drift 生态中**尚未成熟**，集成成本高、维护风险大。

### 9.3 ObjectBox 评估

ObjectBox 是 Flutter/Dart 生态中**唯一成熟支持 HNSW 向量索引**的原生数据库方案。

#### 9.3.1 向量搜索能力（v4.0.0+，当前最新 v5.3.1）

| 特性 | 详情 |
|------|------|
| 索引算法 | HNSW（Hierarchical Navigable Small World），ANN 近似最近邻 |
| 注解 | `@HnswIndex(dimensions: N)`，支持 `neighborsPerNode`（M，默认 30）、`indexingSearchCount`（efConstruction，默认 100） |
| 距离度量 | Euclidean（默认）、Cosine、DotProduct、DotProductNonNormalized、Geo |
| 查询 API | `nearestNeighborsF32(queryVector, maxResultCount)` + `findWithScores()` 返回距离分数 |
| 增量更新 | ✅ 支持。数据变更时仅持久化 delta |
| 维度上限 | 未明确限制，文档描述为 "typically hundreds or thousands" |

#### 9.3.2 优势

- **HNSW 索引**：O(log n) 搜索复杂度，万级~十万级向量下亚毫秒级延迟
- **成熟稳定**：v4.0.0（2024-05）已发布向量搜索，v5.3.1 持续迭代
- **ACID 持久化**：向量数据与业务数据统一存储，自动 schema 迁移
- **混合查询**：向量条件可与普通条件（`and()`/`or()`）组合

#### 9.3.3 劣势与风险

| 劣势 | 详情 |
|------|------|
| **引入第二数据库** | Memex 当前使用 Drift/SQLite，引入 ObjectBox 意味着维护两套数据库连接、两套 schema、两套迁移逻辑 |
| **APK 体积增加** | 原生库约 +2 MB（AAB 分发），但 universal APK 可能膨胀 25+ MB（需 split-per-abi 或 AAB 规避） |
| **与 Drift 不兼容** | ObjectBox 和 Drift 是两套独立 ORM，无法共享事务、连接池 |
| **架构复杂度** | FTS5 仍在 SQLite/Drift 中，向量索引在 ObjectBox 中，混合查询需跨库协调 |
| **学习成本** | 团队需掌握 ObjectBox 的 Entity/Box/Query 模型 |

### 9.4 local_hnsw 评估

[`local_hnsw`](https://pub.dev/packages/local_hnsw) 是一个纯 Dart 的 HNSW 实现（v1.0.0）。

| 维度 | 评估结果 |
|------|----------|
| 算法 | HNSW，支持 Cosine / Euclidean |
| 持久化 | `save()`/`load()` 导出为 `Map<String, dynamic>`，需自行管理序列化 |
| 内存模型 | **纯内存**，无磁盘页缓存；大数据量时内存占用 = 向量数据 + 索引结构 |
| 版本活跃��� | v1.0.0，发布于 12 个月前，更新频率低 |
| 性能数据 | 无公开 benchmark |

**结论**：虽有 HNSW 算法，但纯内存、无原生持久化、维护活跃度低，不适合生产环境。

### 9.5 纯 Dart 线性扫描方案

#### 9.5.1 性能估算

基于 Memex 实际数据量级（文件级向量）：

| 指标 | 数值 |
|------|------|
| 单次向量比对 | O(n × d)，n=10,000, d=1536 ≈ 1,500 万次浮点运算 |
| Dart 执行时间（现代移动设备） | ~10~40ms |
| 内存占用 | 10,000 × 1536 × 4B ≈ 60MB（原始向量） |

> 注：若未来采用 chunk 级向量（每文件 2~5 个 chunk），10,000 文件 → 20,000~50,000 个向量，扫描时间约 50~200ms，仍属可接受范围。

#### 9.5.2 优势

- 零额外原生依赖，不增加 APK/IPA 体积
- 与 Drift 无缝集成，单库单事务
- 代码完全可控，无外部项目停滞风险
- 实现简单（余弦相似度约 10 行代码 + 最小堆 Top-K）

#### 9.5.3 劣势

- 无 ANN 索引，每次搜索全量计算
- 向量数 >50,000 时延迟可能超过 100ms

### 9.6 方案综合对比

| 维度 | sqlite-vec | ObjectBox | local_hnsw | 纯 Dart 线性扫描 |
|------|:----------:|:---------:|:----------:|:----------------:|
| ANN 索引（HNSW） | ✅ | ✅ | ✅ | ❌ |
| 搜索复杂度 | O(log n) | O(log n) | O(log n) | O(n) |
| 万级向量延迟 | <1ms | <1ms | 未知 | ~20ms |
| 十万级向量延迟 | <1ms | <1ms | 未知 | ~200ms |
| Drift/SQLite 兼容 | ❌ 需 FFI  hack | ❌ 独立数据库 | N/A | ✅ 无缝 |
| 单数据库架构 | ✅ | ❌ | ✅（内存） | ✅ |
| 零额外依赖 | ❌ | ❌ | ✅ | ✅ |
| APK 体积增加 | ~1MB | ~2MB | 0 | 0 |
| 生产成熟度 | ❌ 不成熟 | ✅ 成熟 | ⚠️ 低 | ✅ 完全可控 |
| 维护风险 | 高 | 中 | 高 | 极低 |

### 9.7 最终选型建议

**采用「FTS5 + 纯 Dart 向量检索」方案**，理由如下：

1. **架构简洁性**：FTS5（Drift/SQLite）+ 向量表（Drift/SQLite）= **单库架构**。引入 ObjectBox 会变成双库架构，混合查询需跨库协调，复杂度远超收益。

2. **当前量级完全够用**：Memex PKM 文件级向量，即使年增长到 10,000+ 文件，纯 Dart 线性扫描延迟仍在 20~40ms，用户无感知。

3. **零依赖、零体积增加**：不引入任何新原生库，APK/IPA 体积不变。

4. **代码完全可控**：余弦相似度 + 最小堆的实现不到 50 行 Dart 代码，无外部依赖风险。

5. **预留升级路径**：
   - 当向量数突破 5 万且延迟不可接受时，可平滑迁移至 ObjectBox（HNSW 索引）
   - 当 sqlite-vec 官方 Dart 绑定成熟后，可迁移至 sqlite-vec（单库架构回归）

### 9.8 向量存储 Schema 设计

```dart
// Drift Table（普通表，非虚拟表）
class VectorIndex extends Table {
  TextColumn get filePath => text()();      // PKM 文件相对路径（PK）
  TextColumn get fileHash => text()();      // 内容哈希，用于增量更新判断
  BlobColumn get embedding => blob()();     // Float32List 序列化
  IntColumn get dimension => integer()();   // 维度（1536/2048/768 等）
  IntColumn get updatedAt => integer()();   // 最后更新时间戳

  @override
  Set<Column> get primaryKey => {filePath};
}
```

### 9.9 混合打分算法

```dart
// 伪代码
Future<List<SearchResult>> hybridSearch(String query, {int limit = 50}) async {
  // 1. FTS5 关键词搜索
  final ftsResults = await ftsSearch(query, limit: limit * 2);

  // 2. 向量语义搜索（仅在 query 长度 > 2 时触发，避免短词浪费 Embedding API 调用）
  List<VectorResult> vectorResults = [];
  if (query.trim().length > 2) {
    final queryEmbedding = await embeddingProvider.embed(query);
    vectorResults = await vectorSearch(queryEmbedding, limit: limit * 2);
  }

  // 3. 加权融合（RRF 或线性加权）
  return mergeResults(
    ftsResults, weight: 0.3,
    vectorResults, weight: 0.7,
    limit: limit,
  );
}
```

## 十、Chunking 策略

| 方案 | 说明 | 选择 |
|------|------|------|
| 文件级向量 | 每个 Markdown 文件生成一条向量 | ✅ **推荐**（PKM 文件通常主题聚焦，粒度适中） |
| Chunk 级向量 | 文件切分为 400 tokens/80 overlap 的块，每块一条向量 | 作为未来扩展，当前文件级足够 |

> 文件级向量的优势：与 FTS5 的文档粒度一致，混合打分逻辑简单；减少 Embedding API 调用量和存储占用。

---

**Labels**: `enhancement`, `search`, `performance`, `agent`
