The record-store LLD is finished around whole-visit revisions, and the HLD's "concurrency choice open" references are updated in place. Here is the Phase 2 stop.

## Record-store design — completed LLD (`docs/intent/record-store/record-store-design.md`)

The contract now reads:

- **Revision model**: every accepted submission creates a stored revision (payload verbatim, author, receipt time, base revision, per-visit sequence number). A submission based on the current revision becomes current; anything else becomes a **competing revision** held for coordinator resolution. Arrival order never decides which observations are retained.
- **Submission envelope**: visit UUID, plot UUID, base revision ID, idempotency key (scoped to the submitting worker), payload; author from authentication. Response reports accepted-as-current or accepted-as-competing with the current revision ID.
- **Retrieval**: current revision + payload, unresolved-review-work flag (review-export holds flagged visits out of the CSV), full revision list with statuses (`current` / `superseded` / `competing` / `resolved-out`), and resolution metadata (coordinator, contributing IDs, time) so the export path stays inspectable.
- **Resolution**: authenticated coordinators either adopt a stored revision or supply a coordinator-authored corrected payload. All competing revisions and the current at resolution time are recorded as contributors; originals are never discarded.

The edge-case probe (delegated to a fresh reader) returned 11 gaps. I folded the mechanical ones into the draft and left two as deferred open questions (retention policy; queue-pile-up surfacing, which belongs to review-export).

## Judgment calls I made — please confirm or narrow

1. **Resolution authority**: I ruled a coordinator may adopt one stored revision *or* author a corrected payload. Adopting one whole revision alone would re-create the silent-merge problem inside the review screen — but you may want pick-only for simplicity.
2. **Resolution races**: first resolution processed wins; later ones are rejected as invalid. I did *not* add idempotency keys to resolutions — retrying a lost connection would surface as an invalid resolution rather than a replay. Tell me if you want replay semantics like submissions have.
3. **Plot immutability**: a visit's plot is fixed at creation; new visits must reference an active plot, existing visits survive later archival.
4. **Rejected submissions are not retained** (no stored revision, response names the reason). Note this brushes the "do not silently discard a submitted edit" tenet — I read that tenet as covering accepted work. If you want rejected submissions retained too, say so.

## Also for you

- **Decision doc**: the whole-visit-revisions choice will stay live for a cold reader (field-aware merge still looks attractive on review-load grounds, and two nodes are about to be sized around this). Want it recorded as a decision doc under `docs/intent/record-store/decisions/`, or is the Decisions & Alternatives row sufficient?
- **Cross-segment note**: site-catalog's design says tablet-sync's reconciliation behavior "remains pending that choice" — now stale. It's a one-line edit, but it crosses a segment boundary, so I'm asking before touching it.

On your approval of this LLD (and the calls above), I'll proceed to Phase 3: updating the REC EARS specs to cover the revision semantics, with a consistency report at that stop.