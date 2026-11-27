Wrote `docs/decisions/change-delivery-approach.md` and linked it from the HLD's Key Design Decisions row.

The doc lays out:
- **Context** — why the choice matters (shapes change store, delivery, and browser sync at once) and what's *not* a differentiator (all three options meet the 15-second freshness goal; the data-sensitivity tenet doesn't bar the hosted option either).
- **Decision Elements** — operational burden (moderate), recurring cost/provider coupling (major), latency beyond the floor (minor).
- **Options in the Domain** — polling, self-hosted WebSockets, hosted service, each described on its own terms with a verdict per element.
- **Selection** — self-hosted WebSockets, explaining why it beats the hosted service on the major criterion despite losing on operational burden, and what it commits the three downstream nodes to.

One flag: no existing HLD tenet actually speaks to provider coupling — I noted in the doc that weighing it as major here is a one-off judgment call, and that it's worth promoting to a tenet if future decisions keep leaning on it the same way. Want me to add that as a tenet now, or leave it as the doc's own note?