**Decision doc landed** at `docs/intent/record-store/decisions/concurrency-policy.md`, and the LLD's Decisions row now links it. Full text:

---

```markdown
---
node: record-store
---

# Decision: Whole-visit revisions for concurrent visit edits

## Context

Field workers edit the same visit independently — tablets stay offline for up to 48 hours, and corrections are often made after comparing field notes rather than in real time. The record store must turn concurrent submissions into one current visit without discarding anyone's work and without hiding how the exported value came to be. Two mechanisms remain credible in this problem space: whole-visit revisions settled by a coordinator, and field-aware three-way merge with review only where changes overlap. Choosing wrong either floods the two-coordinator review workflow with trivial conflicts or risks automated combinations that silently cross scientific relationships the rules do not model. This decision sets the contract that tablet-sync and review-export are sized against.

Arrival-order winner — the first or last submission simply becomes current — is eliminated by the project's requirement that no submitted edit be silently discarded. It is not analyzed below.

## Decision Elements

**Gates** (inherited from the HLD):

- **No silent discard.** A mechanism that drops or overwrites a submitted edit without human awareness is eliminated. Both surviving options pass; arrival-order winner fails.
- **Inspectable provenance.** Every exported value must be traceable to submitted work. Both surviving options pass, at different costs — resolution records versus field-level provenance.

**Weighted criteria**:

- **Scientific integrity of the current record (major).** A mechanism must not combine scientifically related edits — a species identification revised together with its cover estimate — in ways its logic does not understand. The project's non-goal of automated botanical validation or inference of scientific intent is what makes this criterion major: any automation that merges records is, at the boundary, inferring scientific intent.
- **Coordinator workload and operability (moderate).** Drawn from the tenet that two coordinators operate the workflow without a systems administrator: review volume per season and the difficulty of each review both matter.
- **Implementation and maintenance burden (moderate).** Field-level merge rules for scalar fields, observer lists, and species entries must be maintained as the record model evolves. Comparison interfaces and review queues must likewise be maintained, but do not encode scientific judgment.
- **Export readiness without human touch (moderate).** How many of roughly 6,000 seasonal visits reach the Friday CSV without coordinator intervention.
- **Offline submission simplicity (minor).** What tablets must retain and send: a base revision ID, or a base snapshot plus structured field changes.

## Options in the Domain

### Whole-visit revisions with coordinator resolution

Each submission carries the complete visit payload and names the base revision it started from. A matching base advances the visit's current revision; a stale base is stored as a competing revision and the visit becomes unresolved. A coordinator resolves by selecting one revision from the unsettled set; unresolved visits are held out of the export until then. Tablets retain only a base revision ID per draft and send whole payloads. Review presents competing whole revisions for comparison.

**Demonstration.** Tablet A and Tablet B both fetch visit V at revision R1. A corrects an observer name and submits (base R1) → R2, current. B adds a missing species and submits (base R1) → competing; V is unresolved. A coordinator compares R2 and R3 and selects one; the visit returns to export eligibility with the selected revision as current. Both original submissions remain in history.

**Analysis.**

- Scientific integrity — **strong** (major). No automated combination exists; a person compares complete visits and can weigh related fields together.
- Coordinator workload — **weak** (moderate). Any concurrent edit, even to unrelated fields, creates review work; the queue grows with the season.
- Implementation/maintenance burden — **strong** (moderate). No field-level merge rules to build or maintain; comparison of complete revisions is a bounded interface.
- Export readiness without human touch — **weak** (moderate). Visits with any unresolved competition need a coordinator before the Friday export.
- Offline submission simplicity — **strong** (minor). The tablet stores one base revision ID per draft and sends whole payloads.
- Gates — **passes** both.

Summary: trades review volume for combinations a person can see and a small system to maintain.

### Field-aware three-way merge

Each submission carries a base snapshot and structured per-field changes. Disjoint field changes combine automatically; only overlapping changes require review. Review and export need field-level provenance and a view of overlapping changes. Tablets retain base snapshots and compute and send structured diffs rather than whole payloads.

**Demonstration.** Same two tablets: A's observer-name correction and B's added species are disjoint by field and combine automatically; only edits to the same field or the same species entry surface for review.

**Analysis.**

- Scientific integrity — **partial** (major). Disjointness is judged by field structure, not scientific meaning. Revising a species identification and revising its cover estimate are two field changes that may be disjoint by key while being one scientific act; maintained rules can cross that boundary without noticing, and the resulting current record contains a combination no one reviewed.
- Coordinator workload — **strong** (moderate). Most concurrent edits combine without review; the queue shrinks to true overlaps.
- Implementation/maintenance burden — **weak** (moderate). Rules for scalar fields, observer lists, and species entries must be built and kept correct as the model evolves; an incorrect rule produces a wrong current record rather than visible review work.
- Export readiness without human touch — **strong** (moderate). Disjoint edits never block the Friday export.
- Offline submission simplicity — **weak** (minor). The tablet must retain base snapshots and transmit structured diffs — a heavier client contract and more local state.
- Gates — **passes** both, provided every automatic combination is retained with provenance.

Summary: trades a heavier client and maintained merge rules for a smaller review queue — at the cost of automated combinations the rules cannot fully justify.

## Selection

**Whole-visit revisions with coordinator resolution.** It is the only surviving option that scores strong on scientific integrity, the major criterion, and it wins offline submission simplicity and maintenance burden outright. It loses on coordinator workload and touch-free export readiness: the team accepts a larger review queue, operated by two coordinators, over automated merges that can silently combine scientifically related edits. The decision turns on the tenets *Do not silently discard a submitted edit* — whole-visit revisions make non-discard structural, since resolution can only select among stored submissions — and *Prefer workflows two coordinators can operate without a dedicated systems administrator*, weighed for rather than against: each review is a comparison of complete visits, not merge-conflict adjudication.

Committing forecloses automatic disjoint-field merging for the first release, and obligates the downstream nodes:

- **Tablet-sync** must retain a base revision ID on every local draft, send whole-visit payloads, size local storage and its retry state machine around the submission envelope, and surface to the worker when a submission has become a competing revision pending review.
- **Review-export** must hold unresolved visits out of the partner's CSV until a coordinator resolves them, export only the current revision of resolved visits, and give coordinators a comparison of competing whole revisions sufficient to select one.

Reconsideration triggers, recorded so the choice can be re-run rather than merely trusted: if the unresolved queue outstrips two coordinators' capacity in a normal season, the first lever is coordinator-authored composite resolution — resolving the frequent case where no submitted revision is acceptable as-is, without reopening automated merging. If that is still insufficient, field-aware three-way merge becomes live again, with its scientific-integrity cost weighed against a measured workload problem rather than a projected one.

## References

- docs/intent/record-store/record-store-design.md — the revision model this decision specifies
- docs/high-level-design.md — tenets and non-goals cited above
```

---

Still open from the Phase 2 stop — I need these before moving on:

1. **Unknown visit ID + non-null base** — reject (drafted) or accept-as-create?
2. **Coordinator-authored composite resolution** — keep deferred (drafted; the decision doc now names it as the first reconsideration lever), or include now?
3. **Retention/purge of superseded submissions** — retain indefinitely (drafted), or set a rule?
4. **Free-text reason on resolution** — add, or keep resolutions bare?
5. **Site-catalog stale sentence** — OK to fix the one line in `site-catalog-design.md`?

Answer these and approve the LLD, and I'll proceed to Phase 3: rewriting the REC specs against the revision model.