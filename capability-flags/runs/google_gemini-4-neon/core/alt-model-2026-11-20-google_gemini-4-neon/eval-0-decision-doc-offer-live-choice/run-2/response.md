I have updated `docs/high-level-design.md` to record self-hosted WebSockets as the change-delivery approach (`Problem`, `Tenets`, `Goals`, and `Non-Goals` are unchanged).

### Updated sections in `docs/high-level-design.md`

```markdown
## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS, and the server commits each change as an ordered, replayable event revision. Committed changes are pushed to connected browsers over self-hosted WebSockets, while browsers display a revisioned view of the board and recover missed revisions on reconnect.

Change storage, delivery, and browser sync are designed together around this model: the change store persists replayable revisions and publishes committed changes reliably; delivery manages WebSocket sessions and fan-out within connection capacity; and browser sync handles connection lifecycle, visible connectivity state, and reconnect catch-up.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Authorizes HTTPS edit commands below the command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative event revision history, replayable revision queries for catch-up, and reliable publication of committed changes to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription authorization, fan-out of committed revisions, and connection capacity management.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser WebSocket connection, visible connectivity state, reconnect handling, and revision-based catch-up after disconnects.
```

```markdown
## Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** Editors submit commands to the server, which assigns each committed edit one event revision. Peer-to-peer or browser-side merging was rejected: the tenets require one authoritative revision regardless of delivery route, and offline editing is a non-goal.
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed over self-hosted WebSockets rather than five-second HTTPS polling or a hosted realtime service. Polling was rejected because it adds repeated read load and multi-second lag; a hosted realtime service was rejected to avoid recurring realtime vendor fees and provider coupling. This accepts the operational responsibility of connection capacity, session management, replayable revision storage, and browser reconnect catch-up.
```

### Phase 1 review & decisions before moving on

1. **HLD approval:** Does the updated `docs/high-level-design.md` capture your intent, or would you like any edits?
2. **Decision doc offer:** Because all three delivery options satisfy the 15-second freshness goal and are permitted by the tenets — and three downstream nodes (`change-store`, `delivery`, `browser-sync`) are about to be sized around this choice — a future cold reader could reasonably re-litigate why MarketBoard took on WebSocket connection/reconnect ops over polling or a hosted service. Would you like me to record this as a project-level decision doc at `docs/decisions/change-delivery.md` (with full criteria, option analyses, and selection, linked from `## Key Design Decisions`), or leave it as the `## Key Design Decisions` entry in the HLD?
3. **Tenets check:** `## Tenets` currently permits both self-hosted and managed infrastructure without a lean. Keep the tenets as-is, or add a one-line tie-breaker (e.g., favoring self-hosted independence / fast updates over minimizing operational burden)?
4. **Cascade note (`access`):** `docs/intent/access/access-design.md` still references "the still-open change-delivery approach." I have left it untouched for now — once the HLD is settled, should I update that line before we walk the three new nodes (`change-store`, `delivery`, `browser-sync`) in Phase 2?