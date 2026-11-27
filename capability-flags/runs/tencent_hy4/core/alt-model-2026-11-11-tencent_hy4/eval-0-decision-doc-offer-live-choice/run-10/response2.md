Written and linked: `docs/decisions/change-delivery-transport.md` (project-level decision, owned by the HLD), with a link added to its Key Design Decisions entry. It reads cold — present tense, no chronology, each option at its strongest, and the C1-vs-C4 tension spelled out so a newcomer can see exactly why the ops cost was taken on.

```markdown
# Decision: Change-delivery transport

## Context

MarketBoard keeps one authoritative board per event: editors submit commands over HTTPS, and the server assigns each committed edit a single event revision (see the HLD's "Commands over HTTPS, one authoritative board per event" decision). Up to 800 staff browsers display a revisioned view of that board. This decision fixes the transport that carries committed revisions from the server to those browsers.

The transport is a project-level choice because it determines what three components must provide: the change store's read and publication shape, the delivery component's runtime, and the browser's recovery behavior. It also sets the board's operating cost and dependency profile. Every candidate transport can meet the 15-second freshness goal (subsecond updates are useful but not required), serve 800 browsers, and recover a browser disconnected for up to 20 minutes. No candidate is eliminated by a standing tenet or hard goal — the standing tenets (one authoritative revision regardless of delivery route; connectivity failures visible, not mistaken for an unchanged board; server-side command authorization; both self-hosted and managed infrastructure permitted) and the hard goals are satisfiable by all three. The choice therefore rests on weighted criteria, not on a gate.

## Decision Elements

- **C1 — Vendor independence and recurring cost** (major). Avoid a recurring realtime-vendor fee and coupling to a hosted provider's SDK, subscription model, and availability. Board updates contain stall IDs and operational statuses, not customer records, so data sensitivity is not a gating concern.
- **C2 — Update freshness** (moderate). How promptly a committed change appears, with headroom under the 15-second goal. Derived from the freshness goal; subsecond delivery is not required.
- **C3 — Read and capacity efficiency at scale** (moderate). Cost of serving 800 simultaneous browsers and opening-time bursts of 20 edits per second without repeated full reads.
- **C4 — Connection operations the team owns** (major). Who runs connection capacity, session lifecycle, reconnect storms, reliable publication, and the on-call and engineering work to build and operate them.
- **C5 — Ease of guaranteeing visible connectivity failures and gap-free catch-up** (moderate). Importance derives from the tenet "Connectivity failures must be visible, not mistaken for an unchanged board" and the goal of recovering the latest board after up to 20 minutes disconnected.

## Options in the Domain

### Five-second HTTPS polling

Browsers issue an HTTPS read every five seconds and supply a cursor; the server returns the committed revisions since that cursor. Delivery stays stateless request/response — no persistent connection and no server-side session. The change store needs cursor queries ordered by revision; browsers run a polling loop. Described as its advocate would: it is the simplest thing that works, with no connection tier to operate, no reconnect protocol, and recovery that is just "ask again from your cursor"; a five-second interval comfortably meets the 15-second goal.

- **C1**: strong — no third-party realtime dependency or vendor fee; capacity cost is ordinary HTTPS read traffic.
- **C2**: partial — changes appear within one poll interval (up to five seconds); meets the goal with lag.
- **C3**: weak — 800 browsers polling every five seconds is roughly 160 reads per second whether or not anything changed; bursts load the read path.
- **C4**: strong — stateless request/response; no connection capacity, reconnect, or session state to run.
- **C5**: strong — a failed poll is a visible HTTP error, and recovery is a cursor query from the last seen revision.

*Simplest to operate, at the cost of repeated reads and a few seconds of lag.*

### Hosted realtime service

A managed provider carries committed changes to subscribed browsers over its own connection infrastructure. The server publishes each revision to the provider; browsers use the provider's subscription SDK. The change store needs publication reconciliation to confirm what the provider accepted; delivery wraps the provider; browsers adopt its subscription model. Described as its advocate would: it is the quickest route to low-latency updates — the provider runs the connection tier, reconnects, and fan-out, so the team ships push updates with the least new infrastructure.

- **C1**: weak — recurring fees and coupling to the provider's SDK, subscription model, and availability.
- **C2**: strong — pushes arrive immediately.
- **C3**: partial — the provider handles fan-out, but cost scales with connections and messages at 800 browsers.
- **C4**: strong — connection capacity, reconnects, and reliability are the provider's responsibility.
- **C5**: partial — the provider surfaces disconnects and offers replay, but the visibility and recovery semantics are the provider's, not the board's.

*Fastest path to low-latency push with minimal connection ops, in exchange for recurring fees and provider coupling.*

### Self-hosted WebSockets

The server holds a WebSocket connection to each browser and pushes each committed revision as it is stored. The change store records revisions in replayable order and publishes them reliably; delivery manages socket sessions and fans out published revisions; browsers reconnect and catch up from their last revision after an interruption. Described as its advocate would: fast updates with no vendor bill — the board keeps control of its delivery path and data, and one persistent connection per browser costs less than repeated polling reads.

- **C1**: strong — no recurring vendor fee, no provider SDK or subscription model, and no third party receiving board data.
- **C2**: strong — pushes arrive immediately.
- **C3**: strong — one persistent connection per browser; traffic is proportional to changes, not to browser count times poll interval.
- **C4**: weak — the team owns connection capacity for 800 sockets, reconnect storms at opening time, session lifecycle, reliable publication, and catch-up; this is real engineering and on-call work.
- **C5**: partial — visibility and catch-up must be built (replayable revisions plus a last-seen-revision handshake), and a dropped socket must be surfaced rather than read as a quiet board.

*Fast, vendor-independent push, with connection operations and reconnect/catch-up owned in-house.*

## Selection

Self-hosted WebSockets. The decisive weight is C1 (major): the board accepts connection and reconnect operations rather than a recurring realtime-vendor fee and coupling to a hosted provider. C4 (major) is the cost the decision accepts — it is real, it falls on the team, and it is the criterion that most strongly favors the two alternatives. C2, C3, and C5 break toward push delivery over polling, but since all three options clear the freshness goal they confirm rather than force the choice; no criterion dominates on its own, which is why the decision turns on C1 against C4.

The decision honors the tenet "Self-hosted and managed infrastructure are both permitted" by taking the self-hosted branch, and it takes direct ownership of the tenet "Connectivity failures must be visible, not mistaken for an unchanged board": with self-hosted sockets, surfacing a dropped connection and replaying from the last revision are work the board builds, not a provider feature. It is not taken against any tenet.

Committing forecloses the low-operations path (stateless polling, or a managed provider absorbing connection ops) and the quickest-to-ship path. It obligates the three downstream design nodes: the change store keeps replayable revisions and publishes them reliably, delivery manages socket sessions and connection capacity, and browser sync implements reconnect and catch-up from a last-seen revision. It also obligates capacity planning and on-call ownership for 800 concurrent connections and opening-time reconnect bursts.
```

