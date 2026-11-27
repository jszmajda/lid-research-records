Updated `docs/high-level-design.md` to record self-hosted WebSockets as the change-delivery approach:

```markdown
## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are pushed to connected browsers over self-hosted WebSockets. Each committed edit is persisted as a replayable event revision and published to active socket sessions for that event, while browsers maintain a live subscription and catch up on missed revisions after disconnects.

Change storage, delivery, and browser sync are designed together around this model: the change store provides replayable revisions and reliable publication, delivery manages WebSocket sessions and connection capacity, and browser sync handles reconnect and catch-up recovery.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns event revision history, replayable revision reads for catch-up, and reliable publication of committed changes to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription authorization, connection capacity, and fan-out of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the WebSocket subscription lifecycle, connectivity status visibility, reconnect handling, and revision catch-up.
```

Added under `## Key Design Decisions`:

```markdown
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed over self-hosted WebSockets rather than five-second HTTPS polling or a hosted realtime service. Five-second polling offers simpler stateless operation at the cost of repeated reads and multi-second lag; a hosted realtime service reduces connection operations at the cost of recurring vendor fees and provider coupling. Self-hosted WebSockets trade owning connection capacity and reconnect/catch-up complexity for low-latency updates without realtime vendor lock-in, requiring replayable revisions and reliable publication in the change store, session management in delivery, and reconnect/catch-up logic in browser sync.
```

### Before moving to Phase 2

1. **Decision doc vs. Key Design Decisions entry:** This choice stays live for a future cold reader — all three options can meet the 15-second freshness goal, both self-hosted and managed infrastructure are permitted by the tenets, and three downstream nodes (`change-store`, `delivery`, `browser-sync`) are about to be sized around it. Would you like to record it as a standalone decision doc at `docs/decisions/change-delivery.md` (linked from `## Key Design Decisions`), or keep it as the `## Key Design Decisions` entry in `docs/high-level-design.md`?
2. **Cascade note (`access`):** `docs/intent/access/access-design.md` still refers to "the still-open change-delivery approach" in its Context section. I left it untouched at the segment boundary; let me know if you want that phrasing updated once the HLD is approved.

Please review the HLD update and let me know any changes, your preference on the decision doc, and whether we're ready to move on to the three downstream nodes.