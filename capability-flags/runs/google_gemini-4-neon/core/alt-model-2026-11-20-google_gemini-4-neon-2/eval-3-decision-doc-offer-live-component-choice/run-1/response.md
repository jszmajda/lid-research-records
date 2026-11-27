Updated `docs/intent/record-store/record-store-design.md` with the whole-visit revisions design.

### Summary of `record-store-design.md`

- **Revision model & visit state**: Each visit is an append-only DAG of immutable revisions (`submission` or `resolution`) with `parentRevisionIds`, full scientific `payload`, `authorId`, `receivedAt`, and `idempotencyKey`. Active heads (revisions with no child referencing them) derive `reviewStatus`: `resolved` (1 active head = `currentRevision`) vs. `unresolved` (2+ active heads = `competingRevisions`, `currentRevision: null`).
- **Operations & contracts**:
  - **Submit Visit Edit**: Validates auth, payload fields, plot existence, and `baseRevisionId`; enforces idempotency; advances linearly when `baseRevisionId` is the sole active head, or adds a competing head (`unresolved`) on stale base / duplicate root.
  - **Retrieve Current State and Lists**: Single-visit retrieval returning `reviewStatus`, `currentRevision`, and `competingRevisions`; filtered listing by `reviewStatus`.
  - **Retrieve Submission History**: Returns all immutable `submission` and `resolution` revisions for a visit.
  - **Resolve Competing Revisions**: Authenticated coordinator submits `supersedesRevisionIds` (≥2 active heads) plus a synthesized payload or verbatim reference to a superseded revision. Appends a `resolution` revision; any late-arriving edit not in `supersedesRevisionIds` remains an active head so nothing is silently discarded.
- **Decisions & Alternatives**: Recorded whole-visit revisions (vs. field-aware three-way merge), append-only resolution revisions (vs. in-place winner flag), and `currentRevision: null` for unresolved visits (vs. latest-arriving with conflict flag).
- **Downstream Obligations**: Noted cascade obligations for `tablet-sync` and `review-export` without co-owning their designs.

### Decision Doc Offer

Because the whole-visit revisions vs. field-aware three-way merge choice trades multiple criteria across two credible options and both `tablet-sync` and `review-export` will be sized around it, it is a candidate for a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from the Decisions & Alternatives row). Would you like me to write that decision doc, or keep it as the Decisions & Alternatives table row only?

### LLD Edge-Case Probe (for triage: fix in LLD vs. defer)

1. **Idempotency key scope & replay semantics**: What happens if an `idempotencyKey` is reused across different `visitId`s or `authorId`s, or with the same `payload` but a different `baseRevisionId`/`supersedesRevisionIds`? On replay after later edits, does it return the original `reviewStatus` at acceptance or the current `reviewStatus`, and are rejected keys ever stored?
2. **Per-visit serialization of concurrent writes**: When two submissions for the same `visitId` and `baseRevisionId` arrive simultaneously, is head evaluation serialized per visit so neither can falsely report `reviewStatus: resolved` while creating two active heads?
3. **Stale coordinator resolutions & resolution response shape**: When Coordinator B submits `supersedesRevisionIds` that Coordinator A already superseded (wholly or partially), what distinct conflict/rejection shape is returned, and what is the success response contract of `Resolve Competing Revisions` (especially when a late-arriving edit keeps the visit `unresolved`)?
4. **Mutability of `payload.plotId` across revisions**: Can a later `submission` or `resolution` change `payload.plotId` to another valid plot (as a correction), or is `plotId` immutable after root creation?
5. **Resolution payload vs. verbatim reference**: What if a resolution supplies both a payload and a revision reference, supplies neither, or references a revision not in `supersedesRevisionIds`? When copied verbatim, should the chosen source revision ID be recorded on the `resolution` revision?
6. **Payload invariants & no-op edits**: Which payload fields may be empty/null (`observers`, `speciesCover`, `notes`), and does a stale-base submission whose `payload` is byte-for-byte identical to `baseRevisionId` or another active head still create a competing head (`unresolved`)?
7. **Read ordering, list shape, and unknown `visitId`**: What deterministic ordering is guaranteed for `competingRevisions`, history, and filtered listings; does filtered listing return metadata or full revisions (paginated or unbounded); and what does single-visit retrieval return for an unknown `visitId`?
8. **Role boundaries & coordinator edits on `resolved` visits**: Can a coordinator correct an already-`resolved` visit via `Submit Visit Edit`, and what auth rules apply to the read operations?

*(Note: `docs/high-level-design.md` still notes `record-store` as "concurrency choice open" — I left it untouched for now and can refresh that note once this LLD is approved.)*

### Next Step (Phase 2 Stop)

Please review `docs/intent/record-store/record-store-design.md` and let me know:
1. Any changes to the LLD itself.
2. Which probe items (1–8) to fold into the LLD now vs. defer to Open Questions.
3. Whether you want the standalone decision doc or just the Decisions & Alternatives row.

Once you approve Phase 2, I'll move to Phase 3 and update `docs/intent/record-store/record-store-specs.md`.