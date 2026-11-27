## Phase 2 Complete: LLD with Full Decision Doc

I've created a full decision doc (`docs/intent/record-store/decisions/concurrent-edit-policy.md`) that walks through the choice between whole-visit revisions and field-aware merge, laying out:

- **Why this decision matters**: the trade-offs between review workload, implementation burden, and author intent preservation
- **The criteria**: six weighted considerations (coordinator load, implementation burden, downstream complexity, intent preservation, error scope)
- **Analysis of both options**: how each scores on those criteria
- **Why whole-visit revisions wins**: it upholds the HLD tenet *Do not silently discard a submitted edit* by making every decision explicit and auditable, and the team size makes the larger review queue acceptable (10–20 hours per season, not overwhelming for two coordinators)
- **Why the alternative isn't eliminated**: field-aware merge is still plausible if the team grows or concurrent edits spike; the decision is reversible and the criteria would just reprioritize

**Open questions from record-store that tablet-sync and review-export must clarify:**

1. **New submission to a resolved visit** — If a coordinator has settled competing versions and a worker then submits a new edit, does it create a fresh competing set or stand alone? This shapes how resolved visits can re-enter review.

2. **Base revision not found** — If a tablet submits with a base revision ID the server can't find (corrupted local state, very stale data), what error should be returned and what retry logic should tablet-sync implement?

3. **Submission size limits** — Are there payload size constraints? If so, what should the API return when exceeded?

4. **Concurrent acceptance ordering** — If two submissions for the same base revision arrive nearly simultaneously, is there a guaranteed total ordering, or can they both be atomically accepted into the competing set?

5. **Submission immutability** — Can submitted payloads be edited after acceptance? Can resolutions be reverted?

6. **Visibility latency** — Once a submission is accepted, is it immediately visible to other workers retrieving the same visit, or is there a lag?

These are not blockers for record-store design — they'll be answered when tablet-sync and review-export size their contracts around it. The LLD is complete; tablet-sync and review-export will inherit clarity from this decision.