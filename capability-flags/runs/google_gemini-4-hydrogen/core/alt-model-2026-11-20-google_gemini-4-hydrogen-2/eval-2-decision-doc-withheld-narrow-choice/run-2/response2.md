I recommend keeping it as the **Decisions & Alternatives** row in `docs/intent/previews/previews-design.md` rather than writing a full decision doc:

1. **It affects only the `previews` node.** Both the HLD and `review-api` isolate cache paths and replacement tracking inside the preview worker—no other node is sized around 2Q or depends on it.
2. **Deliberation length isn't the bar.** A decision doc is for choices that stay live across the system's design; here, a cold reader only needs to know why 2Q beat LRU (scan resistance for comparison sheets) and aged frequency (faster adaptation on project switches), which the table row already settles.

That said, if you still want a standalone doc at `docs/intent/previews/decisions/cache-eviction-policy.md`, say the word and I'll write it. Otherwise, let me know your approval on `previews-design.md` and which of the 10 edge-case probe items to fold in vs. defer so we can move to **Phase 3 (EARS specs)**.