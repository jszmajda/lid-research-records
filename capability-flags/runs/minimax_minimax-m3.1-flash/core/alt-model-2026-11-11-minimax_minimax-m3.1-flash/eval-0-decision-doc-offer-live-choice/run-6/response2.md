Written. Two files changed:

- **New** `docs/decisions/self-hosted-websocket-delivery.md` — project-level decision doc (owner: `high-level-design`), read cold by someone with no access to the discussion: Context, one gate (the update path must not require buying realtime capacity from a third party) that eliminates the hosted option, five weighted criteria (update latency major, burst load shape moderate, market-carried operational work moderate, store read load minor, vendor independence major), one section per option with verdicts and a concrete 800-browser example, and a Selection that shows the polling-vs-sockets contest turning on latency and load shape, with the operational cost accepted deliberately.
- **Edited** `docs/high-level-design.md` — the Key Design Decisions row now links to the doc.

Two things the doc surfaced that need your call before the three nodes:

1. **The gate is sharper than the tenet list.** The doc's gate forbids a paid realtime vendor on the update path only, while the HLD tenet still says "Self-hosted and managed infrastructure are both permitted." I wrote it that way deliberately — the board stays open to managed infrastructure elsewhere, and the decision scopes vendor-freedom to one path. But if you'd rather the tenet carry this generally, the sharper one-liner I proposed ("Prefer self-hosted infrastructure for the update path; accept the operational work it brings over per-connection vendor cost and provider coupling") would need to go into the HLD, and the doc would cite that tenet in Decision Elements and Selection instead of selecting on criteria alone. Right now it selects on criteria only, which the doc template flags as a signal that the project may be missing a tenet.

2. **Still open from before:** the stale "still-open change-delivery approach" phrase at `docs/intent/access/access-design.md:10` — may I reword it? And whether Target Users / System Design / Success Metrics should be drafted into the HLD now or as a separate pass.

Say the word on those and I'll start on the three nodes in HLD order — change-store, then delivery, then browser-sync — each with its own LLD, EARS specs, and its own stop.