Done. Created **`docs/decisions/self-hosted-websockets.md`** with the full tradeoff analysis and linked it from the HLD.

The decision doc covers:
- **Context** — why this decision exists (40 markets, 800 browsers, 15s freshness target)
- **Gates** — no vendor lock-in (eliminates hosted realtime), subsecond latency achievable (all pass)
- **Weighted criteria** — 6 criteria with importance and tenet traceability
- **Three options** — each with description, analysis against every element, and summary
- **Selection** — why self-hosted WebSockets wins, the accepted tradeoffs (connection ops burden, implementation complexity), tenets engaged, and downstream obligations for the three nodes

A cold reader can now re-run the judgment from the landed state.

**STOP for user review.** Confirm the HLD + decision doc, and I'll proceed to **Phase 2 — LLD check/draft** for change-store, delivery, and browser-sync.