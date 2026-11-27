The decision doc is written, and the HLD state cell now reads "Drafted; whole-visit revisions selected." Both changes are in the working tree and not committed.

**What I wrote**

- **`docs/intent/record-store/decisions/concurrency-policy.md`** (new). It covers:
  - **Context and gates:** The two gates are preserving every original submission, and not inferring scientific relationships from field names.
  - **Weighted criteria:** Each criterion is tied to the tenet it comes from.
  - **Both options:** Each has a demonstration, per-element verdicts, and a summary. The field-aware merge gets its strongest honest description.
  - **Selection:** Whole-visit revisions, with the reasons, what it forecloses, and what it obligates downstream.
  - **Revisiting:** The two conditions under which the field-aware merge should be re-examined after a season of use, and the precondition for it (an agreed list of field relationships).
- **HLD** (`docs/high-level-design.md`): the record-store state cell now reads "Drafted; whole-visit revisions selected."

**Why we'd still consider the other approach**

The field-aware merge is clearly stronger on review workload and on how many visits are export-ready. It would become the better choice if coordinators find the queue is larger than two people can clear before Friday and most queued visits involve edits to unrelated fields. The doc names that trigger.

**What tablet-sync must accommodate**

- Keep the base revision ID for each draft.
- Show pending competing revisions to the field worker.
- Send complete visits, not change sets.

**What review-export must accommodate**

- A revision comparison screen that compares competing revisions with each other and with the last resolved revision.
- Exclusion of visits with unresolved competing revisions from the CSV.
- Resolution records that hold the coordinator's identity and the contributing submission IDs.

**Your earlier questions**

- The coordinator review-load cost is recorded in the decision doc, under the review-workload criterion and in the downstream obligations. The record-store LLD will carry the same note.
- The record-store LLD does not exist yet, so the Decisions row that links to this doc will be added when I draft the LLD in Phase 2.

Please review the decision doc and the HLD edit. Once you approve, I'll start Phase 2 and draft the record-store LLD, replacing the "Open Design Choice" section with the selected policy.