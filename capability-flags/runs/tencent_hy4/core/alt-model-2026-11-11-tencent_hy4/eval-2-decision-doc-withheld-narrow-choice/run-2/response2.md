Short answer: I don't think it earns a full decision doc — I'd record it as a Decisions & Alternatives row, which I've added. That's a recommendation, not a decision; it's your call.

Why: the earns-its-place test is forward-looking from the landed design, not a reward for how hard the choice was. A full doc is for a choice that stays live for a cold reader because other design nodes are sized around the result. Every change here stays inside the preview cache — the preview API, render queue, and disk budget are unchanged, and the HLD tenet keeps replacement bookkeeping private to the worker — so no sibling node is sized around 2Q, and it's exactly the kind of choice the rule excludes "however long the debate ran." The three meetings and 180-message thread are the "debate happened" symptom, not the test; a cold reader of a cache built to protect comparison sheets during scans won't re-litigate 2Q. The row is the sanctioned home for the rejected alternatives (LRU, frequency-with-aging) and the rationale.

Coherence pre-flight: HLD/LLD/EARS were coherent; I removed the now-stale HLD line "Its eviction policy remains open." PREVIEW-001–005 are policy-agnostic and still valid, and there's no test/code layer in this repo, so specs stay `[ ]`. I finished the preview LLD (`docs/intent/previews/previews-design.md`): the "policy is open / candidates" paragraph is now the 2Q design (probationary `A1in` + protected `Am`, promotion on re-access, evict `A1in` before `Am`), with the choice and rejected alternatives in a Decisions row and the `A1in`/`Am` size split logged as a deferred tuning question. I left review-api untouched — node-local change, fixed interface, segment boundary respected.

LLD-level edge-case probe — please triage (fix in LLD vs defer):
1. When a screening overflows `A1in`, is a sheet evicted before any second access (never promoted), and is that intended?
2. On a hit to an `Am` entry, is `Am` pure FIFO or reordered by recency?
3. If `Am` alone exceeds 12 GiB while `A1in` is empty, which queue yields victims?
4. Are the queues persisted across a worker restart, or rebuilt cold?
5. Are entries for a superseded renderer version swept, or left to be evicted?

If you still want the full doc, say so and I'll write it and link it from the row — flagging that for a node-local choice that reads as settled once it lands, it mostly memorializes a debate that's over, and a doc-per-hard-decision habit tends to fill `docs/decisions/` with residue.

Two things to rule on before I continue: (1) triage the gaps above; (2) keep it as the Decisions & Alternatives row, or have me write the full decision doc anyway? I'm holding at this Phase 2 stop — the 2Q EARS update (Phase 3), edge audit, tests, and code are untouched pending your ruling and approval.