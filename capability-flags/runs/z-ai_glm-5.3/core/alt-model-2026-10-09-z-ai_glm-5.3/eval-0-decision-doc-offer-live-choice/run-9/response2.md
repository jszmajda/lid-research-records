The decision doc is written and linked from the HLD's Key Design Decisions entry. Here it is in full for your review:

---

---
`node: high-level-design`
---

# Decision: Self-Hosted WebSocket Change Delivery

## Context

MarketBoard boards change constantly during event hours: a busy market averages two status changes per minute with opening-time bursts around 20 edits per second, and up to 800 staff browsers watch each board. Commands arrive over HTTPS and every committed edit becomes one authoritative event revision. This decision concerns only how committed revisions reach connected browsers; the command path is unaffected.

Any delivery route must respect the same invariants: committed changes must appear in connected browsers within 15 seconds under normal connectivity, a browser disconnected for up to 20 minutes must be able to recover the latest board, and event revisions are retained for seven days. All three options in this space meet those invariants, so they are background, not differentiators. What differs is where the operational burden lands, how fast updates arrive, what the store must support, and whether a third party enters the delivery path.

Three options exist in this space: periodic HTTPS polling, WebSocket connections hosted by the service itself, and a hosted realtime (push) service wrapped by the application. This doc records why the project delivers over self-hosted WebSockets.

## Decision Elements

No option is eliminated on a binary constraint; the choice trades graded criteria.

- **Vendor independence in the delivery path (major).** Whether the route from committed revision to browser can operate without a third-party provider in it. The project's stated lean: fast updates without tying the board to a realtime vendor.
- **Recurring cost (major).** Whether the route adds a fee that scales with usage, versus running on infrastructure the service already operates.
- **Operational burden owned in-house (major).** How much connection management, reconnect, and capacity work the project must design, run, and debug itself.
- **Latency headroom (moderate).** How far below the 15-second requirement updates land. The requirement is 15 seconds; headroom beyond it is desirable, not required.
- **Change-store obligations (moderate).** What the store must provide for the route to work: cursor queries, replayable revisions with reliable publication, or publication reconciliation.
- **Burst and reconnect-storm behavior (moderate).** Behavior at opening time — 20 edits per second fanned to up to 800 browsers — and when many browsers reconnect at once after a connectivity blip.
- **Standing read load (minor).** Load imposed on the store while nothing changes.
- **Third-party data exposure (minor).** What the route shares beyond the service. Event updates carry stall IDs and operational statuses, never customer records (HLD tenet), which keeps the stakes of this criterion low regardless of route.

## Options in the Domain

### Five-second HTTPS polling

**Description.** Browsers re-fetch changes over ordinary request/response HTTPS on a five-second timer. The store serves cursor queries ("everything for event E after revision N"); delivery is stateless — no sessions, no connections, no fan-out machinery. A browser that was offline simply polls on return and receives everything it missed; recovery needs no dedicated mechanism.

**Analysis.**
- Vendor independence: **strong** — plain HTTPS, no third party.
- Recurring cost: **strong** — no incremental fees; runs on the existing web tier.
- Operational burden: **strong** — stateless request/response; nothing to reconnect or supervise.
- Latency headroom: **weak** — every change waits out the interval, up to five seconds; a poll that returns nothing still costs a store read and a round trip.
- Change-store obligations: **partial** — cursor queries are the simplest of the three store mechanisms.
- Burst and reconnect-storm behavior: **strong** — a poll naturally coalesces a burst into one response; a reconnecting browser is just a poll.
- Standing read load: **weak** — load scales with browsers × poll rate regardless of change activity; 800 browsers at five seconds is ~160 reads/second sustained through event hours, most returning nothing.
- Third-party data exposure: **strong** — nothing leaves the service.

**Summary.** The simplest route to operate, paying for it with a few seconds of lag on every change and a read load that tracks connection count rather than edit rate.

### Self-hosted WebSocket delivery

**Description.** The service hosts its own WebSocket endpoint. Browsers subscribe per event; committed revisions are published by the change store and fanned out to connected sessions. A reconnecting browser resumes from its last seen revision and catches up by replaying the store's revision history. Connection capacity, session lifecycle, and reconnect handling are owned by the project's delivery and browser-sync components.

