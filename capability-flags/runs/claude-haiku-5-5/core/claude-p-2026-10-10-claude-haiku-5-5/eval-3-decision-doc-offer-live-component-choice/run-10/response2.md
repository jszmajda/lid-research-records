I wrote the decision doc at `docs/intent/record-store/decisions/concurrency-policy.md`. It follows the decision-doc template: it lays out the criteria, both options, and the selection. It has no EARS IDs, and it's linked from nowhere yet, because the record-store LLD that would link to it hasn't been drafted.

**What it records**

- **Selected: whole-visit revisions.** It rests on three major criteria: keeping each worker's submitted visit intact, keeping exported values traceable to a submission, and not combining scientifically linked fields without a coordinator seeing them together.
- **Taken against one tenet.** It weakens "Prefer workflows two coordinators can operate without a dedicated systems administrator," because concurrent edits to unrelated fields now create review items. The doc says the team accepted that cost.
- **Why the other approach stays on the table.** Three-way merge would cut review volume, get more visits into the Friday export, and keep submissions small. Its weaknesses are the maintained per-field rules and combinations no one reviews as a whole visit. The "when to reconsider" section names the trigger: coordinator review time limits the Friday export, and most review items involve non-overlapping fields. It also says to measure this from the first season's queue.
- **What tablet-sync must accommodate.** Keep the base revision ID with each local submission. Show a worker when their edited visit has competing revisions. Keep their draft intact while the coordinator decides. Do not merge fields locally.
- **What review-export must accommodate.** A side-by-side revision comparison view. Unresolved visits are excluded from the CSV and reported as blocking review work. A resolution carries its contributing submission IDs into the export's provenance.

**Still open**

- I did not check the tenet trade-off with you separately. I took your "yeah" to mean record it as taken against the coordinator-workload tenet. Tell me if you want that changed.
- The HLD line I changed last turn stands: "Drafted; whole-visit revisions selected, contract pending."
- Next is the record-store LLD rewrite, which removes the "OPEN" section and adds the Decisions row that links to this doc. Then the REC spec updates. I'll stop after the LLD for your review, then the specs.