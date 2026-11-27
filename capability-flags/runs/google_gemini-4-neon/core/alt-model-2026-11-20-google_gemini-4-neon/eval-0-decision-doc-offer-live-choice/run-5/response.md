Updated `docs/high-level-design.md` for Phase 1 with the self-hosted WebSockets approach. Below are the updated sections for review (Problem, Tenets, Goals, and Non-Goals are unchanged):

```markdown
## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS, and the server pushes committed changes to connected browsers over self-hosted WebSockets so browsers maintain a revisioned view of the board with low-latency updates and no dependency on a hosted realtime provider.

Change storage, delivery, and browser sync are designed together around replayable event revisions. The change store persists replayable revisions and supports reliable publication; delivery manages WebSocket sessions, fan-out, and revision replay; and browser sync handles connection visibility, reconnects, and revision catch-up after disconnects.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable event revision history, read indexes, and reliable publication to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription credentials, fan-out, and revision replay.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscriptions, connection visibility, reconnect handling, and revision catch-up.

## Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** Editors submit commands to the server, which assigns each committed edit one event revision. Peer-to-peer or browser-side merging was rejected: the tenets require one authoritative revision regardless of delivery route, and offline editing is a non-goal.
- **Self-hosted WebSockets for change delivery.** Committed board changes are pushed to browsers over self-hosted WebSockets rather than five-second HTTPS polling or a hosted realtime service. Five-second polling keeps delivery stateless but incurs repeated reads and multi-second lag; a hosted realtime service reduces connection operations but introduces recurring fees and provider coupling. Self-hosted WebSockets deliver fast updates without vendor lock-in or recurring realtime fees, accepting ownership of connection capacity, session management, and reconnect/catch-up logic across change storage, delivery, and browser sync.
```

**Before we move past Phase 1:**

1. **Decision doc vs. HLD entry:** Because all three delivery options meet the 15-second freshness goal, trade off against multiple criteria (latency, operational burden, vendor cost/coupling), and shape three upcoming nodes (`change-store`, `delivery`, `browser-sync`), a cold reader could plausibly re-litigate this choice. Would you like to record a standalone decision doc at `docs/decisions/change-delivery.md` (linked from `Key Design Decisions`), or leave it as the `Key Design Decisions` entry in `docs/high-level-design.md`?
2. **Downstream wording note (`access`):** `docs/intent/access/access-design.md` still refers to "the still-open change-delivery approach." I left it untouched during Phase 1; let me know if you want that line updated once the HLD is approved.

Please review the HLD update and let me know any changes, your preference on the decision doc, and whether we are approved to proceed to Phase 2 for `change-store`, `delivery`, and `browser-sync`.