Overkill, I think. The Decisions & Alternatives row is enough.

A decision doc earns its place when a cold reader would re-litigate the choice without the competing options and criteria in front of them. Here the HLD already settles it:

- **The tenets decide it:** "no runtime network access" and "kiosks have no network route during normal operation" rule out the HTTPS directory and the managed service.
- **The row carries the rationale:** it names both alternatives and the constraint that excludes them, so a reader can reconstruct why SQLite was chosen.
- **The deliberation doesn't show in the result:** the options looked close while you were weighing them, but the landed design has one option that fits the constraints. The doc test looks at how the choice reads once it lands, not how hard it was to make.
- **Nothing else depends on it:** certificates is unaffected by the choice, so no other node is being sized around the result.

If you'd still like a doc, say so and I'll write one in `docs/intent/registry/decisions/` and link it from the row. One case where it would earn its place: if the "no network" tenet were ever relaxed, the two network options would become live again, and a doc laying out the criteria would help that future decision. That's speculative, so I'd skip it now.