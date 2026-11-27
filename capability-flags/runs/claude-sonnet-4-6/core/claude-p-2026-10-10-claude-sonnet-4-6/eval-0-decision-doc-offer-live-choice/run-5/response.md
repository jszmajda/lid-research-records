Here is the updated HLD for review:

---

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; committed changes are pushed to browsers over self-hosted WebSockets. Subsecond updates would be useful, but are not required; the freshness goal is 15 seconds under normal connectivity.

Delivery, change storage, and browser recovery are designed together around this choice. The change store holds replayable revisions and a publication outbox so the delivery layer can fan out to socket sessions. The delivery layer manages connection capacity, session lifecycle, and reliable fan-out. The browser holds a WebSocket connection, reconnects on drop, and replays from the last revision it holds to catch up.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: not written yet. Owns revision history, read indexes, and a publication outbox that delivery drains to fan out to socket sessions.
- Delivery: not written yet. Owns self-hosted WebSocket session management, fan-out from the publication outbox, and reconnect handling.
- Browser sync: not written yet. Owns the WebSocket subscription loop, reconnect on drop, and catch-up replay from the last held revision.

## Tenets

*(unchanged — all four still hold)*

## Goals / Non-Goals

*(unchanged)*

## Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** *(existing)*

- **Self-hosted WebSockets for delivery.** Committed changes are pushed to browsers over WebSocket connections managed on the project's own infrastructure. Five-second HTTPS polling was rejected because it introduces several seconds of lag and generates repeated reads at scale; a hosted realtime service was rejected to avoid recurring per-message fees and provider coupling. Self-hosted WebSockets deliver subsecond fan-out at the cost of owning connection capacity and reconnect logic — a tradeoff judged acceptable given the 800-browser scale and the preference to keep infrastructure dependencies within the project's control.

---

**One question before we move to the nodes:** the delivery approach choice is one a cold reader would question (a hosted service is a credible alternative and the tradeoffs are real). It earns a decision doc by the earns-its-place test. Do you want to record it as a standalone decision doc in `docs/decisions/`, or is the Key Design Decisions row above sufficient?