The three nodes are still held, as you asked. Four rulings before I treat anything as final:

1. **Decision-doc review (stop).** Approve the doc above or send numbered feedback; I'll revise it in place.
2. **Latent-criteria probe.** Before finalizing Decision Elements I looked for criteria the three-option sketch never named, especially ones cutting against the recommendation. Two I did **not** add: (a) *time to a working push path* — hosted is "quickest," polling "simplest," and neither time-to-ship nor minimum operational burden has been declared the overriding criterion; (b) *availability concentration / on-call exposure* — 800 concurrent connections behind one team-run tier weighed against the 99.5% event-hours goal. Should either become a decision element, at what importance, and is there another a thoughtful critic would weigh that could move the selection?
3. **Tenet ruling (from the Phase 1 stop).** The Selection names tenets "both self-hosted and managed infrastructure permitted" and "connectivity failures must be visible," but C1 — the decisive lean to own ops rather than pay or tie to a vendor — has no tenet behind it, so its weight rests on a stated preference. Add a one-line tenet (e.g., lean toward owning infrastructure / avoiding a recurring vendor dependency where the operational cost is bounded), in which case I'll name it in C1 and Selection too? Or keep vendor-independence scoped to this decision and leave the tenets as they are? Any other leans to record?
4. **Still open from the Phase 1 stop.** (a) Explicit approval of the revised `docs/high-level-design.md`. (b) `docs/intent/access/access-design.md:10` still calls the approach "still-open" — a different segment, so I left it untouched: fix that wording now, or defer it to the three-node pass?