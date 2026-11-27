Done. The decision doc is written and linked.

**Files changed**
- `docs/decisions/delivery-route.md` (new) — the full decision, with frontmatter `node: high-level-design`.
- `docs/high-level-design.md` — the key-decision bullet now points to it.
- `CLAUDE.md` — added a `docs/decisions/` row to the navigation table.

**How the doc is structured for a cold reader:** Context (the problem, the three credible routes, and the two boundaries that apply to all of them — the 15-second freshness goal, and no customer data on a third party's path), Decision Elements (six weighted criteria, with **vendor dependency and portability** marked major and explicitly tied to the *Own over rent, within reason* tenet), Options in the Domain (each route given its strongest honest representation, with a per-element verdict and analysis), and Selection.

**Two things I deliberately did not soften**, since a new reader will look for them:

- The choice is taken *against* three elements, not just for one: operational burden (major), recurring cost at pilot scale, and fan-out cost under opening-time bursts. The doc states plainly that polling is the lightest option and the hosted service nearly as light, and that the project gives up the hosted service's offloaded fan-out.
- The fan-out arithmetic is quantified rather than hand-waved: 20 edits/second across 800 browsers is roughly 16,000 sends/second for the project to size. The doc also says the route cannot be swapped for a hosted service later without reworking the store's publication path and the browser's subscription model — the choice is worth revisiting only if the connection tier's operational cost proves larger than acceptable.

The doc closes with the downstream obligations it creates, so the next three nodes inherit a stated contract rather than a guess: the change store needs a replayable revision log plus reliable publication, delivery owns the socket session lifecycle and catch-up replays, browser sync owns last-revision tracking, reconnect, and replay.

Two questions still open from the last round:

1. **Tenet wording.** I wrote the doc against "**Own over rent, within reason**" (already in the HLD). If you'd rather keep the original neutral "Self-hosted and managed infrastructure are both permitted" or split it into two tenets, say so and I'll adjust the HLD and the doc's element that cites it.
2. **Inspection for the three nodes.** Default is that you read each phase output at its stop. For change-store, delivery, and browser-sync I can also run a zero-context reader over the drafts, or a delegated inspector reviewing in your place. Which do you want?

Say the word on those and I'll start the three nodes.