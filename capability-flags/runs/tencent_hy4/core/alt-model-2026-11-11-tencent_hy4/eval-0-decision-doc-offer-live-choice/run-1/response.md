Phase 1 complete — coherence pre-flight passed (the written `Access` leaf is independent of delivery; the three dependent nodes still read "Not written yet"). I updated `docs/high-level-design.md` to commit to self-hosted WebSockets, written fresh with no trace of the open-decision framing. Here is the full phase output for review:

**## Approach**
> Keep one authoritative board per event. Editors submit commands over HTTPS, and the server assigns each committed edit one event revision. Browsers display a revisioned view of the board and stay current over self-hosted WebSocket connections: the delivery service holds a session for each connected browser and pushes every newly committed revision to it as soon as it is published.
>
> The change store retains replayable revisions and a reliable publication outbox, so a committed edit is never lost between publication and delivery. When a browser's connection drops, it reconnects and catches up from the last revision it saw. The delivery service owns connection capacity and reconnect handling; the browser owns catch-up. Propagation is typically sub-second; the governing requirement is that committed changes appear in connected browsers within 15 seconds under normal connectivity.
>
> Self-hosted delivery keeps updates fast without coupling the board to a realtime vendor. Connection capacity, reconnect bursts around opening time, and publication reliability are operated by the project rather than delegated to a provider. The change store, delivery service, and browser sync all work from the same revision stream.

**## Architecture** — the three nodes now name their concrete responsibilities instead of "depend on the approach" (still "Not written yet"; Access unchanged):
> - Change store: … Owns replayable event revisions, read indexes, and the publication outbox that feeds delivery.
> - Delivery: … Owns WebSocket sessions, connection capacity, and reliable publication of committed revisions.
> - Browser sync: … Owns the board subscription, reconnect, and revision catch-up behavior.

**## Key Design Decisions** — added one row:
> - **Committed changes over self-hosted WebSockets.** Delivery pushes each committed event revision to connected browsers over project-operated WebSocket sessions. Five-second HTTPS polling was rejected for its repeated reads and multi-second lag; a hosted realtime service was rejected for recurring fees and provider coupling. Self-hosted sockets deliver fast updates without binding the board to a realtime vendor, at the cost of owning connection capacity, reconnect handling, and reliable publication. This choice sizes the change store (replayable revisions and a publication outbox), delivery (session management), and browser sync (reconnect and catch-up).

I'll stop here for the Phase 1 review before doing the three nodes. A few calls are yours to make:

1. **Approve the HLD, or give numbered edits?** I won't start the three nodes (change store, delivery, browser sync) until you approve — each gets its own Phase 2 stop.
2. **Full decision doc?** This choice traded off latency, operating burden, vendor coupling, and cost, and the three nodes are about to be sized around it, so a cold reader could re-litigate it. Want me to record it as a standalone decision doc (`docs/decisions/websocket-delivery.md`) linked from the Key Design Decisions row, or is the row alone enough?
3. **Tenets — which way do you lean?** Your rationale ("fast updates without tying the board to a realtime vendor, accepting the extra connection/reconnect work") is tenet-shaped. Should I add a one-line lean under `## Tenets` (e.g. "Prefer fast, vendor-independent updates even at the cost of owning more operations")? And should the existing "Self-hosted and managed infrastructure are both permitted" tenet stay as a neutrality statement or be sharpened to reflect this preference?
4. **Cross-segment cascade:** `docs/intent/access/access-design.md` still says authorization is "independent of the still-open change-delivery approach" — now stale since the approach is settled. That's a sibling segment, so I've left it untouched. Want me to clean that wording as a cascade, or hold it until we do the three nodes?