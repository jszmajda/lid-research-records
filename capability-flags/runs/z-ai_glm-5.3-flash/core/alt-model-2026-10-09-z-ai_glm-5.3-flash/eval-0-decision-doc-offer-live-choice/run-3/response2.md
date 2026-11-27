Decision doc written: `docs/decisions/self-hosted-websockets-delivery.md` (project-level, owned by the HLD), and the HLD's Key Design Decisions row now links to it.

It's written to be read cold — someone new can re-run the judgment from it alone:

- **Context**: the scale/freshness numbers that make all three routes viable, and why the choice is hard to reverse (it shapes store, delivery, and browser sync).
- **Decision Elements**: two majors — vendor coupling, plus latency/cost/burden as moderates and read amplification as minor. No gates eliminate anything, so it says so explicitly and selects on the weighted criteria.
- **Options**: each given its strongest honest representation — polling as the genuinely simplest stateless option, hosted as genuinely lightest to operate.
- **Selection**: hosted eliminated primarily by vendor coupling; polling eliminated because its wins (simplicity, no connection ops) are on criteria the 15-second goal doesn't demand; WebSockets wins on latency, reads, cost, and coupling, losing only on operational burden — which you accepted deliberately. It names the tenet it's taken with (self-hosted/managed both permitted) and lists the downstream obligations each node inherits.

Take a look at the doc — particularly whether the Selection section reflects your actual weighing (I framed vendor coupling as the deciding factor over cost). On your approval, I'll start Phase 2: drafting the three leaf LLDs — change-store, delivery, browser-sync — one at a time with a stop after each.