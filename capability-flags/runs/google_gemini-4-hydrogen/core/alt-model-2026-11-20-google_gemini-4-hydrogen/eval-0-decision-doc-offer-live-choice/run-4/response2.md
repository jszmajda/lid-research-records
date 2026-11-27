Created `docs/decisions/change-delivery-approach.md` and linked it from `Key Design Decisions` in `docs/high-level-design.md`.

It records the context, the four weighted decision criteria (vendor independence and recurring cost, connection/reconnect operational burden, update latency and read efficiency, and cross-node architectural simplicity), cold-readable analysis of all three options, and the selection rationale plus downstream obligations for `change-store`, `delivery`, and `browser-sync`.

Ready to proceed to Phase 2 for those three nodes when you approve the Phase 1 HLD + decision doc—and let me know if you'd also like me to update the stale *"still-open change-delivery approach"* line in `docs/intent/access/access-design.md`.