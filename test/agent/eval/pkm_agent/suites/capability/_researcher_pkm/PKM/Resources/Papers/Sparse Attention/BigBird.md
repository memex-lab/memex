# BigBird — Transformers for Longer Sequences

<!-- fact_id: fact_pkm_paper_bigbird_001 -->

Authors: Zaheer et al. 2020
Link: arxiv 2007.14062

## Why I cared

Theoretical guarantee that random+window+global attention is universal.
Practically a bit dated now (2026) — has been overtaken by S4/Mamba on
the long-range arena, but the proof structure is still the cleanest I've
seen.

## Key ideas

- 3 attention patterns combined (random + window + global) — sparse but
  expressive.
- Reduces O(n²) to O(n) memory.
- Universal approximator argument relies on the random component.

## My questions

- Does the universal-approximator proof rely on the *exact* random
  pattern or just any sparse coverage? Need to reread §4.
