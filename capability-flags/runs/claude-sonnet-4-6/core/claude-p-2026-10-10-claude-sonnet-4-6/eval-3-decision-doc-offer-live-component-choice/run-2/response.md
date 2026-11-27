**Phase 1 — HLD update** (minor): Updated the record-store state from "Drafted; concurrency choice open" to "Drafted", and updated the dependency note to reflect the choice is settled.

---

**Phase 2 — Record Store LLD** (full draft below for review)

---

The design is now at `docs/intent/record-store/record-store-design.md`. Here's what was settled:

**Revision model**: every submission creates a revision pointing to its parent via `base_revision_id`. A visit is *current* when it has one head; *unresolved* when it has two or more. Competitions arise when two accepted revisions share the same base.

**Submission processing**: validates auth, field types, plot reference, and idempotency key. A null base is only valid for a visit's first submission — subsequent attempts with null are rejected and the response includes the latest revision ID so the tablet can sync. Submissions onto a competing head are accepted (more heads join the pool). Submissions onto a superseded revision are rejected.

**Resolution**: coordinators select one head or synthesize a new revision. Both forms are atomic and record full provenance. A second concurrent resolution attempt is rejected with the accepted outcome in the response.

**Export eligibility**: only current visits (one head) enter the export set.

---

**LLD-level edge-case probe** — gaps identified for you to triage:

| # | Question | Gap |
|---|---|---|
| A | When a worker submits with null base but revisions exist, the LLD says reject and include the latest revision ID — but if the visit is *unresolved*, which revision ID is "latest"? There's no single current head. | The rejection response shape for this case is unstated. Should it return all competing head IDs, or is "go look at /competing" sufficient? |
| B | When a coordinator submits a synthesis resolution, the new revision has the competing heads as parents. If another submission had arrived naming one of those heads as base (before the resolution landed), that new submission is now a head too — resolution did not clear it. Does the visit re-enter unresolved immediately after a resolution? | The LLD accepts submissions onto competing heads, but does not state what happens if such a submission arrives in the window between the coordinator submitting a resolution and it being committed. This may need a locking rule or the acceptance rule for submissions-onto-competing-heads to be narrowed. |
| C | The LLD doesn't define what "superseded" means precisely across non-linear chains. If R1 → R2, and separately R1 → R3 (competition), and the coordinator resolves by selecting R3 — is R2 now superseded? A submission naming R2 as base should be rejected, but the LLD's rule ("a revision that is no longer a head") covers this only if R2 was a head. | The term "superseded" needs a precise definition (any non-head revision, or specifically a revision overridden by a resolution). |
| D | Coordinator synthesis validation uses the same rules as worker submissions. But observation_date and observer_names come from the coordinator's judgment — should they be allowed to set observation_date to a date before any contributing submission? The LLD doesn't state any date-range constraints. | May be intentional (coordinators set whatever the science says), but worth an explicit decision. |

Please review the LLD and triage these gaps (fix in LLD vs. defer as open questions vs. no action needed). Once you approve, the next step is Phase 3 — updating the EARS specs to cover the whole-visit-revision mechanics.