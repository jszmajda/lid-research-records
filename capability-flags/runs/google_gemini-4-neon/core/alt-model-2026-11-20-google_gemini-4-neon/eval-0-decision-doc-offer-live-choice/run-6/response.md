Updated `docs/high-level-design.md` for self-hosted WebSocket delivery (Phase 1 — HLD):

```markdown
## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server commits each change with an event revision and pushes committed updates to connected browsers over self-hosted WebSockets so browsers maintain a revisioned view of the board.

Change storage, delivery, and browser recovery are designed around this WebSocket pipeline. The change store persists replayable event revisions and provides reliable publication of committed changes; delivery manages live WebSocket sessions and fan-out; browser sync handles connection lifecycle, reconnects, and revision catch-up after disconnects.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns event revision history, replayable revision queries, and reliable publication to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, event subscriptions, and live change fan-out.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket connection management, reconnect handling, and revision catch-up.

## Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** Editors submit commands to the server, which assigns each committed edit one event revision. Peer-to-peer or browser-side merging was rejected: the tenets require one authoritative revision regardless of delivery route, and offline editing is a non-goal.
- **Self-hosted WebSockets for change delivery.** Committed changes are pushed over self-hosted WebSockets to deliver fast updates without recurring realtime vendor fees or provider coupling, accepting the operational work of managing connection capacity and reconnect/catch-up flows across the change store, delivery, and browser sync. Five-second HTTPS polling (simpler stateless operation, but repeated reads and multi-second lag) and a hosted realtime service (lower connection-ops burden, but recurring cost and provider coupling) were rejected.
```

Before moving to the three downstream nodes, please review and let me know:

1. **HLD approval:** Do the `Approach`, `Architecture`, and `Key Design Decisions` updates look right, or would you like any edits?
2. **Decision doc offer:** Because all three options meet the 15-second freshness goal with real trade-offs across latency, connection/reconnect ops, and vendor coupling—and `change-store`, `delivery`, and `browser-sync` will all be sized around this choice—a cold reader may question why simpler polling or a hosted service wasn't used. Would you like me to record this as a project-level decision doc at `docs/decisions/change-delivery.md` (linked from `## Key Design Decisions`), or leave it as the `## Key Design Decisions` entry in `docs/high-level-design.md`?
3. **Tenets:** Is accepting extra operational work to avoid vendor coupling specific to change delivery, or should we add a project-wide tie-breaker tenet to `## Tenets`?
4. **Minor cascade note:** `docs/intent/access/access-design.md` still refers to the "still-open change-delivery approach" in its Context section. Once the HLD is approved, should I update that line as well before we start `change-store`, `delivery`, and `browser-sync`?