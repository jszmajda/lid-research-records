Updated `docs/high-level-design.md` for Phase 1 to commit to self-hosted WebSockets:

```markdown
## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit a monotonic event revision and publishes committed changes to connected browsers over self-hosted WebSockets. Browsers maintain a revisioned view of the board and use reconnect and catch-up logic against replayable revision history when a socket drops.

Change storage, WebSocket delivery, and browser recovery work together around this model: the change store provides replayable event revisions and reliable publication, delivery manages active socket sessions and connection capacity, and browsers subscribe to live updates while recovering missed revisions from the store on reconnect.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns event revision history, replayable revision queries, and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection capacity management, and live fan-out of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscription, disconnect detection, and revision catch-up on reconnect.
```

Added to `## Key Design Decisions`:

```markdown
- **Self-hosted WebSockets for change delivery.** Committed edits are pushed to browsers over self-hosted WebSockets backed by replayable revision storage and browser reconnect/catch-up logic. Five-second HTTPS polling (simpler stateless operation, but higher repeated read load and multi-second lag) and a hosted realtime service (less connection operations work, but recurring vendor fees and provider coupling) were rejected to get fast updates without tying the board to a realtime vendor, accepting self-hosted connection capacity and reconnect operations.
```

Before we move to Phase 2 for the three downstream nodes (`change-store`, `delivery`, `browser-sync`):

1. **HLD review:** Do the updated `Approach`, `Architecture`, and `Key Design Decisions` sections look right, or would you like any changes?
2. **Decision doc:** Because three downstream nodes will be sized around this trade-off (latency, vendor coupling/fees, and connection ops), would you like me to record it as a standalone decision doc under `docs/decisions/` (and link it from `## Key Design Decisions`), or keep just the `## Key Design Decisions` entry?
3. **Tenets:** Should `## Tenets` stay as-is, or do you want to add a tie-breaker reflecting your preference for avoiding vendor lock-in over minimizing self-hosted connection operations?
4. **Adjacent segment note:** `docs/intent/access/access-design.md` still refers to the `"still-open change-delivery approach"` in its Context section. Would you like me to update that phrasing to reflect self-hosted WebSockets as well?