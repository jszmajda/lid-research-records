Written to `docs/intent/record-store/decisions/concurrent-visit-edits.md`, and linked from the LLD's Decisions & Alternatives row.

**Context** states what is at stake: the current failure is the spreadsheet import dropping corrections, and the failure this decision could substitute is quieter — a record assembled by rule that looks clean, that no observer authored, and that nothing flags.

**Decision Elements** — one gate, inherited from *do not silently discard a submitted edit*: every submission survives and a person decides between competing ones. That gate is what eliminates last-write-wins. Then five criteria, each tied to the tenet or goal it derives from: scientific fidelity between fields (major), explainability of the path to an exported value (major), coordinator review volume (moderate), implementation and ongoing maintenance burden (moderate), tablet-side state under a 48-hour disconnection (minor).

**Options** — three, each analyzed per element with a verdict.

Field-aware merge is written as its advocate would write it, which is what you asked for: most concurrent corrections here plausibly touch different fields, so under revisions each one costs a coordinator a comparison that ends in "both, obviously" — review work that exists only as an artifact of the storage model. It scores **strong** on review volume, and its gate passage holds. What makes it **weak** on fidelity is structural rather than a matter of rule quality: disjointness is computed over field identity, while the relationships in this survey run between fields and inside the species and observer collections. Revising a species identification without touching its estimate is disjoint from another worker's estimate change, so correct rules combine them and produce a record neither observer made.

**Selection** names the tenet the choice is taken *against* — *prefer workflows two coordinators can operate without a dedicated systems administrator*. It cuts both ways here (no merge rules to maintain, but a real review queue), and the doc says the queue is the price of the selection, not an oversight in it.

The downstream obligations are spelled out per node: tablet-sync keeps a revision ID rather than a base snapshot, submits whole field sets, handles each rejection reason distinctly, keeps accepting edits to an already-contested visit, and shows a worker when their visit awaits resolution; review-export owns the comparison screen, holds contested visits out of the Friday CSV, reports what was withheld before the export reaches the partner, and carries the review volume for two coordinators at 6,000 visits a season.

It also records what would reopen the judgment: the unmeasured quantity is how often two workers edit one visit inside an offline window. Because the server retains every revision whole, any submission's base is reconstructable server-side, so a later merge policy would not require a tablet change — and a batch-resolve affordance for contests that differ only on disjoint fields is the cheaper first response.

Still open from the last stop, and I'd rather not settle these for you:

1. **Identical concurrent content** — keep my rule that a submission matching an existing competing revision attaches to it instead of creating a third head, or should every concurrent submission produce a competing revision so a coordinator always sees two people touched the visit? If kept: byte equality, or equivalence (observer list reordered, `2.0` vs `2`, whitespace)?
2. **Resolution authority** — restrict resolution to a coordinator role, or let any authenticated worker resolve, given there is no admin to manage roles?
3. **Plot reference on an edit** — can a worker correct a mis-keyed plot on an existing visit, which lets competing revisions name different plots, or is the plot fixed at creation?

And items 4–12 from that stop (resolution parents closed to new children, atomic staleness check, concurrent resolutions, identical-submission race, acceptance result on attachment, author/receipt as lists, resolution's rejection catalogue, per-visit idempotency scope, unknown-visit retrieval and history tie-breaking) are still unconfirmed — "4–12 as proposed" is enough if you agree. Once 1–3 are ruled and those land, I'll take the record-store EARS specs.