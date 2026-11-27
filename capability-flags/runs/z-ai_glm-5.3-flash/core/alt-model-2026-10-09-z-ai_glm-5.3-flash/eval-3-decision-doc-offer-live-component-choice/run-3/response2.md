Decision doc written at `docs/intent/record-store/decisions/concurrent-visit-edits.md`, linked from the LLD's Decisions row. It lays out:

- **Decision elements**: two gates (no discarded edits; no server inference of scientific relationships — the second one eliminates the merge option on its own) plus five weighted criteria, with the HLD tenets named where they carry weight.
- **Both options** given their strongest honest representation: whole-visit revisions as the auditable-but-bigger-queue approach, field-aware three-way merge as the lower-review-volume approach with its disjoint-combination risk and maintained rule burden stated plainly.
- **Selection**: why whole-visit revisions win, what tradeoff is accepted (review volume grows with every concurrent edit, even trivially unrelated ones), and when the alternative would be credibly re-opened.
- **Downstream obligations** recorded as cascades, not co-ownership: tablet-sync carries base revision IDs and explains unresolved outcomes to workers; review-export gets the comparison view, adopt-only resolution, and holds unresolved visits out of the CSV.

Next up per your sequencing: the tablet-sync design (Phase 2 — I'd stop for review on the draft before its EARS). Ready when you are.