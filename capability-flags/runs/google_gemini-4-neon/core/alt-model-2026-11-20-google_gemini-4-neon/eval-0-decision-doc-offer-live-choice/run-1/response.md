Updated `docs/high-level-design.md` for Phase 1 review:

```markdown
## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets.

Change storage, delivery, and browser sync work together around event revisions: the change store persists replayable revisions and publishes committed edits reliably, delivery manages WebSocket sessions and fan-out, and browsers handle reconnects and catch-up from their last seen revision.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable event revision history and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Manages self-hosted WebSocket sessions, subscriptions, and live push of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket connection lifecycle, reconnect handling, and revision catch-up after disconnects.
```

And under `## Key Design Decisions`:

```markdown
- **Self-hosted WebSockets for change delivery.** Committed event revisions are pushed to connected browsers over self-hosted WebSockets, backed by replayable revision history for reconnect catch-up. Five-second HTTPS polling (simpler stateless operation, but repeated reads and multi-second lag) and a hosted realtime service (less connection management, but recurring vendor fees and provider coupling) were rejected to get fast updates without tying the board to a realtime vendor, accepting the operational work of managing connection capacity and reconnects.
```

Before we move on to the three nodes, two quick checks:

1. **Decision doc vs. HLD entry:** Because all three delivery options stay credible against multiple criteria (freshness vs. connection ops vs. vendor fees/coupling, especially with a 15-second freshness goal) and `change-store`, `delivery`, and `browser-sync` are all being sized around this choice, a cold reader could easily re-litigate it later. Would you like me to record this as a project-level decision doc at `docs/decisions/change-delivery.md` (linked from `## Key Design Decisions`), or keep it as the `## Key Design Decisions` entry in the HLD?
2. **Minor wording cascade in `access`:** `docs/intent/access/access-design.md` still refers to "the still-open change-delivery approach." Should I clean up that line after you approve the HLD?

Let me know any edits to `docs/high-level-design.md` and your call on the two items above.