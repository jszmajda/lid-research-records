Decision doc written at `docs/decisions/realtime-delivery.md` (project-level, `node: high-level-design`, no status field, no EARS IDs) and linked from the HLD's Key Design Decisions row. It's written cold — present tense, options described as their advocate would, no chronology of the discussion — so a new reader can re-run the judgment. Here it is in full:

```
---
node: high-level-design
---

# Decision: Realtime delivery of committed board changes

## Context

MarketBoard keeps one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit one event revision. Up to 800 simultaneous staff browsers display a revisioned view, and a busy market produces about two status changes per minute with bursts of up to 20 edits per second around opening time. Changes must appear in connected browsers within 15 seconds, and a browser disconnected for up to 20 minutes must recover the latest board.

Three delivery approaches satisfy that freshness floor and preserve one authoritative event revision per committed edit regardless of delivery route; none introduces browser-side merging. Choosing among them is therefore a genuine tradeoff rather than the elimination of unfit options, and the three nodes that consume the choice — change store, delivery, and browser sync — are sized around whichever approach is selected. The board carries stall IDs and operational statuses, not customer records, so both self-hosted and managed infrastructure are permitted; a managed realtime service is a legitimate option rather than a prohibited one.

What is at stake: the delivery path determines how quickly a committed edit becomes visible, whether the board depends on a third-party provider for that path, how much connection machinery the project operates, and where the obligation to surface connectivity failures and catch up after a disconnect lives. Getting it wrong either ties the board to a vendor's fees and API, or leaves the project operating a stateful tier it did not budget for.

## Decision Elements

No option is eliminated by a gate; selection rests on four graded criteria. An element on which all options score equally is background, not a selection driver, and is omitted here.

- **Update latency beyond the floor (major).** How soon after commit a change reaches connected browsers, and how much lag is inherent to the mechanism. All three meet the 15-second goal; the differentiator is the headroom each leaves above it.
- **Independence from a realtime vendor (major).** Recurring fees, coupling to a provider's API, SDK, availability, and terms, and exposure to that provider's pricing. Recurring cost and provider coupling are weighed together because both arise from the same dependency.
- **Connectivity-failure visibility and catch-up (major).** Whether a connectivity failure is surfaced rather than shown as an unchanged board, and whether a browser can recover the latest board after up to 20 minutes disconnected. Importance derives from the tenet *Connectivity failures must be visible, not mistaken for an unchanged board* and from the recovery goal.
- **Operational burden of the delivery tier (moderate).** Connection capacity for up to 800 simultaneous browsers, reconnect storms around opening-time bursts, and reliable publication of committed revisions — work the project must own and operate.

## Options in the Domain

### Five-second HTTPS polling

**Description.** Browsers issue an HTTPS request every five seconds and receive the changes since a cursor. Delivery stays stateless request/response; the change store serves cursor queries; browsers run a polling loop. It is the simplest approach to operate: there are no long-lived connections, no session state, and no publication pipeline, every request is independent, and a failed poll is an ordinary HTTP failure. At 800 browsers the loop generates on the order of 160 requests per second, all served by the same stateless path used for edit commands.

**Analysis.**
- Update latency beyond the floor (major): **weak** — a change waits up to the next poll, so a few seconds of lag is inherent to the design; shortening the interval multiplies reads against the store.
- Independence from a realtime vendor (major): **strong** — no third-party realtime dependency; delivery rides the existing HTTPS command path.
- Connectivity-failure visibility and catch-up (major): **strong** — a missed poll is an explicit failed request, and cursor-based catch-up deterministically returns changes since the last cursor; a stale board is straightforward to distinguish from a failed fetch.
- Operational burden of the delivery tier (moderate): **strong** — no connection capacity to size and no reconnect storms; the cost is repeated reads rather than connection state.

**Summary.** Buys the simplest operation and the most direct connectivity semantics at the price of inherent lag.

### Self-hosted WebSockets

**Description.** The board's own servers hold long-lived WebSocket sessions and publish committed revisions onto them as they are committed. The change store keeps revisions replayable and publishes them reliably; delivery manages session lifecycle, publication, and reconnect; browsers run reconnect and catch-up logic against the revision stream. It is the fastest route to fresh updates without a realtime vendor bill: a change is pushed the moment it commits, and the entire delivery path is the project's own.

**Analysis.**
- Update latency beyond the floor (major): **strong** — a committed revision is pushed on commit with no poll interval; subsecond propagation is achievable.
- Independence from a realtime vendor (major): **strong** — no recurring realtime fees and no provider SDK, availability, or terms; the delivery path depends only on infrastructure the project operates.
- Connectivity-failure visibility and catch-up (major): **strong** — a dropped session is detected and surfaced, and the browser catches up from its last seen revision against replayable revisions; the tenet and the 20-minute recovery goal are met by explicit design.
- Operational burden of the delivery tier (moderate): **weak** — the project owns connection capacity for up to 800 simultaneous browsers, reconnect storms around opening-time bursts, and reliable publication.

**Summary.** Combines the lowest latency with full vendor independence, in exchange for owning connection capacity, reconnect handling, and publication.

### Hosted realtime service

**Description.** A managed realtime provider carries committed changes to browsers. Delivery wraps the provider, the change store reconciles its writes with provider publication, and browsers use the provider's subscription model. It is the quickest route to low-latency updates with the least connection operations: the provider absorbs connection capacity, fan-out, and reconnect handling, and the board integrates through the provider's SDK.

**Analysis.**
- Update latency beyond the floor (major): **strong** — push-based delivery with provider-managed fan-out gives low latency without building a socket tier.
- Independence from a realtime vendor (major): **weak** — recurring fees scale with connection volume, and the board couples to the provider's API, SDK, availability, and terms.
- Connectivity-failure visibility and catch-up (major): **partial** — reconnect and 20-minute catch-up depend on the provider's semantics and retention; surfacing failures faithfully requires mapping provider events onto the board's own connectivity model.
- Operational burden of the delivery tier (moderate): **strong** — the provider operates connection capacity and reconnects; what remains in-house is publication reconciliation, credential management, and provider-outage handling.

**Summary.** Trades recurring fees and provider coupling for the quickest low-latency path and the least connection operations.

## Selection

**Self-hosted WebSockets** is selected. It is the only option strong on both major criteria — update latency beyond the floor and independence from a realtime vendor. Five-second polling is strong on vendor independence and connectivity visibility but weak on latency; a hosted realtime service is strong on latency and operational burden but weak on vendor independence and only partial on connectivity visibility. The choice therefore turns on a single weighing: low-latency updates and independence from a realtime vendor are valued above minimizing operational burden, which is the moderate criterion. The one criterion WebSockets is weak on — the connection-capacity, reconnect, and publication work the project must own — is the cost this decision accepts. This elevates latency headroom, which the HLD describes as achievable but not required, above operational burden; that is a deliberate preference, not a mandated requirement.

The decision turns on the tenet *Connectivity failures must be visible, not mistaken for an unchanged board*: under a push model the board satisfies that tenet and the 20-minute recovery goal through explicit reconnect and catch-up against replayable revisions, built in-house rather than inherited from a provider. It stays within the tenet that self-hosted and managed infrastructure are both permitted — the managed option was in contention precisely because that tenet and the non-customer nature of the data allow it — and it overrides no tenet.

It forecloses polling's stateless simplicity and the managed provider's offloaded connection operations. It obligates downstream nodes accordingly: the change store must keep revisions replayable and publish committed revisions reliably rather than serve only cursor queries; delivery must own WebSocket session lifecycle, publication onto sessions, and reconnect handling; browser sync must hold subscription state and run reconnect and catch-up against the revision stream; and operations must size connection capacity for up to 800 simultaneous browsers and opening-time reconnect storms.
```

