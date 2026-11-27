Decision doc written at `docs/decisions/self-hosted-websocket-delivery.md` and linked from the HLD's Key Design Decisions entry. Structure:

- **Context** — why the choice exists (15s goal, three nodes sized around it, no policy forbidding either infrastructure kind).
- **Decision Elements** — four weighted criteria: update latency headroom, vendor independence, operational burden (all major), store/browser obligations (moderate); the 15-second floor noted as background, not a discriminator.
- **Options in the Domain** — each of the three approaches described so a new reader can reconstruct it, with per-criterion verdicts and a one-line trade summary.
- **Selection** — self-hosted WebSockets: accept owning connection and reconnect operations to get fast updates without a realtime vendor; names the tenet engaged and what the choice forecloses and obligates downstream.

Two things before Phase 2:

1. Anything to correct in the decision doc?
2. Earlier I also asked for review of the HLD changes themselves (Approach, Architecture node lines, Key Design Decisions entry) — approved as-is?

On your go, I'll draft the three nodes: change-store, delivery, and browser-sync.