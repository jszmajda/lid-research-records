Updated `docs/high-level-design.md` for self-hosted WebSockets. Here is the updated HLD for Phase 1 review:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS, which commit sequential event revisions to the change store. Committed changes are pushed to connected staff browsers over self-hosted WebSockets, with revision-based replay for reconnect catch-up.

This places three coordinated responsibilities across the downstream components: the change store persists replayable event revisions and supports reliable publication; delivery manages WebSocket sessions and fan-out; and browser sync handles connection lifecycle, reconnects, and revision catch-up.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Authorizes HTTPS edit commands against current event assignments.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative event revisions, replayable revision history, and reliable publication to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection capacity, event fan-out, and subscription authorization.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket connection management, visible connectivity state, reconnects, and revision-based catch-up.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed over self-hosted WebSockets rather than five-second HTTPS polling or a hosted realtime service. Self-hosted WebSockets deliver fast updates without recurring realtime vendor fees or provider coupling, in exchange for owning connection capacity, replayable revision storage, reliable publication, and browser reconnect/catch-up logic. Five-second polling was rejected for its update lag and repeated read load despite simpler stateless operation; a hosted realtime service was rejected for recurring vendor costs and provider coupling despite lower connection-management overhead.
```

### Before we move on to the three downstream nodes

1. **Decision doc offer:** Because all three delivery options satisfy the 15-second freshness goal with genuine trade-offs across latency, operational burden, and vendor coupling—and three nodes (`change-store`, `delivery`, `browser-sync`) are about to be sized around this choice—a cold reader may question why MarketBoard took on self-hosted WebSocket operations. Would you like to record this as a full decision doc at `docs/decisions/change-delivery.md` (linked from `## Key Design Decisions`), or is the `## Key Design Decisions` entry in the HLD sufficient?
2. **Stale reference in `access`:** `docs/intent/access/access-design.md` (line 10) still mentions "the still-open change-delivery approach." Should I update that line to reflect the settled delivery approach, or leave `access` untouched for now?
3. **HLD approval:** Any edits to the updated HLD (including whether the current tenets still reflect how you want to lean on vendor independence vs. operational overhead), or is Phase 1 approved?