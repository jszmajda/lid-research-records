Here is the full updated LLD for your review.

---

**`docs/intent/record-store/record-store-design.md`**

---

**Revision Model** — every accepted submission creates an immutable revision with a server-generated ID, the visit it belongs to, the base it was edited from (or null for first submissions), author, receipt time, and payload. Revisions form a DAG. Sequential edits produce a linear chain; competing revisions arise when two revisions share the same parent.

**Visit State Machine** — three states: Unsubmitted, Current, Contested. A visit becomes Contested when any revision's parent already has another accepted child. It returns to Current when a coordinator resolves the last open fork. Contested visits are excluded from the export-eligible set.

**Submission envelope** — visit_id, idempotency_key, base_revision_id (UUID or null), payload. The acceptance response carries the resulting visit_status and, when contested, the competing revision IDs and authors so the tablet can surface the conflict immediately. Identical competing payloads still require coordinator review — the server can't determine whether the agreement was coincidental.

**Resolution** — coordinator selects an accepted_revision_id; the first submitted resolution for a fork wins and subsequent attempts are rejected. Post-resolution stale-base submissions create new forks handled identically to any other.

**Downstream contract section** names exactly what tablet-sync and review-export must accommodate (base revision tracking, contested surface, idempotency retry on the sync side; fork comparison view, Current-only export filter, coordinator identity recording on the export side).

**Decisions & Alternatives** — the merge alternative note explains why field-aware three-way merge is credible (real operational benefit for a high-volume team with two coordinators) and where it falls short (merge rules conservative enough to be safe recover most of the review volume they save; rules aggressive enough to matter require botanical domain expertise to maintain).

Four probe gaps closed: first-write-wins on concurrent resolution; competing revision details in submission response; identical payloads always go to coordinator; no claiming mechanism needed given first-write-wins.

Two items deferred as open questions: synthesis revisions (coordinator authors a new payload combining fields), and whether contributing_revision_ids in a resolution must exactly match the server's known competitors.

---

Does this read right to you? If so, I'll move to Phase 3 — the EARS spec update.