Phase 1 is done. Coherence pre-flight passed (ACCESS-001..004 still trace to `access-design.md`, which points to the HLD); the only file I changed is the HLD — I did not cascade into the three unwritten nodes or the access segment, per your "we'll do the three nodes after that" and the cross-segment pause rule.

**Phase 1 output — revised HLD in full** (`docs/high-level-design.md`; Problem, Tenets, Goals, Non-Goals unchanged):

```
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit one event revision and browsers display a revisioned view of the board. Committed changes reach connected browsers over self-hosted WebSocket connections: the change store retains replayable event revisions, delivery maintains socket sessions and reliably publishes committed revisions, and browsers reconnect and catch up from their last seen revision after a disconnect.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable event revisions and reliable publication of committed edits.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket session management and reliable publication of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns socket subscription, reconnect, and catch-up from the last seen revision.

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
- **Committed changes delivered over self-hosted WebSockets.** Editors' committed revisions are pushed to connected browsers over server-owned WebSocket connections. Alternatives considered: five-second HTTPS polling (stateless and simplest to operate, but repeated reads and a few seconds of lag) and a hosted realtime service (low-latency with less connection operations, but recurring fees and provider coupling). Self-hosted WebSockets is chosen to deliver fast updates without coupling the board to a realtime vendor, accepting ownership of connection capacity and reconnect/recovery work. Downstream obligations: the change store retains replayable revisions and reliable publication, delivery manages socket sessions, and browser sync handles reconnect and catch-up.
```

I wrote the Approach as a fresh author (settled mechanism, no "still open"/three-way comparison residue) and moved the rejected alternatives and rationale into Key Design Decisions.

Before I continue, I need your ruling on these (numbered feedback is easiest):

1. **Approve the Phase 1 revision?** Any changes to the Approach, Architecture lines, or the new Key Design Decisions row, or shall I take it as settled?
2. **Decision doc?** This is a consequential HLD choice from sketched options — three credible options weighed against several criteria, and three design nodes will be sized around it — so it clears the bar for a full decision doc. I've recorded it as a Key Design Decisions row. Do you want me to also write a full decision doc at `docs/decisions/realtime-delivery.md` (context, decision elements, options, selection) and link it from that row, or is the row enough? I won't write it unless you say yes.
3. **Cross-segment cascade — pausing, not auto-repairing.** Settling the approach creates downstream coherence work: (a) the three unwritten nodes (change-store, delivery, browser-sync) are now pinned to self-hosted WebSockets — you said these come after, so I've deferred them; (b) `docs/intent/access/access-design.md` still says authorization is "independent of the still-open change-delivery approach," which becomes stale once the approach is settled, and access is a separate segment. Should I fix that one line now, or fold it into the node work? I'll confirm at each segment boundary before propagating.
4. **Standing tenet?** Your choice sits under the existing tenet "Self-hosted and managed infrastructure are both permitted." Do you want the lean behind it — accept connection/reconnect operations work to avoid realtime-vendor coupling — recorded as a one-line tenet for future choices, or shall I leave the tenet list as-is?

I'll stop here for your review and won't start the three nodes or write the decision doc until you decide.