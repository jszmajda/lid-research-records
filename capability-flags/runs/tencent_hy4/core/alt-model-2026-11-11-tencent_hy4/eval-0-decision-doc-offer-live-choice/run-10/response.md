Phase 1 done. I committed the approach to self-hosted WebSockets and rewrote the HLD as current intent (removed the "still open"/three-options/"depends on the approach" language). As you asked, I've held the three nodes — change store, delivery, browser sync are untouched. The skill requires a Phase 1 review stop before any downstream cascade, so I'm stopping here.

Revised `docs/high-level-design.md`:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach connected browsers over self-hosted WebSockets: the server owns the socket layer and pushes each committed revision as it happens. Subsecond updates are useful but not required; pushing revisions satisfies the freshness target.

The change store, delivery, and browser recovery are designed together around this socket path. The change store records revisions in replayable order and publishes them reliably. Delivery manages socket sessions and fans out published revisions. Browsers reconnect and catch up from their last revision after an interruption. The server owns connection capacity, reconnects, and catch-up; in return the board gets fast updates without a recurring realtime-vendor fee or a dependency on a hosted provider.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, read indexes, and a replayable publication outbox feeding the socket path.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns socket sessions, reliable publication of revisions, and connection capacity.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the client subscription, reconnect, and catch-up-from-revision behavior.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Self-hosted and managed infrastructure are both permitted. Event updates contain stall IDs and operational statuses, not customer records.

## Goals

- Show committed changes in connected browsers within 15 seconds under normal connectivity.
- Support 800 simultaneous browsers and opening-time bursts of 20 edits per second.
- Recover the latest board after a browser has been disconnected for up to 20 minutes.
- Retain seven days of event revisions for operational investigation.
- Achieve 99.5 percent availability during published event hours.

## Non-Goals

- Offline editing or resolving conflicting offline commands.
- Vendor payments, customer information, or public attendee access.
- Multi-region active-active operation for the pilot.

## Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** Editors submit commands to the server, which assigns each committed edit one event revision. Peer-to-peer or browser-side merging was rejected: the tenets require one authoritative revision regardless of delivery route, and offline editing is a non-goal.
- **Self-hosted WebSockets for change delivery.** The server owns the socket layer and pushes each committed revision to connected browsers. Five-second HTTPS polling was rejected for its repeated reads and multi-second lag; a hosted realtime service was rejected for recurring fees and provider coupling. Owning the connection takes on capacity, reconnect, and catch-up work in exchange for fast updates and no dependency on a realtime vendor. The change store, delivery, and browser sync nodes are designed around replayable revisions, reliable publication, and socket sessions.
```

Coherence pre-flight: the HLD's Approach/Architecture/Key Design Decisions were inconsistent with a chosen approach; that's now reconciled. Four things I need your ruling on before I go further:

1. **Review (the Phase 1 stop).** Approve the HLD above, or send numbered feedback. I won't start the three nodes until you say go.
2. **Decision doc.** This choice stays live for a cold reader — three credible options (polling, self-hosted sockets, hosted realtime) traded against latency, recurring cost, ops burden, and vendor coupling, with the three downstream nodes about to be sized around it. Want me to record it as a full decision doc at `docs/decisions/` (linked from the Key Design Decisions row), or keep just the row? I'll write the doc only if you say yes.
3. **Tenet.** Your call takes on ops work to stay free of a realtime vendor, but the HLD has no tenet for that lean — tenet #4 only says "Self-hosted and managed infrastructure are both permitted." Should I add a one-line tenet (e.g., lean toward owning infrastructure / avoiding a recurring vendor dependency where the operational cost is bounded), or keep vendor-independence scoped to this delivery decision and leave the tenets as they are? Any other load-bearing leans to record?
4. **Cross-segment drift.** `docs/intent/access/access-design.md:10` still describes the change-delivery approach as "still-open," which is now stale. That's a different segment, so I haven't touched it. Fix that wording now, or defer it to the three-node pass?