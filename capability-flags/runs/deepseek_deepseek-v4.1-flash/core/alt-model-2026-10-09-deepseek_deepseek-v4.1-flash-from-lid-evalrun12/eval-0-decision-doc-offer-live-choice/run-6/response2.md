Written to `docs/decisions/self-hosted-websockets.md` and linked from the HLD's "Committed changes delivered over self-hosted WebSockets" entry.

The doc lays out the reasoning cold:
- **Context** — why delivery must be fixed before the three downstream nodes are designed, and what each route would obligate across them.
- **Decision Elements** — no candidate fails a hard gate (all meet freshness, load, and reconnect recovery), so it's decided on weighted criteria: provider independence and low team operational burden (both major), update latency, recurring cost, and delivery reliability/failure visibility (moderate), implementation simplicity (minor). The reliability criterion names the tenet *Connectivity failures must be visible*.
- **Options** — polling, self-hosted WebSockets, and hosted service, each analyzed against every criterion.
- **Selection** — self-hosted wins as the only option strong on both major criteria while accepting the connection/reconnect operations cost; polling's lag and hosted's coupling are why the others lose. It records what this forecloses, what it obligates, and the tenet it turns on.

One gap the writeup surfaced, for your judgment: the decision leans on a preference for owning the realtime path over vendor coupling, and no current tenet states it — the existing "self-hosted and managed infrastructure are both permitted" only keeps both admissible. Would you like a tenet added so future infrastructure choices lean the same way (e.g. *Prefer owning the realtime path over provider coupling when self-hosting meets the requirement*), or is that a one-off call for this decision only?

With that settled, the Phase 1 HLD work is complete. Approve and we'll start the three nodes — change-store, delivery, browser-sync — beginning with change-store.