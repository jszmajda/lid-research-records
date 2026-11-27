Decision doc written at `docs/decisions/change-delivery-approach.md` and linked from the HLD's Key Design Decisions row. Full text for your review:

---

# Decision: Change delivery approach

## Context

MarketBoard keeps one authoritative, revisioned board per event: editors submit commands over HTTPS, each committed edit receives one event revision, and up to 800 simultaneous staff browsers must see committed changes within 15 seconds under normal connectivity. Three delivery mechanisms meet that freshness target — five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service — and the choice sizes the rest of the system. The change store must be shaped around whichever mechanism reads from it, the delivery node owns whatever runs between commit and browser, and browser sync owns recovery when a connection drops. Choosing wrong means either ongoing vendor spend and coupling in the delivery path, or operating connection infrastructure the project has never run.

## Decision Elements

No gate eliminates an option: all three mechanisms can meet the 15-second freshness goal, and the tenets permit both self-hosted and managed infrastructure, so neither direction is disqualified by policy. The selection rests on weighted criteria:

- **Independence from a realtime vendor (major).** Recurring fees, provider pricing changes, and provider coupling in the path between commit and browser vs. infrastructure the project controls outright.
- **Operating burden — connection and reconnect operations (major).** Who owns connection capacity, session lifecycle, and reconnect correctness at 800 browsers, including opening-time connect bursts.
- **Update speed for committed changes (moderate).** All options clear the 15-second goal; this criterion separates how far past it lands — seconds of lag behind a poll interval vs. push-on-commit.
- **Implementation complexity (moderate).** Stateless request handling vs. session state and replay vs. third-party SDK surface in server and browser.

## Options in the Domain

### Five-second HTTPS polling

**Description.** Browsers re-fetch the board (or changes since a cursor) every five seconds over ordinary HTTPS request/response. The change store exposes cursor queries over revision history; delivery is plain request/response with no persistent connection; each browser runs a polling loop. Nothing long-lived exists server-side between requests.

**Analysis.**

- Operating burden — major: **strong** — no connection capacity to provision or monitor; failures degrade to ordinary request retries; no session state between polls.
- Independence from a realtime vendor — major: **strong** — no realtime vendor is involved; runs on ordinary HTTPS infrastructure.
- Implementation complexity — moderate: **strong** — the simplest mechanism of the three; cursor queries and a client interval are the whole design.
- Update speed — moderate: **weak** — every change waits up to a full poll interval, and up to 800 browsers each re-read on every tick regardless of whether anything changed.

**Summary.** The simplest, most boring operation, paid for with seconds of lag and repeated reads.

### Self-hosted WebSockets

**Description.** The server holds a persistent WebSocket session per connected browser. The change store records every committed edit as a replayable revision; delivery publishes each revision to connected sessions as it commits; a browser whose socket drops reconnects and catches up from the last revision it received. The project owns the connection tier: capacity, session lifecycle, and reconnect correctness.

**Analysis.**

- Independence from a realtime vendor — major: **strong** — no realtime vendor bill, pricing, or coupling; the delivery path is entirely project infrastructure.
- Update speed — moderate: **strong** — push-on-commit puts changes in connected browsers essentially immediately, well inside the 15-second goal.
- Implementation complexity — moderate: **partial** — requires replayable revisions, reliable publication, and browser reconnect/catch-up, none of which polling needs.
- Operating burden — major: **weak** — the project owns connection capacity (including opening-time bursts), heartbeat and idle handling, and the reconnect/catch-up machinery that keeps dropped browsers correct.

**Summary.** Fast, vendor-independent updates in exchange for owning connection capacity and reconnect operations.

### Hosted realtime service

**Description.** A third-party realtime provider fronts delivery: the change store reconciles publication with the provider, the delivery node wraps the provider's API and credentials, and browsers subscribe through the provider's SDK and subscription model. Connection capacity and most connection failure handling are the provider's problem.

**Analysis.**

- Update speed — moderate: **strong** — managed pub/sub delivers low-latency updates and is the quickest route to them.
- Operating burden — major: **partial** — connection capacity and reconnect plumbing are largely outsourced, but publication reconciliation, provider credentials, and dependence on provider incidents remain.
- Implementation complexity — moderate: **partial** — delivery wraps a well-documented API, but the browser bundle takes a provider SDK and the store must reconcile its publication record with the provider's.
- Independence from a realtime vendor — major: **weak** — recurring fees scale with usage, and the delivery path couples to one provider's SDK, availability, and pricing.

**Summary.** The fewest connection operations, at the price of recurring fees and provider coupling.

## Selection

**Self-hosted WebSockets.** Against the criteria: strong on independence (the delivery path is project-owned) and on speed (push-on-commit), partial on complexity (replayable revisions, reliable publication, and reconnect/catch-up must be built), and weak on operating burden — the project owns connection capacity and reconnect operations at 800 browsers. Five-second polling was strong on operating burden and complexity but weak on speed: seconds of lag behind the interval, plus repeated reads from every browser. The hosted service was strong on speed and comparatively light on connection operations, but weak on independence: recurring fees, provider coupling, and a provider SDK in the browser.

The weighing favors the two criteria this project cares about most — vendor independence and fast updates — and consciously accepts the operating-burden cost, which is the criterion the chosen option scores worst on. It is taken within the tenet *self-hosted and managed infrastructure are both permitted*: hosted delivery remains a permitted direction if owning connections proves untenable at scale.

Committing obligates the downstream design nodes: the change store must expose replayable revisions and a durable publication record; delivery must own WebSocket session capacity and reliable publication to connected browsers; browser sync must own subscription, reconnect, and catch-up from the last received revision. It forecloses stateless request/response delivery and provider-managed connections as the primary path.

---

Still open from my last message:

1. **Approve the revised HLD** (Approach, Architecture bullets, and Key Design Decisions now linking this doc) — or give numbered amendments.
2. **Access cascade:** `docs/intent/access/access-design.md` still calls the delivery approach "still-open." Fix that phrase now, or leave it for a later pass?

Once both are settled, I'll start the three nodes.