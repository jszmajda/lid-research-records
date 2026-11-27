Updated `docs/high-level-design.md` for self-hosted WebSockets (Phase 1 — HLD update):

```markdown
## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit a single event revision and delivers committed changes to connected browsers over self-hosted WebSockets. Browsers display a revisioned view of the board, maintain a WebSocket session for live updates, and catch up from the event's revision history after disconnects.

Change storage, delivery, and browser sync are designed together around this boundary: the change store persists replayable event revisions and supports reliable publication, delivery manages WebSocket sessions and fan-out, and browser sync handles connection state, reconnects, and revision catch-up.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative revision history, replayable revision queries, and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription authorization, and change fan-out.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser WebSocket connection, visible connectivity status, reconnects, and revision catch-up.
```

```markdown
## Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** Editors submit commands to the server, which assigns each committed edit one event revision. Peer-to-peer or browser-side merging was rejected: the tenets require one authoritative revision regardless of delivery route, and offline editing is a non-goal.
- **Self-hosted WebSockets for change delivery.** Committed board changes are pushed to browsers over self-hosted WebSockets rather than five-second HTTPS polling or a hosted realtime service. This provides low-latency updates without recurring realtime vendor fees or provider coupling, accepting the operational and design work of managing WebSocket connection capacity, replayable revision storage, and browser reconnect/catch-up. Five-second polling was rejected for its repeated reads and multi-second lag; a hosted realtime service was rejected for recurring fees and provider coupling.
```

Before we move on to the three downstream nodes (`change-store`, `delivery`, `browser-sync`):

1. **HLD review:** Does the updated `docs/high-level-design.md` match your intent, or would you like any changes?
2. **Decision doc offer:** Because all three delivery options meet the 15-second freshness goal, none is ruled out by a standing constraint, and three downstream nodes are about to be shaped around this trade-off, a future cold reader could easily re-litigate why WebSockets was chosen over polling or a hosted service. Would you like me to record this choice as a standalone decision doc at `docs/decisions/change-delivery.md` (linked from `Key Design Decisions`), or is the `Key Design Decisions` entry in `docs/high-level-design.md` sufficient?
3. **Minor cascade note (`access`):** `docs/intent/access/access-design.md` (Context) still refers to "the still-open change-delivery approach." Should I update that line to reflect the settled delivery approach as well?