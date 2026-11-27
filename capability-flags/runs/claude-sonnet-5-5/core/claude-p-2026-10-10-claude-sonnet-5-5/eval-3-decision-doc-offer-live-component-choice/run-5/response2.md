I wrote the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md`, and nothing else has changed. This is a stop for your review, and the record-store LLD still says OPEN until the next phase.

**What the doc covers**
- **Context:** the offline, shared-tablet situation, why arrival order isn't evidence, and why the server can't tell related edits from unrelated ones.
- **Decision elements:** "no original submission is discarded" is recorded as an inherited bound that both options pass. The weighted criteria are:
  - scientific safety (major)
  - coordinator review workload (major)
  - maintenance burden, tablet complexity, export readiness and explainability (moderate)

  Each criterion names the HLD tenet or goal it comes from.
- **Both options**, each described at its strongest, with a fit verdict per criterion. Whole-visit revisions is strong on safety, maintenance and explainability and weak on workload and export readiness. Three-way merge is the reverse.
- **Selection:** whole-visit revisions, taken against review workload and export readiness. The deciding reason is that an unsafe automatic merge is invisible once it lands, while a large review queue is visible and can be worked down.
- **Why we'd still consider the other approach:** a "Revisit Conditions" section. If a season's queue is dominated by competing revisions on unrelated fields that coordinators resolve by keeping both, and the team can name a small set of fields that are safe to combine, the answer is a narrow, enumerated merge rule on top of whole-visit revisions, not a general merge engine.
- **Downstream accommodation:**
  - **Tablet-sync:** keep the base revision ID per draft, advancing it only from server-confirmed revisions. Store whole visits rather than diffs, retry on the idempotency key, and show pending competing revisions to the worker.
  - **Review-export:** a comparison screen for two or more revisions, a resolution action that records the coordinator and contributing submissions, unresolved visits held out of the CSV, and a count of held-out visits shown before Friday.

**Please check**
1. **Revisit conditions:** this is the part I inferred most, since you didn't say what evidence would change your mind. Is "trivially resolved by keeping both, plus a nameable safe field set" the right trigger?
2. **Held-out visits:** a visit with unresolved revisions is missing from Friday's CSV entirely, rather than exported at its last resolved state. That follows your "holds unresolved visits out" and I recorded it as such. It does mean the partner sees no row for that visit that week. Is that what you want, or should export fall back to the last resolved revision?
3. **Open edge for the LLD (not decided here):** what happens when a third edit is based on one of two competing revisions. I'll raise this in the Phase 2 edge-case probe rather than settle it silently.

On your approval, and with your answer to question 2, I'll move to Phase 2:
- Rewrite the record-store LLD around the selected design, replacing the OPEN section.
- Add a Decisions & Alternatives row linking this doc.
- Define the envelope, state, unresolved-work and resolution contract.
- Run the edge-case probe.

I'd still like your answer on the site-catalog sentence ("remains pending that choice") before I touch it, since that file is outside this segment.