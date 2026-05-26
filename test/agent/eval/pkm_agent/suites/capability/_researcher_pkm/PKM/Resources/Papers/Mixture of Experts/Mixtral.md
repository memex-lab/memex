# Mixtral 8x7B

<!-- fact_id: fact_pkm_paper_mixtral_001 -->

Authors: Mistral AI team 2023-12.

Sparse MoE with 8 experts × 2 active. Gives a clean "model size for
free" lever — 47B params, 13B active.

## Notes

- Routing is per-token, top-2.
- Load balancing loss matters more than I expected.
- The big story is that you can drop this in as a Llama-2 replacement
  and inference works at ~13B speed.
