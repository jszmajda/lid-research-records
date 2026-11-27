I wrote the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md`. I haven't touched the record-store design or specs yet.

**What it contains**
- **Context:** the offline-correction problem, and why the server can't tell which edits are related.
- **Criteria:**
  - Scientific coherence is the major criterion.
  - Review workload, operability by two coordinators, and export readiness are moderate.
  - Payload and tablet state is minor.
  - Each criterion is tied to the tenet or goal it comes from.
- **Both options** are described in their strongest honest form, with a fit verdict per criterion.
  - Whole-visit revisions are strong on coherence and operability, weak on workload and export readiness.
  - Field-aware merge is the reverse.
- **Selection:** your reasoning is that the merge failure is silent, while the queue cost is visible.
- **Obligations for tablet-sync and review-export:**
  - **Tablet-sync** keeps the base revision ID per draft across restarts and long disconnection, and sends it with the idempotency key. It also tells a worker when their visit has competing revisions pending.
  - **Review-export** needs a side-by-side comparison of complete revisions, and leaves unresolved visits out of the CSV.
- **When to revisit:** the unresolved queue regularly exceeds what two coordinators can clear before Friday, and much of it is unrelated-field edits. Even then, a computed merge could be offered as a proposed resolution so every combined record is still approved.

**Things to check**
1. **Revisit trigger:** I wrote it myself, so please confirm it matches your thinking. In particular, the "proposed resolution" middle path is mine.
2. **Excluded visits:** "excludes visits with unresolved revisions from the export set" follows your words. It leaves open whether such a visit's last resolved revision is exported or the visit is omitted entirely. That belongs to the record-store current-state contract and review-export, so I'll raise it in the LLD probe rather than decide it here.
3. **HLD wording:** your "yeah" covered the decision doc; I'm treating the HLD edit as approved too. Say so if you want it changed.

**Next, Phase 2**
- Rewrite the record-store LLD:
  - Replace the "Open Design Choice" section with the revision contract: submission envelope, current-state response, unresolved-work representation, resolution operation.
  - Add a Decisions & Alternatives table that links this doc.
- Run the edge-case probe and bring you the gaps to triage. The choices I expect to put to you are:
  - how a submission against a stale base is stored, including chains of three or more competing revisions;
  - what happens to a worker's queued edits when a coordinator resolves while the tablet is offline;
  - what retrieval returns for a visit with unresolved work.

Shall I proceed with the LLD?