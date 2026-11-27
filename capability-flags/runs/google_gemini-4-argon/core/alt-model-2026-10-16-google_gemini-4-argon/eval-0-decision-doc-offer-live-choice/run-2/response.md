I have updated `docs/high-level-design.md` to settle on self-hosted WebSockets and reflect the resulting responsibilities across `change-store`, `delivery`, and `browser-sync` as present intent.

### Updated `docs/high-level-design.md`

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets.

When an edit commits, the change store records a replayable event revision and publishes it to the delivery layer. Delivery manages WebSocket sessions for each event and pushes committed revisions to connected browsers. When a browser reconnects after a drop, it supplies its last known revision and catches up by replaying missed revisions—or loading a fresh snapshot if its gap exceeds the replay window—before resuming live updates.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative event revisions, replayable revision history, and reliable publication to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription authorization, revision fan-out, and replay handoff.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the WebSocket subscription lifecycle, connection-status visibility, reconnect backoff, and revision catch-up.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to browsers over self-hosted WebSocket sessions, backed by replayable revisions in the change store and client reconnect/catch-up logic. Five-second HTTPS polling was rejected because repeated reads across 800 browsers add steady query load and multi-second lag; a hosted realtime service was rejected to avoid recurring vendor fees and provider coupling, accepting in-house connection capacity and reconnect management in exchange for low-latency updates without external lock-in.
```

---

### Before we proceed to Phase 2 (the three LLDs), please review:

1. **Decision doc vs. HLD entry:** Because the change-delivery choice weighs three credible options across multiple criteria (latency, operational burden, vendor lock-in/recurring cost) and shapes all three downstream nodes (`change-store`, `delivery`, `browser-sync`), a cold reader might re-litigate why polling or a hosted service wasn't used. Would you like to record this in a standalone decision doc at `docs/decisions/change-delivery.md` (linked from `Key Design Decisions`), or is the `Key Design Decisions` entry in the HLD sufficient?
2. **Tenet check:** Your selection surfaced a clear project-level lean that resolved the tie between self-hosted WebSockets, polling, and a hosted service:
   - *Own core operational mechanics over third-party runtime dependencies when both meet the target.* (Opposite: *Prefer managed third-party services over operating stateful infrastructure in-house.*)
   
   Notice also that the existing fourth bullet under `## Tenets` (*"Self-hosted and managed infrastructure are both permitted..."*) is a permission statement rather than a directional tie-breaker. Would you like to adopt the operational-ownership lean (or a variant) in `## Tenets`, or keep the tenets as they are?
3. **Note on `access-design.md`:** `docs/intent/access/access-design.md` currently notes in `## Context` that *"Authorization for HTTPS edit commands is independent of the still-open change-delivery approach."* Since that sits in the `access` segment, I have not touched it yet—when we move past the HLD, let me know if you want to clean up the `"still-open"` phrasing there as well.

Does this HLD update look good to approve, and which of the three nodes (`change-store`, `delivery`, or `browser-sync`) would you like to draft first in Phase 2?