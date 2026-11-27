Updated `docs/high-level-design.md` with the self-hosted WebSockets approach and your accepted operations tradeoff. Here is the revised HLD for review.

---

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Deliver committed changes over self-hosted WebSockets for fast updates without a realtime vendor dependency or recurring realtime service fees. Subsecond updates are desirable; the required freshness target remains 15 seconds under normal connectivity.

Event updates contain stall IDs and operational statuses, not customer records.

Change storage, delivery, and browser recovery share the authoritative event revision as their synchronization boundary. The change store provides replayable revisions and reliable publication of committed changes. Delivery owns socket sessions and connection capacity. Browsers reconnect and catch up after interruptions. Operating connection capacity and reconnect behavior is an accepted cost of low-latency delivery and independence from a realtime vendor; self-hosting still carries infrastructure and operations costs.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative board changes, replayable event revisions, and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection capacity, and delivery of committed revisions to subscribed browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the revisioned browser view, WebSocket subscription, reconnect, and catch-up behavior.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Prefer low-latency updates and independence from a realtime vendor over minimizing connection and reconnect operations work.

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
- **Self-hosted WebSockets for committed changes.** Five-second HTTPS polling offers simpler stateless operations but adds repeated reads and several seconds of lag. A hosted realtime service offers low-latency delivery with less connection operations work but adds recurring fees and provider coupling. Self-hosted WebSockets favor fast updates and realtime vendor independence, accepting responsibility for connection capacity and reconnect recovery. This choice obligates the change store to provide replayable revisions and reliable publication, delivery to manage socket sessions, and browser sync to reconnect and catch up.

---

**Coherence note:** Access’s command authorization remains compatible, but its design still describes delivery as “still-open.” That wording needs a cross-node cleanup with your approval. `git diff --check` passed.

1. Do you approve this HLD, including the preference captured in the final tenet? May I also update Access’s stale wording before we tackle the three nodes?
2. This choice has credible alternatives and shapes all three nodes, so a future reader may revisit it. Would you like a standalone decision doc comparing the tradeoffs, or is the HLD’s Key Design Decisions entry sufficient?