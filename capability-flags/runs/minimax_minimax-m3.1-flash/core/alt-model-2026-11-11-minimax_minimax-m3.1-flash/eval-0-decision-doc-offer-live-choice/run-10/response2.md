**Decision doc written: `docs/decisions/delivery-approach.md`** (node: `high-level-design`, no EARS IDs), and linked from the HLD's *Key Design Decisions* row plus the Architecture section.

How it's built, for a reader who has none of our history:

- **Context** — the settled parts (HTTPS commands, one event revision per committed edit, one authoritative board) and why the delivery route was the open question.
- **Decision Elements** — two gates (freshness: 1 second; browser-client independence: platform-standard APIs only, no vendor browser library) and eight weighted criteria: update latency, recurring cost shape, vendor coupling/exit cost, operational burden, failure visibility, delivery-semantics fit, change-store read/publication burden, browser-side complexity. Each option gets its strongest honest case, then a verdict per element, with the criterion importance carried in one place and the fit in the other.
- **Options in the Domain** — polling (eliminated on freshness), self-hosted WebSockets (passes both), hosted realtime (eliminated on the browser-client gate).
- **Selection** — why sockets win, the tenet it turns on (*own the commodity, buy the specialized*), what it forecloses, what it obligates downstream, and two explicit re-run conditions: relaxing freshness to ≥5s brings polling back into contention; if our operating cost for 800 browsers exceeds a hosted subscription, the browser-client gate is the constraint to re-examine — and it is the price of reversing later.

Two things I did not decide for you, both of which the doc currently assumes:

1. **The 1-second freshness goal is still unratified.** The doc's freshness gate is written against the goal as it now reads in the HLD. If you want 15s back, the gate changes and polling survives it — I'd then rework the gate and re-run the selection.
2. **The doc leans on the tenet "own the commodity, buy the specialized."** If you drop that tenet, the doc loses the principle it turns on and I'd need to restate the selection on the criteria alone.

Ready for Phase 2 when you are: the change-store, delivery, and browser-sync LLDs, with the open choices in each (publication and replay shape; session lifecycle and capacity; reconnect and catch-up) sketched for your selection before I draft around them.