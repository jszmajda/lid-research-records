Wrote `docs/decisions/change-delivery-route.md` and linked it from the HLD's Key Design Decisions entry. It reads cold, in present tense, with no trace of our session.

What it contains:

- **Context** — why the route must be chosen and what it sizes (change store, delivery, browser sync).
- **Decision Elements** — no gate eliminates an option (all meet the 15-second goal; both hosting models permitted), so the choice is settled by weighted criteria: *vendor coupling and recurring cost* (major), *operational burden* (major), *freshness* (moderate), *change-store read load* (moderate), *recovery after disconnection* (major, derived from the connectivity-visibility tenet), and *moving parts* (minor).
- **Options in the Domain** — one section each for five-second HTTPS polling, self-hosted WebSockets, and hosted realtime service, each described as its advocate would, scored per criterion, with a one-line trade.
- **Selection** — self-hosted WebSockets wins on the major criterion *vendor coupling and recurring cost*: it and the hosted service both push on commit, but the project prefers to own connection and reconnect operations rather than pay a recurring vendor fee or depend on a provider. It names what committing forecloses, what it obligates downstream, and that it turns on the connectivity-visibility tenet.

**STOP for your review.** Two items from the last stop are still open, and I did not settle them for you:

1. **Tenet** — the Selection says this decision turns on a lean the tenets don't yet state (*own the operational burden rather than couple to a realtime vendor, when it buys a real capability gap*). Should I add that line to `## Tenets`, or leave the doc's mention as the only record?
2. **Cross-segment staleness** — `docs/intent/access/access-design.md:10` still says "independent of the still-open change-delivery approach." Want me to drop "still-open"?

Once you rule on those and confirm the HLD and decision doc are good, I'll open the three nodes (change store, delivery, browser sync) in turn, pausing at each as usual.