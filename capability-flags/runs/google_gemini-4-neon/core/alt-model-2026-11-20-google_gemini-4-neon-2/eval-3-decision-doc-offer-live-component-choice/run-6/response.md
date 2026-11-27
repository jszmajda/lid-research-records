Updated `docs/intent/record-store/record-store-design.md` around whole-visit revisions.

### Summary of `record-store-design.md`

- **Revision model & visit states**: Every accepted field `submission` and coordinator `resolution` is stored as an immutable whole-visit revision (`revisionId`, `visitId`, `authorId`, `receivedAt`, `kind`, full payload, plus `baseRevisionId` or `resolvedRevisionIds`). Visit state is derived from active (unsuperseded) heads: `current` (sole active head, export-eligible) or `needs_review` (2+ competing active heads).
- **Contracts**:
  1. *Visit Submission*: takes `idempotencyKey`, `visitId`, `baseRevisionId` (`null` for new visit), and complete `payload`; validates auth, schema, `plotId`, and `baseRevisionId` lineage; enforces idempotency; returns `revisionId`, `visitId`, `receivedAt`, `visitStatus`, and `activeHeadIds`.
  2. *Current-State Retrieval*: returns `visitId`, `status`, `currentRevision` (`null` while `needs_review`), `lastResolvedRevisionId`, and `competingHeadIds`.
  3. *History & Unresolved-Work Retrieval*: returns full revision history per visit and the `needs_review` queue with competing heads and nearest common ancestor (when one exists).
  4. *Coordinator Resolution*: takes `idempotencyKey`, `visitId`, exact `resolvedRevisionIds` matching current active heads (rejects with stale-conflict if another edit arrived in the meantime), and resolved `payload`; persists an immutable `resolution` revision as the new sole head, returning the visit to `current`.
- **Downstream obligations**: Notes the cascade obligations for `tablet-sync` (tracking `baseRevisionId`, whole-visit submission, surfacing `needs_review`) and `review-export` (side-by-side comparison, exact-head resolution, excluding `needs_review` from CSV export).
- **Decisions & Alternatives**: Records whole-visit revisions (vs. field-aware three-way merge), exact `resolvedRevisionIds` matching on resolution, and `currentRevision: null` during conflict.

---

### Phase 2 Edge-Case Probe (triage: fix in LLD vs. defer)

A blind probe of `record-store-design.md` surfaced these internal gaps:

1. **Superseding during `needs_review`**: If a visit has competing heads `{H1, H2}` and a new submission arrives with `baseRevisionId: H1`, does the new revision supersede `H1` (leaving `{H2, H3}`), or do all three `{H1, H2, H3}` remain active heads?
2. **Resolution idempotency vs. stale-conflict**: If a coordinator retries a resolution with the same `idempotencyKey` after it already succeeded, does idempotency lookup take precedence over the `resolvedRevisionIds` active-head check (returning the original result), or does it fail as stale?
3. **Submission idempotency scope & replay**: What if the same `idempotencyKey` is reused by a different worker, reused with the same `payload` but a different `visitId`/`baseRevisionId`, or replayed after later edits changed `visitStatus` and `activeHeadIds`?
4. **Nearest common ancestor (NCA) ambiguity**: What should the review queue return when 3+ competing heads only partially share an ancestor, or when prior multi-parent resolutions produce multiple equally-nearest common ancestors?
5. **`lastResolvedRevisionId` edge cases**: What should `lastResolvedRevisionId` be when `status` is `current`, and if two independent `baseRevisionId: null` creations arrive sequentially for the same `visitId`, should the first-arriving one count as `lastResolvedRevisionId` (even though arrival order is not authoritative)?
6. **Per-visit write serialization**: Must concurrent writes (submissions/resolutions) for the same `visitId` be serialized atomically so head-set checks and revision persistence cannot race?
7. **Payload & `plotId` invariants across revisions**: Can a subsequent edit or resolution change `plotId` to another plot, and how should empty `observers`/`speciesCover`, duplicate species entries, or a `plotId` archived while the tablet was offline be handled?
8. **Role permissions & error shapes**: Can coordinators also submit field edits, can field workers read the review queue or other workers' visits, and which rejections (unknown `visitId`, cross-visit `baseRevisionId`, idempotency payload mismatch, stale conflict) must be distinct error responses?

---

### Decision Doc Offer

Because the whole-visit revisions vs. field-aware three-way merge choice trades credible options across multiple criteria (and tenets) and both `tablet-sync` and `review-export` will be sized around it, a cold reader later may question it if the review queue grows. Would you like me to record it as a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from `record-store-design.md`), or keep just the Decisions & Alternatives table row?

---

### Next Step (Phase 2 Stop)

Please review `docs/intent/record-store/record-store-design.md` and let me know:
1. Any edits to the LLD itself (and whether you want `docs/high-level-design.md`'s architecture table updated from `Drafted; concurrency choice open`).
2. Which of the 8 probe items above to resolve in the LLD now vs. defer to Open Questions.
3. Whether to add the decision doc or keep the table row only.

Once approved, I'll move to Phase 3 and update `docs/intent/record-store/record-store-specs.md`.