**Decision doc written** at `docs/decisions/change-delivery-approach.md`, linked from the HLD's Key Design Decisions entry. Full text:

---

# Decision: Change Delivery Approach

## Context

Committed board revisions must reach staff browsers while a market is live. About 800 browsers can be connected at once, a busy market averages two status changes per minute with bursts around opening time, and the freshness goal is to show committed changes within 15 seconds under normal connectivity. The delivery mechanism shapes the change store (how revisions are read and replayed), delivery itself (what runs between store and browser), and browser sync (how a browser recovers after a gap). Choosing one mechanism sizes those three nodes, so the choice is made once, here, rather than inside each node.

## Decision Elements

**Gates**

- *Meet the 15-second freshness goal under normal connectivity.* Every option in contention meets it; the goal bounds the option set rather than eliminating an option.

**Weighted criteria**

- *Freedom from realtime vendor fees and provider coupling* (major). Delivery is a core path of the board; committing it to a third-party service means recurring cost scaled to market traffic and a dependency on that provider's availability, pricing, and API. The tenet "Self-hosted and managed infrastructure are both permitted" keeps hosted options in the option set rather than excluding them; it does not settle how much coupling is acceptable.
- *Connection and recovery operations we own* (moderate). Server-side connection capacity, disconnect detection, reconnect handling, and publication reliability are operations work: monitoring, load, and failure modes the team runs itself. This criterion trades directly against vendor freedom.
- *Update latency for committed changes* (moderate). All options meet the 15-second goal; this criterion measures how much margin they leave. Subsecond delivery is useful but not required.
- *Repeated read load on the delivery path* (minor). A mechanism that re-reads state on a timer multiplies read traffic by browser count and edit frequency, independent of how many changes actually occur.

## Options in the Domain

### Five-second HTTPS polling

Browsers re-request the board (or changes since a cursor) on a fixed timer; the store answers cursor queries; delivery stays plain request/response with no persistent channel. Statelessness is the appeal: no sessions to hold, no publication path to get right — each request is independent and retry is free by construction.

- Vendor freedom: **strong** — no third-party service anywhere in the path.
- Connection and recovery operations we own: **strong** — there are no long-lived connections to capacity-plan or reconnect; a failed request is just the next timer tick.
- Update latency: **weak** — changes surface on the next tick, so typical lag is seconds, using up a large share of the 15-second budget as routine margin rather than headroom.
- Repeated read load: **weak** — every browser re-reads whether or not anything changed; 800 browsers polling every five seconds is sustained read traffic sized by browser count, not by the two-edits-per-minute baseline.

Summary: the simplest server to operate, paid for in constant read traffic and seconds of standing lag.

### Self-hosted WebSockets

A persistent socket per connected browser. The store keeps a replayable revision history, delivery publishes each committed revision to open sessions and owns connection capacity and disconnect detection, and the browser reconnects and catches up from the last revision it saw.

- Vendor freedom: **strong** — no third-party service; the channel is ours.
- Connection and recovery operations we own: **weak** — 800 concurrent connections, capacity planning, disconnect detection, reconnect storms, and reliable publication are all ours to build and run.
- Update latency: **strong** — committed revisions push immediately; lag is network time, well inside the goal.
- Repeated read load: **strong** — traffic is proportional to actual changes plus connection keep-alive, not to browser count on a timer.

Summary: fast updates and no vendor, purchased with the connection and reconnect operations work.

### Hosted realtime service

A provider's infrastructure carries the channel: the server publishes committed revisions to the provider, browsers subscribe through the provider's client, and the store reconciles publication with the provider's delivery guarantees.

- Vendor freedom: **weak** — recurring fees scale with market traffic, and the delivery path inherits the provider's availability, pricing, and API decisions.
- Connection and recovery operations we own: **strong** — the provider owns connection capacity; reconnect and catch-up follow its subscription model rather than code we write.
- Update latency: **strong** — built for low-latency push, same class as self-hosted sockets.
- Repeated read load: **strong** — event-driven like sockets; no timer-driven re-reads.

Summary: the least operations work for fast updates, at the price of fees and coupling on a core path.

## Selection

**Self-hosted WebSockets.**

Vendor freedom (major) eliminates the hosted service: a recurring fee and provider coupling on the board's core delivery path is the one cost the project declines to take, and the tenet that permits managed infrastructure does not require it. Between the two survivors, the decision turns on the accepted trade: connection and recovery operations (moderate) against update latency and read load (moderate and minor). Polling is cheaper to run but weaker on both delivery-quality criteria; sockets buy immediate push and change-proportional traffic with operations work the team has decided to own. The work is bounded and legible — connection capacity, disconnect handling, replayable revisions — versus vendor coupling, which is not ours to bound.

Committing here obligates downstream: the change store must offer replay from any revision a browser last saw and publish reliably; delivery must own session capacity and reconnect at the socket boundary; browser sync must reconnect and catch up without mistaking a dropped connection for an unchanged board. It forecloses the hosted path without an exit story and makes polling unavailable as a fallback without re-opening this decision.

---

**Before I move on:**

1. Review the decision doc above — numbered feedback, or approve as-is.
2. Still unanswered from the last stop: update the stale phrase in `docs/intent/access/access-design.md` ("independent of the still-open change-delivery approach")? That's a one-line edit inside another segment, so I'm waiting on your confirmation.
3. Approve to proceed to Phase 2: drafting the three nodes (change-store, delivery, browser-sync), one LLD at a time with a stop after each?