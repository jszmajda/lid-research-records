The HLD is updated to the self-hosted WebSockets approach (Phase 1). What changed in `docs/high-level-design.md`:

**Approach** — now states the delivery design as settled: the server manages socket sessions and publishes each committed revision; browsers catch up from the change store's replayable revision history. The open-options paragraph is gone.

**Architecture** — the three unwritten nodes now carry their WebSocket-shaped obligations:
- Change store: replayable revisions and reliable publication to delivery
- Delivery: session management — connection capacity, publication to connected sessions, reconnection of dropped sessions
- Browser sync: subscription, reconnect, and catch-up logic against the replayable revisions

**Key Design Decisions** — new entry recording the choice: polling rejected (repeated store reads, seconds of lag), hosted realtime rejected (recurring fees, provider coupling); connection and reconnect operations accepted as the cost of fast updates without a realtime vendor.

Before we move to the three nodes, four things for you:

1. **Review the HLD changes above** — approve as-is or give numbered feedback.
2. **Decision doc?** This choice stays live for a cold reader — polling meets the 15-second freshness target with less machinery, so someone will eventually ask why we took on connection management. Three nodes are about to be sized around it. I can record it as a full decision doc (`docs/decisions/change-delivery-approach.md`) with options and criteria, or the Key Design Decisions row stands alone. Which?
3. **Tenet.** The choice reveals a lean — vendor independence over operational simplicity — but the current tenet still says self-hosted and managed infrastructure are *both permitted*. Sharpen the tenet to match the lean, or keep it permissive for future infrastructure decisions?
4. **Cross-segment drift.** `access-design.md` still says authorization is "independent of the still-open change-delivery approach" — now stale since the approach is settled. May I cascade that one-line fix into the access segment, or leave it until that node is next touched?