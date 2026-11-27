Written to `docs/decisions/change-delivery-route.md`, owned by the HLD, and linked from the Key Design Decisions entry. It reads cold — present tense, no account of how the discussion went, each option described as its advocate would describe it so a new reader can see what was given up and not just what was chosen.

**Structure:**

- **Context** — why the route is load-bearing (it settles the internal shape of change store, delivery, and browser sync at once, so reversing it rewrites three nodes rather than swapping a module). It also clears the ground: the 15-second freshness goal, the 20-minute recovery goal, and the one-authoritative-revision tenet are met by every route, and event updates carry no customer records, so none of those discriminate.
- **Decision Elements** — stated plainly: no gate eliminates anything, so selection rests entirely on weighted criteria. Vendor coupling and exit cost is the one **major** criterion, deriving from the *Own the live-update path* tenet. Then four **moderate** — burst latency, recurring operating cost, connection and reconnect operations burden, availability exposure during event hours — and one **minor**, steady-state read load on the change store.
- **Options in the Domain** — a subhead each, with a per-criterion fit verdict. Polling gets its real strengths stated: one code path for recovery and steady state, an operationally inert tier, no fees. The hosted service gets its genuine case too — fastest route to low latency, provider SLA, connection ops off the project's plate.
- **Selection** — self-hosted WebSockets, won on the major criterion first (coupling removes the hosted service despite it being strongest on operations), then burst latency separating sockets from polling, with polling's 160-requests-per-second idle floor reinforcing it.

Two things I want to flag about how the doc came out:

Probing for criteria that cut *against* the choice surfaced one worth keeping: **availability exposure during published event hours**. Self-hosting puts a new stateful component in the 99.5-percent path, and a provider's SLA might beat what the project achieves alone. The doc scores sockets **partial** there and says so in Selection rather than smoothing it over — connection operations is likewise the one criterion where the chosen route is weak and both rejected routes are strong. That's the tradeoff you accepted, recorded as a cost rather than reframed as a win.

The selection also leans on a second tenet, *Connectivity failures must be visible, not mistaken for an unchanged board* — owning the connection is only safe because a dropped socket surfaces instead of rendering as a current board. That has teeth for browser sync later.

Still open from the last stop, both unanswered:

1. **Tenet scope.** The new tenet currently reads *"**Own the live-update path.** Prefer infrastructure the project operates over a realtime vendor for pushing updates to browsers, and accept the connection and reconnect operations work as the price."* Scoped to realtime only, with managed services still permitted elsewhere. Should it instead lean project-wide — which would pre-commit the change store's hosting and any future queue or metrics choice — or stay narrow? The decision doc cites it as written, so widening it means a one-line edit in both files.

2. **Access cascade.** `docs/intent/access/access-design.md` still says authorization is "independent of the still-open change-delivery approach." One-line fix: independent of the WebSocket delivery route, with subscription credentials still belonging to delivery. It crosses a segment boundary, so I need your go-ahead.

Answer those and Phase 1 closes; change store, delivery, and browser sync stay untouched until then.