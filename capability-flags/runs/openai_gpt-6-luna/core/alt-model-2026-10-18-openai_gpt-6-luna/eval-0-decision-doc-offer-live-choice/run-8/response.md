Updated `docs/high-level-design.md` to make self-hosted WebSockets the delivery approach. The Phase 1 HLD review is the required stop before moving on to the three design nodes.

> # MarketBoard High-Level Design
>
> ## Problem
>
> Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.
>
> ## Approach
>
> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Deliver committed changes over self-hosted WebSocket connections for fast updates without a realtime vendor dependency. The change store retains replayable revisions and supports reliable publication; delivery manages connection sessions and publishes revisions; browsers reconnect and catch up from their last applied revision. This approach accepts the connection-capacity and reconnect operations required to operate the WebSocket service.
>
> ## Architecture
>
> - Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
> - Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative event revisions, revision replay, and reliable publication of committed changes.
> - Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions and publication of committed revisions to connected browsers.
> - Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscription, reconnect, and catch-up from the last applied revision.
>
> ## Tenets
>
> - A committed edit has one authoritative event revision regardless of its delivery route.
> - Connectivity failures must be visible, not mistaken for an unchanged board.
> - Commands use server-side authorization; browser state is not evidence of permission.
> - Self-hosted and managed infrastructure are both permitted. Event updates contain stall IDs and operational statuses, not customer records.
>
> ## Goals
>
> - Show committed changes in connected browsers within 15 seconds under normal connectivity.
> - Support 800 simultaneous browsers and opening-time bursts of 20 edits per second.
> - Recover the latest board after a browser has been disconnected for up to 20 minutes.
> - Retain seven days of event revisions for operational investigation.
> - Achieve 99.5 percent availability during published event hours.
>
> ## Non-Goals
>
> - Offline editing or resolving conflicting offline commands.
> - Vendor payments, customer information, or public attendee access.
> - Multi-region active-active operation for the pilot.
>
> ## Key Design Decisions
>
> - **Commands over HTTPS, one authoritative board per event.** Editors submit commands to the server, which assigns each committed edit one event revision. Peer-to-peer or browser-side merging was rejected: the tenets require one authoritative revision regardless of delivery route, and offline editing is a non-goal.
> - **Self-hosted WebSocket delivery for committed revisions.** Polling and hosted realtime delivery were considered. WebSockets provide fast updates without a realtime vendor dependency; the project accepts the connection-capacity, session-management, and reconnect work this requires. The change store must support replayable revisions and reliable publication, delivery must manage socket sessions, and browsers must reconnect and catch up after interruption.

`git diff --check` passes. Please review and approve this HLD, or tell me what to adjust.

Two choices for the HLD:
1. Should vendor independence over lower operational burden be a project-wide tie-breaker for realtime delivery, or stay specific to this decision?
2. Would you like a full decision doc under `docs/decisions/` with the options and trade-offs, or is the HLD decision entry sufficient?

After your review, we can proceed to the three nodes.