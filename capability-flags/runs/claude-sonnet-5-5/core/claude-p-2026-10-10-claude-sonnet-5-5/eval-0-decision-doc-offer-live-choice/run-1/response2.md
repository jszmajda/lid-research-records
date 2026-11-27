I wrote the decision doc at `docs/decisions/delivery-approach.md` and linked it from the Key Design Decisions entry in `docs/high-level-design.md`.

**What's in it**
- **Context:** Why delivery is the choice that sizes the change store, delivery and browser sync nodes. All three options meet the freshness, load and recovery goals, so the choice turns on latency, who runs connections, and vendor dependence.
- **Decision elements:** There are no gates, because every option passes them. The five weighted criteria are vendor independence and fees, update latency, connection and reconnect operations, build complexity, and visibility of connection failure. The last is drawn from your tenet that connectivity failures must be visible.
- **Options:** Polling, self-hosted WebSockets and the hosted service each get a description, a per-criterion fit verdict and a one-line summary.
- **Selection:** Self-hosted WebSockets is the only option strong on both latency and vendor independence. The doc says plainly that polling also meets the target, so this was a preference, not a necessity. It lists what the choice forecloses and what each downstream node now owes, and it names conditions for revisiting: operations cost exceeding the vendor fees avoided, or a missed availability goal.

**Please check**
1. **Criterion weights:** I set vendor independence as *major* and the rest as *moderate*, based on your stated reason. If you weigh them differently, for example if latency was the main driver, that changes the Selection prose, so correct me.
2. **Revisit triggers:** These are my wording, not something you said. Keep, edit or drop them.
3. **Open sockets:** The doc assigns the question of open sockets at session expiry or revocation to delivery. I can raise it at the delivery LLD stop instead if you prefer.

Still waiting on your answers from before: the tenet question and the stale line in `access-design.md`. After your review I'll draft the change store LLD, which is the first of the three nodes.