## STOP — still at the Phase 1 boundary

Accepting the doc offer was the only ruling you gave, so the other items from the last stop are still open. I have **not** started change-store, delivery, or browser-sync, and I have not touched the Access LLD.

1. **Phase 1 approval.** Approve the decision doc and the revised HLD (including the new link) as they stand, or give numbered feedback. I proceed to a later phase only on that explicit approval.

2. **Tenet — now with a concrete signal.** The doc names the two tenets it genuinely leans on (connectivity-failure visibility; self-hosted and managed both permitted), but its decisive weighing — low latency and vendor independence above operational burden — has no tenet behind it. That is the "missing tenet" signal, and the Selection says plainly that it elevates latency headroom the HLD calls achievable but not required. Should I record your lean as a one-line tenet under `## Tenets` (e.g., low latency and vendor independence are worth added operational burden), or leave it only as decision rationale? Any other load-bearing tenets?

3. **Latent-criteria probe before finalizing.** Is there a criterion a thoughtful critic would weigh that isn't in the Decision Elements — especially one cutting against the recommendation? One candidate I can see is that operation is confined to published event hours; it looks like background because it applies equally to all three options, but it would shrink the accepted ops cost. Weigh it, or treat it as background?

4. **Cross-segment cascade, still held.** `docs/intent/access/access-design.md` still says "the still-open change-delivery approach," now stale; the three unwritten nodes are also downstream of this decision. Both cross a segment boundary, so I've paused rather than auto-propagating. Should I cascade the Access cleanup now, or hold the whole cascade until you direct the three-node work?