Updated `docs/high-level-design.md` with self-hosted WebSockets, your operational tradeoff, and the responsibilities that will guide the three nodes.

## HLD for review

### Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10–25 editors and averages two status changes per minute, with larger bursts around opening time.

### Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Self-hosted secure WebSockets push committed changes to connected browsers, providing fast updates without depending on a realtime service vendor. Event updates contain stall IDs and operational statuses, not customer records.

Change storage, delivery, and browser recovery share an event-revision boundary. The change store retains replayable committed revisions and supports reliable publication; delivery owns socket sessions and catch-up delivery; browsers reconnect and recover missed changes against their last applied revision. A socket connection alone is not evidence that a browser has the latest board. MarketBoard operates connection capacity, reconnect handling, and publication recovery as part of its service.

Low-latency updates and independence from a realtime vendor justify the additional connection and reconnect operations work. The required freshness target remains 15 seconds under normal connectivity; subsecond updates are desirable, not a separate guarantee.

### Architecture

- **Access:** `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- **Change store:** `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative board state, replayable event revisions, and reliable publication of committed changes. Its design must establish how publication recovers from failures without losing committed edits.
- **Delivery:** `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted secure WebSocket sessions, delivery of committed revisions, and catch-up delivery. Its design must cover connection capacity and recovery across connection or service interruptions.
- **Browser sync:** `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser’s revisioned view, WebSocket subscription, reconnect, and catch-up behavior, including visible connectivity failures. Its design must establish how recovery reaches the latest board without gaps between catch-up and live updates.

### Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Prefer fast, realtime-vendor-independent updates over minimizing connection and reconnect operations work.

### Goals

- Show committed changes in connected browsers within 15 seconds under normal connectivity.
- Support 800 simultaneous browsers and opening-time bursts of 20 edits per second.
- Recover the latest board after a browser has been disconnected for up to 20 minutes.
- Retain seven days of event revisions for operational investigation.
- Achieve 99.5 percent availability during published event hours.

### Non-Goals

- Offline editing or resolving conflicting offline commands.
- Vendor payments, customer information, or public attendee access.
- Multi-region active-active operation for the pilot.

### Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** Editors submit commands to the server, which assigns each committed edit one event revision. Peer-to-peer or browser-side merging was rejected: the tenets require one authoritative revision regardless of delivery route, and offline editing is a non-goal.
- **Self-hosted WebSockets for change delivery.** Five-second HTTPS polling offers simpler stateless operation but adds repeated reads and seconds of update lag. A hosted realtime service reduces connection operations work and accelerates low-latency delivery, but introduces recurring service fees and provider coupling. Self-hosted WebSockets provide fast updates without a realtime vendor dependency, at the accepted cost of operating connection capacity and reconnect recovery. This choice applies across change storage, delivery, and browser sync: replayable revisions, reliable publication, socket-session management, and browser catch-up must form a coherent recovery path.

---

**Coherence note:** Access’s command design and specifications remain compatible with this approach, but `docs/intent/access/access-design.md` still describes delivery as “still-open.” That wording needs alignment during the cross-node cascade. `git diff --check` passed.

1. **Do you approve this HLD update before we move to the three nodes?**
2. This choice has credible alternatives and shapes all three nodes, so a future reader could reasonably revisit it. **Would you like a standalone decision doc in `docs/decisions/` capturing the criteria and tradeoffs, or is the HLD decision entry sufficient?**