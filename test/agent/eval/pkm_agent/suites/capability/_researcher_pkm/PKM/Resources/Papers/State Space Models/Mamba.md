# Mamba — Linear-Time Sequence Modeling with Selective State Spaces

<!-- fact_id: fact_pkm_paper_mamba_001 -->

Authors: Gu, Dao 2023.

The selective scan trick is what unlocks input-dependent dynamics — that
was the missing piece compared to S4. Hardware-aware impl matters; the
naive scan kills throughput.

## Key takeaways

- O(n) inference, O(n log n) training (with the scan).
- Beats Transformers of comparable size up to ~3B (per the paper).
- Mamba-2 simplifies the formulation significantly — read that next.

## Open

How does it compose with MoE? See `Mixtral.md` for that direction.
