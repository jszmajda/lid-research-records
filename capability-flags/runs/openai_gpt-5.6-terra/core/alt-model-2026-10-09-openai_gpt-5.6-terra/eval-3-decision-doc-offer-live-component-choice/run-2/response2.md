## Phase 2: Record-Store LLD Review

Rewrote `docs/intent/record-store/record-store-design.md` to specify whole-visit revision handling:

- Every accepted creation or edit is an immutable, complete revision with an author, receipt time, idempotency key, and, for edits, a base revision ID.
- An edit based on the current resolved revision advances it only when no review is open.
- Stale edits, and all edits received while review is open, are retained as competing revisions. They do not overwrite the resolved reference revision.
- Unresolved visits cannot enter CSV export.
- The design now states the tablet contract: retain base revision IDs and idempotency keys, submit whole payloads, and preserve local drafts when review is required.
- The design now states the review/export contract: compare whole revisions, visibly queue unresolved visits, and omit them from CSV.
- The Decisions & Alternatives table records why field-aware three-way merging remains a credible alternative but is rejected: its rules could miss scientific relationships between nominally independent fields.

The independent LLD probe found several details that should be pinned before EARS. I recommend adding the concurrency and authorization invariants below to the LLD, then specifying their API behavior in EARS:

1. Make the base-current check and resulting revision creation atomic, so two concurrent edits cannot both advance the current revision.
2. Define submission and retrieval authorization for field workers, and restrict review resolution to coordinators.
3. Treat every competing revision accumulated while review is open as part of one review item; a resolution must account for all of them.
4. Make review resolution atomic and idempotent, so only one resolution can establish the next current revision.
5. Scope idempotency keys to the authenticated worker and define identical content using the submitted request representation.
6. Distinguish an unknown base revision from a base revision belonging to another visit.

One decision remains yours: when resolving competing revisions, should a coordinator be limited to selecting one stored whole-visit revision, or may they author a new complete revision representing their reviewed result?