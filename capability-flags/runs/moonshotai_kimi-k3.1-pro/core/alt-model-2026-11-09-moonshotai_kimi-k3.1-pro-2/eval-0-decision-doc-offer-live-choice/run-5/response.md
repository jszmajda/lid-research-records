Updated `docs/high-level-design.md` for the selected self-hosted WebSockets approach:

- **Approach:** committed changes now flow over self-hosted WebSockets through a revisioned update path.
- **Architecture:** the change store owns replayable revisions and reliable publication; delivery owns socket capacity, sessions, and reconnect handling; browser sync owns subscriptions, reconnects, and catch-up.
- **Key Design Decisions:** recorded the trade-off—accepting connection and recovery operations to gain fast updates without realtime-vendor coupling or recurring service fees. Polling and hosted realtime alternatives are documented with their rejection rationale.

The existing Access LLD still describes delivery as an “open” choice. That is now stale, but updating it crosses into a separate segment.

Please approve the HLD update and confirm whether I should include that small Access cleanup when proceeding to the change-store, delivery, and browser-sync nodes.