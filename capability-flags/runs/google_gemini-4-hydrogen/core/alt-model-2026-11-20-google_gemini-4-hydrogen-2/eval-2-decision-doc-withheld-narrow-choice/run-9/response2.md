I don't think it earns a full decision doc — the **Decisions & Alternatives** row in `docs/intent/previews/previews-design.md` is the right fit.

The test is forward-looking from the landed design, not how long the debate took:
- **Single-node scope**: 2Q is completely private to the preview worker (`review-api` and `high-level-design` are explicitly insulated from it, and no other node is sized around it).
- **Cold-reader clarity**: The table row already settles *why 2Q* over LRU (scan resistance for comparison sheets) and aged frequency (no project-switch lag) while naming the accepted bookkeeping and split-tuning cost.

If you still want a standalone decision doc at `docs/intent/previews/decisions/cache-eviction-policy.md`, say the word and I'll write it. Otherwise, let me know how you'd like to triage the Phase 2 edge-case probe items (1–8) and whether we're good to move to **Phase 3 (EARS specs)**.