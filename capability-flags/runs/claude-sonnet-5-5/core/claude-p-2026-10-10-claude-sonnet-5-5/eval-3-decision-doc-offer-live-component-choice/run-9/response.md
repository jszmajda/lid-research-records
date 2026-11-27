Whole-visit revisions are recorded in the record-store design, and I've stopped at the Phase 2 review. I haven't touched the specs, tests or code.

**What changed**
- `docs/intent/record-store/record-store-design.md`:
  - The open concurrency choice is replaced by a "Revisions and Competing Edits" section.
  - Every accepted submission is a complete revision that names its base revision.
  - A submission based on the current head advances the visit. Any other submission is stored whole as a competing revision, flags the visit as unresolved, and leaves the head alone.
  - A coordinator resolves by producing a new head, and unresolved visits are held out of export.
  - A Downstream Contract section states what tablet-sync and review-export must do (base revision IDs, comparison screen, export hold).
  - The Decisions row records why field-aware merging was rejected: it could combine scientifically related edits without noticing, and you accept the larger queue.
- `docs/high-level-design.md`: the record-store state and the paragraph saying tablet-sync and review-export must wait on the open choice now reflect the selection.

**Three questions only you can settle**
1. **Resolution content:** may a coordinator only pick one revision as it stands, or may they also author a combined visit from several? Authoring a combination is a manual merge, so it keeps the whole-visit intent but needs a coordinator edit screen. `REC-006` ("contributing submission IDs") reads as if combining is allowed.
2. **Retrieval while unresolved:** should a read return the head flagged as unresolved, or the head plus the competing revisions? The first is simpler for tablets. The second lets the tablet-sync explanation of pending revisions come from one call.
3. **First submissions with no head:** if two tablets each create the same visit UUID with no base, should the second be treated as competing under the same rule? I'd say yes, but the design doesn't say so yet.

**Decision doc offer:** you could record this choice as a full decision doc in `docs/intent/record-store/decisions/`, since both downstream nodes are about to be sized around it. The alternative is the single Decisions row that exists now. I'd lean toward the row; say if you want the doc.

Once you answer these and approve the LLD, I'll move to Phase 3 and update the EARS specs. Several existing specs (`REC-004`, `REC-005`, `REC-006`) will need tightening against the revision model.