**Analysis.**
- Vendor independence: **strong** — the delivery path is entirely the project's own.
- Recurring cost: **strong** — no vendor bill; runs on the service's own infrastructure.
- Operational burden: **weak** — the project owns connection capacity, session management, reconnect behavior, and their failure modes.
- Latency headroom: **strong** — push delivery lands changes in connected browsers as fast as the network allows.
- Change-store obligations: **partial** — replayable revision history plus reliable publication is more store machinery than cursor queries, but the seven-day revision retention goal already requires the history itself.
- Burst and reconnect-storm behavior: **partial** — opening bursts fan roughly 20 revisions per second to up to 800 sessions (~16,000 messages/second), and a connectivity blip reunites hundreds of browsers at once; both must be designed for.
- Standing read load: **strong** — the store is read per revision, not per browser per interval.
- Third-party data exposure: **strong** — nothing leaves the service.

**Summary.** Fast, vendor-free push delivery, bought by taking connection operations in-house.

### Hosted realtime service

**Description.** A managed realtime provider (the Pusher/Ably family) owns the socket layer: the application publishes committed revisions to the provider, browsers subscribe through the provider's client SDK, and the provider's infrastructure absorbs connection capacity, fan-out, and reconnect storms. The application wraps publication in reconciliation — retrying or verifying delivery after publish failures — and holds provider credentials.

**Analysis.**
- Vendor independence: **weak** — a third party sits inside the delivery path; migrating later means re-implementing sessions and catch-up against whichever option replaces it.
- Recurring cost: **weak** — fees recur and scale with message volume and peak connections, that is, with exactly the opening-time bursts the board exists for.
- Operational burden: **strong** on connections — the provider engineers capacity and reconnect storms; **partial** overall — publication reconciliation and credentials remain the project's.
- Latency headroom: **strong** — push delivery at provider-grade latency.
- Change-store obligations: **partial** — publication reconciliation is comparable in weight to reliable publication; the store still needs revision history for the seven-day retention goal.
- Burst and reconnect-storm behavior: **strong** — absorbing reconnect storms is the provider's core product.
- Standing read load: **strong** — push delivery, no interval reads.
- Third-party data exposure: **partial** — operational statuses (stall IDs, states) flow through the provider; customer records never do (tenet), which is why this criterion carries minor importance.

**Summary.** The quickest route to low-latency push with the least connection work, at the price of recurring fees and a provider inside the delivery path.

## Selection

**Chosen: self-hosted WebSocket delivery.**

The decision turns on which burdens the project prefers to own. Vendor independence and recurring cost (both major) put hosted delivery behind the other two: a provider inside the delivery path, and fees that scale with the board's busiest moments. Between polling and WebSockets, polling matches the vendor independence and cost profile but forgoes the latency headroom and pays a standing read load that scales with browsers rather than edits. Self-hosted WebSockets score weakest on the one criterion they lose outright — operational burden owned in-house (major) — and the project takes that burden on deliberately: connection capacity, session management, and reconnect handling become designable, bounded work because the scale is finite and known (up to 800 simultaneous browsers, ~20 edits per second at opening), and the store's seven-day revision retention already requires the history that catch-up replay consumes.

The choice stays within the HLD tenet that self-hosted and managed infrastructure are both permitted — it is a lean for this path, not a ban on managed delivery. The tenet that event updates carry stall IDs and operational statuses, never customer records, is what keeps third-party exposure a minor criterion; it was weighed and did not overcome vendor independence.

**What this obligates.** The change store must publish committed revisions reliably and keep them replayable; the delivery node must own WebSocket sessions, fan-out, and burst/reconnect capacity; browser sync must own reconnect and revision catch-up.

**What this forecloses.** Provider-managed connection scaling for the pilot. The decision does not lock the architecture: every delivery route sits behind a single authoritative revision stream (HLD tenet), the scale is bounded, and managed infrastructure remains permitted — if connection operations become a sustained burden, re-running this judgment with a different selection remains open.

---

Two questions from the Phase 1 stop are still open:

1. **Tenet candidate.** Add *"The change store is the source of truth for recovery; delivery connections are transport, not storage"* to the HLD tenets? It would lean "no" if the delivery node is later tempted to buffer missed revisions per offline browser in socket-layer state.

2. **Node order.** Once Phase 1 closes, which node do we draft first — change store (my suggestion, since delivery and browser sync consume its revisions), delivery, or browser-sync?