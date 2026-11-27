Whole-visit revisions is now the record-store's contract. I treated "finish the record-store design" as authorization to cascade the design docs in one pass (Phases 1–4) and stop before tests/code; here is the output and the decisions I need from you.

**Phase 1 — HLD** (`docs/high-level-design.md`): record-store row now reads "Contract drafted; whole-visit revisions"; the paragraph saying the choice was open now states the mechanism and that tablet-sync/review-export must size around the record-store contract; added the tenet *"Prefer a larger coordinator review queue over a server that recombines scientifically related edits on its own."*

**Phase 2 — LLD** (`docs/intent/record-store/record-store-design.md`, rewritten): payload schema; revision model (immutable payload/metadata, mutable status: `current` / `pending_review` / `superseded` / `not_accepted`); the concurrency rule (base == current → advances immediately; base == an accepted earlier revision → held pending; unusable base → rejected, nothing stored); unresolved-work and resolution semantics; the five public operations, envelope, outcomes, rejection reasons, ordering; identity/authorization; storage model; a Decisions & Alternatives table; deferred list.

**Phase 3 — EARS** (`docs/intent/record-store/record-store-specs.md`): REC-001…REC-037 (REC-001/002/003/004/006/009/010/011/016/020/021/022/023/024 revised in place; the rest new), all still `[ ]`. Consistency check: every LLD behavior has a spec; no spec contradicts another; scoping is explicit (pending vs accepted, per-visit vs per-revision); no requirement lines live in the design doc. A delegated LLD probe and two blind spec readers (given only the spec text) found no remaining ambiguity beyond the items below.

**Decisions I need from you** (my draft default in bold):

1. **Can a coordinator resolve by authoring a revision, or only by selecting a submitted one?** **Only selecting a submitted revision** (as drafted); a coordinator-authored variant is a compatible later addition.
2. **Resolution scope:** one resolution closes every pending revision for that visit (**as drafted**), or one competing group at a time, leaving other pendings open?
3. **If the selected pending revision was written against an older base than the current revision, it still replaces the current revision** (**as drafted**; the displaced revision is retained as `superseded`), or should such a selection be rejected?
4. **A submission based on the current revision is accepted immediately even when the visit already has pending revisions** (**as drafted**), or queued behind the open review?
5. **Payload schema defaults** (**as drafted**): plot fixed by the visit's first submission; cover is a number 0–100; one entry per species; observers non-empty; unknown fields rejected. Adjust anything the field team would define differently?
6. **Roles:** workers submit, coordinators resolve, and author/coordinator identity comes from the authenticated caller, not the request body (**as drafted**).
7. **HLD tenet wording** (item above) — keep as written?

**One offer:** the whole-visit-revisions choice stays live for a future reader ("why not merge?"), so I can write it up as a decision doc under `docs/intent/record-store/decisions/` with the trade-off and criteria — say yes or no.

Phases 5–6 (tests first, then code) have not started: the repo currently holds only design docs, so there is no implementation to annotate. All 37 specs stay `[ ]` until that code exists.