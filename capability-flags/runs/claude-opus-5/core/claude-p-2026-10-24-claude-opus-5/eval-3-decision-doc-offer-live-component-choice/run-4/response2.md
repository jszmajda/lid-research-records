Phase 1 output — HLD revision (shown above) plus `docs/intent/record-store/decisions/concurrent-visit-edits.md`. The doc's shape:

**Context** frames the problem from the domain — shared tablets, same starting state, receipt order carrying no authority — and parks the two invariants that *don't* separate the options (no original submission discarded, no reconciled record exported without coordinator approval). Both approaches satisfy both, so they're background rather than gates; nothing here eliminates an option outright, so the doc runs on weighted criteria only.

**Criteria**: scientific fidelity (major) and review workload before the Friday export (major) pull against each other; then resolution without collateral loss, provenance inspectability, and maintenance burden (moderate), and submission size (minor).

**Options** each get a description written as its advocate would put it, a concrete demonstration, and per-criterion fit. The merge option's demonstration is the one doing the real work: A re-identifies *Salicornia* as *Sarcocornia* while B, from the same base, revises that entry's cover from 15% to 30% — field-keyed rules combine them into *Sarcocornia* at 30%, a pairing neither observer recorded, and raise no review precisely because the fields look disjoint.

**Selection** names the loss plainly: review workload is the criterion we give up, on the reasoning that a queue announces itself and a bad merge doesn't. It records that *prefer workflows two coordinators can operate without a dedicated systems administrator* is strained, not honored, and why that's accepted. The three downstream obligation lists (record-store, tablet-sync, review-export) are there, and the revisit conditions are specific rather than "if it gets painful": collisions measurably dominated by scientifically uncoupled fields; a schema where coupled judgments become atomic units a rule can treat as indivisible; or a queue two coordinators can't clear by Friday.

The doc isn't linked yet — the Decisions & Alternatives row pointing at it lands when I draft the LLD in Phase 2.

**One thing I hit writing this that I shouldn't settle for you.** The doc commits record-store to "resolution must not require a coordinator to drop an unrelated correction without that loss being visible to them," but there are two real ways to meet that, and they size review-export differently:

1. **Pick-one.** The coordinator chooses which competing revision becomes current. Cheapest to build and matches the comparison screen you described. But in the demonstration case, keeping both A's new species and B's observer fix means picking one and then re-entering the other edit by hand — the loss is visible, not prevented.
2. **Coordinator-composed revision.** The coordinator starts from either competing revision and edits fields to produce the resolving revision, which is retained with both contributing submission IDs. Every current record stays human-authored, and no correction needs re-typing — but review-export now needs an editing surface, not just a comparison screen, which is more than the review queue you signed up for.

I lean to 2, because 1 reintroduces a smaller version of the problem this decision exists to fix, and the re-typing happens under deadline pressure on Friday. But it widens review-export's scope, and that's your call to make before I write the contract around it.

Which resolution model, and any numbered changes to the HLD edit or the decision doc?