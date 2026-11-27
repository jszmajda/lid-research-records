Wrote `docs/decisions/self-hosted-websocket-delivery.md` — a project-level decision doc linked from the HLD's Key Design Decisions entry. It carries:

- **Context** — why delivery choice exists, what it shapes downstream, and what getting it wrong costs, readable cold.
- **Decision Elements** — two gates (no vendor fee/coupling; replayable revisions as background) and five weighted criteria (latency major, read amplification moderate, cost major, connection ops burden moderate, vendor coupling major).
- **Options** — all three with their strongest honest representations, concrete demonstrations, and per-element verdicts.
- **Selection** — why self-hosted WebSockets wins, the leaning it turns on, the downstream obligations for store/delivery/browser-sync, and how reversible the route is.

Two judgment calls to flag: I graded latency and vendor coupling as **major** and connection-ops burden as **moderate** — that's the weighing that makes the selection follow from the analysis, and it should reflect how you actually lean. If you'd rank burden higher, say so and I'll re-weigh.

Also, my earlier questions on the 15-second freshness goal and the "self-hosted and managed infrastructure both permitted" tenet are still open — resolve those and I'll start the change-store node.