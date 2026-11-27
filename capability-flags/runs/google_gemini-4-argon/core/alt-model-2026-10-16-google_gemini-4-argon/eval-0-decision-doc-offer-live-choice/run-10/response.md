I have updated `docs/high-level-design.md` to settle on self-hosted WebSockets as the change-delivery approach, written as current intent.

### Updated `docs/high-level-design.md`

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server commits each change to the change store with an authoritative event revision and pushes updates to connected browsers over self-hosted WebSockets.

Delivery, change storage, and browser recovery work together around this WebSocket pipeline: the change store maintains replayable revisions and reliable publication, the delivery component manages WebSocket sessions and fan-out, and browsers handle reconnection and revision catch-up from their last seen revision.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, replayable revision queries, and reliable publication to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket session lifecycle, event subscriptions, and revision fan-out.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket connection management, reconnect backoff, and revision catch-up.

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
- **Self-hosted WebSockets for change delivery.** The server pushes committed event revisions to browsers over self-hosted WebSockets, paired with replayable revisions in the change store and client-side reconnect/catch-up logic. Chosen for low-latency updates without recurring realtime vendor fees or provider coupling, accepting the operational work of managing connection capacity and reconnect recovery. Five-second HTTPS polling was rejected for higher read load and multi-second lag; a hosted realtime service was rejected due to recurring vendor costs and provider coupling.
```

---

### Items for your review (Phase 1 stop)

1. **Decision doc vs. HLD entry:** Because this choice trades three credible options across multiple criteria (latency, vendor cost/coupling, operational burden) and shapes the three downstream nodes (`change-store`, `delivery`, `browser-sync`), a cold reader might re-litigate why we aren't using polling or a managed realtime provider. Would you like me to record a standalone decision doc at `docs/decisions/change-delivery.md` (linked from `Key Design Decisions`), or is the entry in `Key Design Decisions` above sufficient?
2. **Tenet check:** Your selection leans toward owning operational complexity (socket capacity, reconnect/replay) over recurring vendor coupling/cost. Would you like to capture that general lean as a tenet in `## Tenets` (for example: *Prefer self-hosted operational work over recurring vendor lock-in when core load is bounded*), or keep the existing tenet (*Self-hosted and managed infrastructure are both permitted*) as-is and treat this strictly as a point decision?
3. **Sibling note (`access`):** `docs/intent/access/access-design.md` line 10 currently says *"Authorization for HTTPS edit commands is independent of the still-open change-delivery approach."* Since that crosses into the `access` segment, should we also update that line to remove "still-open" once you approve the HLD, or leave `access` untouched for now?

Please let me know your thoughts on the updated HLD and these three questions before we move on to Phase 2 for the three nodes.