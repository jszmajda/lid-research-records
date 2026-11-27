Updated `docs/high-level-design.md` for **self-hosted WebSockets** (Phase 1 — HLD).

### Updated sections in `docs/high-level-design.md`

- **Approach**:
  > Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets.
  >
  > Delivery, change storage, and browser recovery are designed together around self-hosted WebSockets: the change store maintains replayable event revisions and reliable publication, the delivery layer manages persistent socket sessions, and browsers run reconnect and catch-up logic against authoritative revisions. Self-hosting delivers fast updates without realtime vendor fees or provider coupling, in exchange for owning connection capacity and reconnect operations.
- **Architecture**: Updated `Change store`, `Delivery`, and `Browser sync` summaries (still marked `Not written yet.`) to reflect replayable revisions/publication, self-hosted WebSocket sessions/fan-out, and WebSocket subscription/reconnect/catch-up.
- **Key Design Decisions**: Added **Self-hosted WebSockets for change delivery**, naming the rejected alternatives (five-second HTTPS polling and hosted realtime service) and the trade-off accepted.

### Questions before proceeding

1. **Decision doc offer**: Because this choice trades credible options across multiple criteria (latency, connection-ops burden, vendor cost/coupling) and sizes three downstream nodes (`change-store`, `delivery`, `browser-sync`), a cold reader could question why WebSockets were chosen for a 15-second freshness target. Would you like me to record it as a full decision doc at `docs/decisions/change-delivery-approach.md` and link it from `Key Design Decisions`, or keep the `Key Design Decisions` entry as-is?
2. **Existing segment note**: `docs/intent/access/access-design.md` (line 10) still says *"independent of the still-open change-delivery approach"*. Should I update that wording when we cascade, or leave `access` untouched for now?
3. **Phase 1 approval**: Please approve this HLD update (or share any changes) so we can move to Phase 2 for `change-store`, `delivery`, and `browser-sync`.