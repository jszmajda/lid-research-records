I have updated `docs/high-level-design.md` to establish self-hosted WebSockets as the change-delivery approach, align the three pending component responsibilities, and record the choice and rejected alternatives under `Key Design Decisions`.

### Updated `docs/high-level-design.md`

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed updates over self-hosted WebSockets.

Change storage, session delivery, and browser recovery work together around the authoritative revision stream. The change store records replayable event revisions and publishes committed changes reliably to delivery; the delivery component manages WebSocket sessions and streams revisions to subscribed browsers; browsers maintain socket connections, surface connectivity loss visibly, and catch up on missed revisions after reconnecting.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative event revisions, replayable revision history, and reliable publication to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription credentials, and streaming committed revisions to browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser WebSocket lifecycle, visible connectivity state, and reconnect catch-up.

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
- **Self-hosted WebSockets for change delivery.** Committed event revisions stream to connected browsers over server-managed WebSocket sessions, backed by replayable revisions and reliable publication in the change store and reconnect catch-up in the browser. Five-second HTTPS polling was rejected despite simpler stateless operation because it adds multi-second lag and repeated read load across up to 800 simultaneous browsers. A hosted realtime service was rejected to avoid recurring vendor fees and coupling board delivery to a third-party provider, accepting ownership of socket capacity and reconnect handling.
```

---

### Phase 1 review items before moving to the three LLDs

1. **Decision doc vs. HLD entry**: Because all three delivery options satisfy the 15-second freshness goal and existing tenets—trading latency, read load, connection ops, and vendor coupling while sizing `change-store`, `delivery`, and `browser-sync` around the outcome—a cold reader could reasonably re-litigate this choice. Would you like to record it as a full decision doc at `docs/decisions/change-delivery-approach.md` (linked from `Key Design Decisions`), or keep just the `Key Design Decisions` entry above?
2. **Tenet check**: Does your preference here generalize into a project-wide tenet—e.g., *"Prefer owning standard, portable protocols over coupling core paths to proprietary vendor services, even when we take on extra operational work"*—or was avoiding vendor coupling specific to realtime delivery while managed services remain equally welcome elsewhere (as the fourth tenet currently states)? Any other tenets you want to add or adjust before we design the three nodes?
3. **Cross-segment wording cascade (`ACCESS`)**: `docs/intent/access/access-design.md` still says *"Authorization for HTTPS edit commands is independent of the still-open change-delivery approach."* Access's behavior and specs are unaffected, so I paused at the segment boundary—should I update that sentence to say *"self-hosted WebSocket change delivery"*?
4. **HLD approval & Phase 2 order**: If the updated HLD looks good (with any edits from 1–3), confirm approval to proceed to Phase 2 and let me know which node you'd like to draft first (`change-store` → `delivery` → `browser-sync` follows the data flow).