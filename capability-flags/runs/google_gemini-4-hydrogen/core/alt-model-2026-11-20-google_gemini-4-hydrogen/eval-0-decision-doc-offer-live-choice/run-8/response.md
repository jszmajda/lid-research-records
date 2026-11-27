Updated `docs/high-level-design.md` for Phase 1 with the self-hosted WebSockets decision:

- **`## Approach`**: Committed to self-hosted WebSockets for delivering committed changes and noted the resulting responsibilities across change storage (replayable revisions, reliable publication), delivery (WebSocket sessions, fan-out), and browser sync (connection lifecycle, reconnect, catch-up).
- **`## Architecture`**: Updated the unauthored descriptions for `change-store`, `delivery`, and `browser-sync` to reflect their WebSocket-era responsibilities.
- **`## Key Design Decisions`**: Added **Change delivery via self-hosted WebSockets**, recording why five-second HTTPS polling and a hosted realtime service were rejected and what downstream operational obligations this commits to.

Before we move to Phase 2 for the three nodes:
1. **Decision doc offer**: Because this choice traded credible options against multiple criteria (latency, connection/reconnect ops, vendor cost/coupling) and three downstream nodes will be sized around it, would you like me to record it as a project-level decision doc at `docs/decisions/change-delivery-transport.md` (and link it from Key Design Decisions), or leave it as the Key Design Decisions entry?
2. **Adjacent segment note**: `docs/intent/access/access-design.md` still refers to "the still-open change-delivery approach" in its Context section (its behavior is unchanged). Should I update that wording, or leave `access` untouched?
3. **Phase 1 review**: Please review the updated `docs/high-level-design.md` and confirm when you're ready to proceed to Phase 2 (`change-store`, `delivery`, `browser-sync`).