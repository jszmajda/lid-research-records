Wrote the decision doc and linked it from the LLD's Decisions row.

## Decision doc (`docs/intent/record-store/decisions/concurrency-mechanism.md`)

**Decision elements:** scientific-integrity risk of auto-combination (major), coordinator review workload (major), rule-maintenance burden (moderate), export eligibility (moderate), outcome explainability to the worker (minor).

**Whole-visit revisions** wins both major criteria — no automatic step ever combines fields whose scientific relationship the server can't see, and there's no merge-rule logic to maintain for two coordinators to lean on. It loses the moderate criteria: review workload is larger than the underlying conflict rate justifies (disjoint-field edits still become competing heads), and fewer visits clear in time for the Friday export.

**Field-aware merge** would have won on review workload and export eligibility, but its combination logic decides safety by field identity, not scientific relationship — it can silently combine a species ID correction with its cover-estimate correction just because they land on different fields. That's the risk the decision is explicitly taken against.

**What it forecloses/obligates**, now written into the Selection section:
- Forecloses ever auto-combining disjoint edits without a future decision revisiting this doc. Does *not* foreclose a coordinator incorporating multiple competitors' fields by hand during resolution — that stays a per-visit human call, not a standing rule.
- **Tablet-sync** must retain base revision IDs, surface a "pending against a competitor" outcome distinct from "current," and handle revision chains that keep growing for repeatedly-disputed visits.
- **Review-export** must build a revision-comparison view, exclude any visit with competing heads from export regardless of which fields collided, and accept a smaller export set / larger backlog than merge would have produced.
- Named the revisit trigger: if the review queue becomes unworkable for two coordinators and the project becomes willing to trade some silent-auto-combination risk to relieve it.

The LLD's Decisions & Alternatives row now just points to this doc.

I still owe you a triage of the 12-item edge-case probe from last turn before I can call Phase 2 (the LLD) done and move to Phase 3 (EARS specs) — none of those were addressed by this decision doc, which was scoped to the concurrency-mechanism choice itself, not the mechanism's own internal gaps. Want to work through those now, or should I hold them as open questions in the LLD for now and move on?