Done — Phase 1 (HLD) is updated, and I'm stopping before the three nodes, as you asked.

**Pre-flight (new session resuming this change):** HLD, the `access` LLD, and its specs were mutually coherent; no code or tests exist yet; working tree clean. No drift to fix before starting.

I committed the approach to self-hosted WebSockets in `docs/high-level-design.md`, written context-free: dropped the "still open / designed after this choice" deliberation language, named the chosen mechanism and its consequences, updated the Architecture list's one-line descriptions of the three deferred nodes, and recorded the choice with alternatives + rationale in Key Design Decisions. I did **not** write the three nodes, nor touch the `access` segment (see cascade note). Here is the full updated HLD for your review:

```
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over self-hosted WebSocket connections: the server holds a session per connected browser and pushes each committed event revision as it is published, so connected browsers receive changes without waiting for a poll. The board stays independent of any realtime vendor, and fast, low-latency updates are worth the connection capacity and reconnect handling this mechanism requires.

Change storage, delivery, and browser recovery are designed together around this mechanism. The change store keeps replayable revisions and a reliable publication outbox; delivery manages socket sessions and publication; browser sync owns subscription, reconnect, and catch-up so a returning browser recovers the latest board. The binding freshness target is showing committed changes within 15 seconds; subsecond updates are useful but not required.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, read indexes, replayable revisions, and a reliable publication outbox feeding delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket session management and publication of committed revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the socket subscription, reconnect, and catch-up that recover the latest board after a disconnect.

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
- **Committed changes are delivered over self-hosted WebSockets.** Three approaches all met the 15-second freshness target: five-second HTTPS polling (simplest stateless operation, but repeated reads and a few seconds of lag), self-hosted WebSockets (fast updates, but we own connection capacity and reconnect handling), and a hosted realtime service (low-latency with fewer connection operations, but recurring fees and provider coupling). Self-hosted WebSockets was chosen to get fast updates without coupling the board to a realtime vendor, accepting the connection and reconnect operations work. Polling was not chosen because of its lag; the hosted service was not chosen because of recurring fees and provider coupling.
```

This is the **Phase 1 STOP**. Before proceeding to the three nodes, I need your judgment on these — I won't settle them for you:

1. **Decision doc (offered once).** You settled a choice among three sketched options, traded against several credible criteria (latency, operational burden, vendor coupling, cost), with three design nodes about to be sized around the result — so it clears the bar for a full decision doc. I have **not** written one; I recorded the choice as a Key Design Decisions entry (the minimal record that lands in the HLD either way). Should I write the full decision doc — `docs/decisions/<name>.md`, with Context, Decision Elements (gates + weighted criteria), per-option analysis, and Selection, linked from that entry — or should the Key Design Decisions entry stand as the only record? The doc gets written only if you accept.

2. **Cascade pause (cross-boundary).** An HLD change fans out to every segment. You've deferred `change-store`, `delivery`, and `browser-sync`; I've left them untouched. The `access` segment is separate and already written, and `docs/intent/access/access-design.md:10` still calls the change-delivery approach "still open." Cascading across a segment boundary needs your confirmation: should I update that line now, or leave `access` for its own pass? (Its specs carry no approach reference.)

3. **Tenet elicitation.** The tenet "Self-hosted and managed infrastructure are both permitted" now reads as leftover from when the choice was open, and your decision leans toward low latency and no vendor coupling over minimal ops burden. Tenets are elicited, not assumed, so I've left them unchanged. Want me to add/adjust a one-line tenet for that lean, or leave the tenets as-is and let the Key Design Decisions entry carry the rationale? I'd also welcome any other load-bearing tenets you want recorded.

Give me your review (numbered feedback welcome) and your calls on 1–3; on your explicit approval I'll move on to the three nodes.