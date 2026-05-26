# Longformer

<!-- fact_id: fact_pkm_paper_longformer_001 -->

Authors: Beltagy, Peters, Cohan 2020

Sliding-window + dilated + global attention. Predates BigBird, but the
practical recipe (window=512 + a few global tokens) is what most folks
actually deployed in 2020-2022.

## Notes from advisor sync 05-15

Advisor's hot take: "Longformer is the C++ STL of long-context models —
ugly but everyone ended up using it."

## Reading queue

- Reread §3.4 (linear-bias trick) for the thesis lit review.
