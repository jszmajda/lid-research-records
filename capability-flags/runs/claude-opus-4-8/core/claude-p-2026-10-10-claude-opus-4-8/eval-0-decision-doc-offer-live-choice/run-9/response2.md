Written. **`docs/decisions/delivery-transport.md`** (HLD-owned, project-level, no spec IDs), linked from the Key Design Decisions entry.

How it's structured so a cold reader can re-run the judgment:

- **Context** — what the transport fixes and why it's expensive to unwind (it sizes all three unwritten nodes). The three invariants every option meets — 15s freshness, failure visibility, 800-browser/20-eps capacity — are named as *background*, not criteria, so they don't masquerade as reasons.
- **Decision Elements** — no eliminating gate (all three can be built to meet the invariants); the choice turns on four weighted criteria: provider independence (major), operational burden & capacity ownership (major), update latency (moderate), recurring cost (moderate).
- **Options in the Domain** — one subhead each, described as its own advocate would, with a per-criterion fit verdict (strong/partial/weak) kept separate from the weighing.
- **Selection** — self-hosted WebSockets, worked through explicitly: the two major criteria eliminate the hosted service; latency-vs-burden decides between polling and sockets, and the doc states plainly that burden is the accepted cost rather than hiding it. It also names the re-opener — if the socket tier's ops cost bites at scale, the hosted service is the option to re-weigh.

Two honesty notes I want to flag rather than bury:

1. **The decision cites no tenet as mandating it.** The template calls that a signal — either the choice is purely local or a tenet is missing. Here it's genuinely local: your *"self-hosted and managed infrastructure are both permitted"* tenet is deliberately neutral and leaves this open, so I wrote the Selection as a local weighing under that neutrality rather than inventing a tenet. If you'd actually prefer the project to *lean* toward provider independence as a standing rule, that's a tenet edit — tell me and I'll propose one.
2. I described the change store's publication obligation as a durable-before-push / no-lost-or-double outbox. That's the socket choice's downstream consequence, stated at HLD altitude — the real mechanism is the change-store LLD's to settle, not pinned here.

Phase 1 stop. When you're ready for the three nodes, I'd start with **change-store** (delivery and browser-sync both size against its revision/publication contract) — crossing into each is a segment boundary, so I'll pause at each. Want me to go?