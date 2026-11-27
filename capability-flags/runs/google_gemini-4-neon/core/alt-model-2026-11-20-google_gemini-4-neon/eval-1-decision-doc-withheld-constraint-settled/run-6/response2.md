Overkill — the **Decisions & Alternatives** row in `docs/intent/registry/registry-design.md` is the right level here.

A standalone decision doc earns its place when a cold reader of the landed design would find the choice genuinely live and re-litigate it without full options and weighted criteria. Looking at how this lands:

- **Inherited HLD constraints settle it.** `docs/high-level-design.md` requires fully offline lookups with no runtime network route and lists remote/cloud services as non-goals, which eliminates the on-site HTTPS directory and managed search service outright.
- **It affects only the `registry` node.** `certificates` sees only `findBySerial(serial)`, so no other node is sized around the backend choice.
- **Deliberation effort doesn't change the bar.** Even when options feel close during discussion, once the landed structure makes the choice straightforward, a table row gives a future reader everything they need without adding doc overhead.

(If GaugeDesk later revisits the offline-only HLD tenet to allow networked lookups, *that* HLD-level tradeoff would be a stronger candidate for a decision doc.)

Ready to stick with the table row and triage the Phase 2 edge-case probe items (1–7) above, or anything else you want to adjust in `registry-design.md` before moving to Phase 3?