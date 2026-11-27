Recorded at `docs/intent/record-store/decisions/whole-visit-revisions.md` and linked from the LLD’s Decisions & Alternatives table.

The decision doc covers:

- Both options at full strength, including why field-aware three-way merge remains credible: it wins on review workload and export readiness, and would be reconsidered if concurrent-edit volume overwhelms two coordinators, disjoint edits dominate, or the team adopts an auditable merge-rule set with field-level provenance.
- Why whole-visit revisions win despite the larger queue: whole-visit scientific integrity, explainability, and lower maintenance burden, tied to the HLD tenets.
- What tablet-sync must accommodate: base revision IDs, complete-visit submissions, pending competing revisions, and a visit becoming unresolved after sync.
- What review-export must accommodate: whole-visit comparison, the resolution operation, and holding unresolved visits out of the CSV.
- What the choice forecloses and what it leaves open.

The Phase 2 stop is still open. I left the eight probe findings unchanged rather than deciding them for you. My recommendation is to apply items 1, 3, 4, 5, 6, 7, and 8 as mechanical clarifications, and bring item 2 back as the one real design choice: whether first arrival becomes the comparison baseline as specified, or whether competing siblings should leave the common base as the baseline until resolution.

Please confirm the LLD and say how you want the probe items handled. Then I’ll draft the EARS updates. I have not touched tablet-sync or review-export.