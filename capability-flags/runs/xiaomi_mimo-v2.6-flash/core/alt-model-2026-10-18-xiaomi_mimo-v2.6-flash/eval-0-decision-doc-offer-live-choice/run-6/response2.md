The decision doc is written at `docs/decisions/self-hosted-websockets-delivery.md` and linked from the HLD's Key Design Decisions. Here it is in full:

```markdown
# Decision: Self-hosted WebSockets for change delivery

## Context

Committed edits each carry one server-assigned event revision, and up to 800
simultaneous staff browsers must show those revisions within fifteen seconds of
commit. Three delivery mechanisms meet that freshness target — five-second HTTPS
polling, self-hosted WebSockets, and a hosted realtime service — so freshness
alone does not separate them. The choice is load-bearing beyond delivery itself:
it fixes whether the change store keeps replayable revision history, whether
delivery owns socket sessions or a provider integration, and whether browsers
implement reconnect and catch-up or a polling loop. It is settled before the
change-store, delivery, and browser-sync nodes are designed.

## Decision Elements

No gate eliminates an option: all three meet the fifteen-second freshness target
and the tenet "Self-hosted and managed infrastructure are both permitted" keeps
both self-hosted and vendor-hosted options admissible. The decision turns on
these weighted criteria:

- **Update timeliness (major).** How promptly a committed revision appears in
  connected browsers, and what the client and store must do to achieve it.
- **Vendor independence (major).** Whether the delivery path incurs recurring
  fees or binds the board to a third party's subscription semantics and
  availability.
- **Operational burden (moderate).** What the project must run and recover:
  connection capacity, session state, reconnect handling, or only stateless
  request handling.

Tenet engagement: "Self-hosted and managed infrastructure are both permitted"
enters through vendor independence — vendor use is weighed against the other
criteria, not forbidden. "Connectivity failures must be visible, not mistaken
for an unchanged board" constrains whichever recovery mechanism the selection
obligates downstream.

## Options in the Domain

### Five-second HTTPS polling

**Description.** Browsers re-fetch board state, or changes since a revision
cursor, over ordinary HTTPS every five seconds. The server answers each request
and keeps no per-browser connection state; the change store serves cursor
queries ("what changed since revision N"). Every browser runs its own polling
loop; delivery is plain request/response.

**Analysis.**

- Update timeliness — **weak**: a committed revision is visible only when the
  next poll lands, averaging a few seconds of lag and worst-case nearly five
  seconds. Inside the fifteen-second goal, but the slowest of the three, and
  subsecond delivery is unreachable.
- Vendor independence — **strong**: no realtime vendor; delivery is ordinary
  HTTPS serving the project already runs.
- Operational burden — **strong**: the simplest stateless operation — no
  connection capacity to own and no server-side sessions to reconnect. The cost
  appears as repeated reads against the store and a polling loop running in
  every browser.

**Summary.** Simplest to operate and vendor-free, at the price of update lag
and multiplied reads.

### Self-hosted WebSockets

**Description.** The project runs a WebSocket endpoint and holds one socket per
connected browser. Each committed revision is published on the sockets as it
lands. The change store keeps replayable revision history so delivery can serve
catch-up after a drop, and browsers reconnect and catch up from a revision
cursor.

**Analysis.**

- Update timeliness — **strong**: revisions push to connected browsers
  immediately on commit; subsecond-capable, though subsecond is not required.
- Vendor independence — **strong**: no realtime vendor bill and no provider
  coupling; the delivery stack is the project's own code on the project's own
  infrastructure.
- Operational burden — **weak**: the project owns connection capacity for up to
  800 browsers, server-side session handling, and the reconnect and catch-up
  problems on both ends.

**Summary.** Fast, vendor-free delivery paid for with connection and reconnect
operations the project runs itself.

### Hosted realtime service

**Description.** A third-party realtime provider fronts the subscription
channel: the server publishes committed revisions to the provider, and browsers
subscribe through the provider's client model. The change store reconciles
publication with the provider so committed revisions are not lost between the
two; delivery wraps the provider's API and credentials; browsers follow the
provider's subscription and recovery semantics.

**Analysis.**

- Update timeliness — **strong**: the provider's infrastructure delivers the
  quickest low-latency path with little connection work of our own.
- Vendor independence — **weak**: recurring fees, provider coupling, and
  delivery behavior bound to the provider's subscription semantics and
  availability.
- Operational burden — **partial**: less direct connection capacity and fewer
  reconnect problems to own, offset by credentials, publication reconciliation,
  and dependence on the provider's outage behavior.

**Summary.** Fastest updates with the least connection operations, bought with
recurring fees and provider coupling.

## Selection

Self-hosted WebSockets. It is strong on both major criteria — immediate push
timeliness and vendor independence — and its weakness on operational burden
(moderate) is the explicitly accepted cost of the trade: the project takes on
connection capacity for 800 browsers and the reconnect and catch-up work.
Polling wins operational burden but is weak on the major timeliness criterion —
repeated reads, seconds of lag, and a polling loop in every browser. The hosted
service matches timeliness but is weak on the major vendor-independence
criterion; the tenet permitting managed infrastructure keeps it admissible, but
weighed against fees and coupling it does not win.

Committing obligates the downstream nodes: the change store keeps replayable
revision history, delivery owns socket sessions and reliable publication of
committed revisions, and browsers implement reconnect and catch-up that surfaces
connectivity state rather than presenting a stale board as current (tenet:
connectivity failures must be visible). It forecloses stateless request/response
delivery and provider-managed subscriptions as the delivery path.
```

Still open from my last message — I won't move on to the three nodes until you rule on both:

1. **HLD approval** — the updated `docs/high-level-design.md` I posted last time (Approach, Architecture bullets, and the new Key Design Decisions entry). Numbered feedback, or "approved".
2. **Access segment fix** — `docs/intent/access/access-design.md` still says authorization is independent of "the still-open change-delivery approach." Harmless substance, stale wording. Fix the phrase as part of this approval, or leave access untouched?