I have updated `docs/high-level-design.md` for **Phase 1 (HLD)** to commit to self-hosted WebSockets as current intent.

### Updated `docs/high-level-design.md`

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server commits each edit as a numbered event revision and broadcasts updates to connected browsers over self-hosted WebSockets.

Delivery, change storage, and browser recovery work together around the revision stream: the change store persists replayable revisions and publishes committed edits reliably, the delivery service manages WebSocket sessions and revision replay, and browsers maintain socket connections with reconnect and catch-up logic for gaps up to 20 minutes.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Authorizes HTTPS commands and snapshot reads against current server-side event assignments.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns ordered event revisions, seven-day retention, replay queries for reconnecting browsers, and reliable publication to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, event subscriptions, live revision fan-out, and revision replay.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket connection lifecycle, visible connectivity state, and reconnect catch-up from the last applied revision.

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
- **Self-hosted WebSockets for change delivery.** Connected browsers receive committed revisions over self-hosted WebSocket sessions, catching up via revision replay after brief disconnects. Five-second HTTPS polling (simpler stateless operation, cursor queries, and browser polling loops, at the cost of repeated read load and multi-second lag) and a hosted realtime service (less connection ops and fast updates, at the cost of recurring fees, provider coupling, and publication reconciliation) were rejected in favor of low-latency updates without vendor lock-in or recurring realtime fees, accepting ownership of socket capacity, session management, and reconnect recovery.
```

---

### Items for Your Review Before Phase 2

1. **Decision doc vs. HLD Key Design Decisions entry:** Because this choice trades three credible options across multiple criteria (latency, operational burden, vendor coupling/recurring cost) and sizes `change-store`, `delivery`, and `browser-sync`, it qualifies for a standalone project-level decision doc (`docs/decisions/change-delivery-approach.md`) linked from `## Key Design Decisions`. Would you like me to draft that standalone decision doc, or keep the summary entry in `## Key Design Decisions` as written above?
2. **Tenet check:** Your selection leaned toward owning operational state over external vendor coupling and recurring realtime fees when low latency is desired. Should we record a general tie-breaker tenet in `## Tenets` (for example: *"Prefer self-hosted operational state over recurring vendor coupling when both satisfy availability and latency goals"*) alongside or replacing the fourth tenet, or keep this preference scoped to the WebSocket delivery decision only?
3. **Note on `access` LLD:** `docs/intent/access/access-design.md` currently mentions *"the still-open change-delivery approach"* in its `## Context` section. Per cross-segment cascade discipline, I left `access` untouched for now — let me know if you want me to clean up that phrasing as we move into Phase 2, and which of the three nodes (`change-store`, `delivery`, or `browser-sync`) you'd like to tackle first once the HLD is approved.