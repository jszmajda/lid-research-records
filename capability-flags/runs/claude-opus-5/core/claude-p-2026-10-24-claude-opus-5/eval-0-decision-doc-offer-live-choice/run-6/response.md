Phase 1 (HLD) — self-hosted WebSockets recorded. `docs/high-level-design.md` now reads as if this was always the route; no narration of the three-way choice remains outside the decision record.

**Approach** (rewritten)

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over WebSocket connections the project operates itself: the server publishes each newly committed event revision to the sessions subscribed to that event, and a browser that misses revisions catches up by replaying from the last revision it holds.
>
> Three concerns are designed around that route. The change store assigns and retains replayable event revisions and publishes them reliably to delivery. Delivery owns WebSocket session management, subscription state, and connection capacity. Browser sync owns subscribing, detecting a dropped connection, reconnecting, and catching up from its last known revision.
>
> Freshness beyond the 15-second goal is useful but not required; the socket route is expected to deliver well inside it, and no behavior may depend on subsecond delivery.

**Architecture** — the three unwritten nodes now carry concrete ownership instead of "depends on the approach":

- Change store: authoritative revision sequence, replay reads from an arbitrary revision, reliable publication of committed revisions to delivery.
- Delivery: WebSocket sessions, per-event subscription state, fan-out of published revisions, connection capacity.
- Browser sync: subscribing, applying revisions in order, surfacing a lost connection, reconnecting, catching up from its last known revision.

**Key Design Decisions** — added:

> **Self-hosted WebSockets deliver committed changes.** Delivery runs WebSocket sessions on infrastructure the project operates, the change store publishes each committed revision to it, and browsers reconnect and catch up from their last known revision. Five-second HTTPS polling was rejected: it would have kept delivery request/response and needed only cursor queries, but it spends repeated reads on an unchanged board and leaves every update several seconds behind. A hosted realtime service was rejected: it would have removed most connection operations work, but it carries recurring fees and couples the board's subscription behavior to one provider. All three routes meet the 15-second freshness goal, so latency alone did not decide it — owning connection capacity and reconnect handling is the accepted price for fast updates with no realtime vendor.

Three things for you:

1. **Tenet.** Your reasoning — accept ops work rather than tie the board to a vendor — is a lean that will govern choices no spec anticipates, so I drafted it as a tenet above the existing infrastructure line, which I softened to "Managed infrastructure is otherwise permitted": *"**Own the live-update path.** Prefer infrastructure the project operates over a realtime vendor for pushing updates to browsers, and accept the connection and reconnect operations work as the price."* I scoped it to the live-update path only. Should it be broader — "prefer infrastructure we operate" across the board, which would also lean the change store's hosting and any metrics or queue choice — or is this specific to realtime, with managed services fine elsewhere?

2. **Decision doc?** A cold reader meeting the session management, publication, and replay machinery is likely to ask "why not just poll?" and re-litigate it, and all three remaining nodes get sized around the answer — so this one clears the bar for a full decision doc at `docs/decisions/change-delivery-route.md`, laying out the three options against latency, recurring cost, provider coupling, and connection ops. The Key Design Decisions entry above is the alternative and stands on its own if you'd rather not. Want the doc?

3. **One cascade into the access segment.** `docs/intent/access/access-design.md` opens with "Authorization for HTTPS edit commands is independent of the still-open change-delivery approach" — now stale. The fix is a one-line edit saying authorization is independent of the WebSocket delivery route, with subscription credentials still belonging to delivery. It crosses a segment boundary from an HLD change, so I'm asking before touching it. Its specs reference nothing about delivery, so nothing else in that segment moves.

Approve or give numbered feedback, and I'll hold on change store, delivery, and browser sync until this lands.