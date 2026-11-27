I wrote the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the Decisions & Alternatives row in `record-store-design.md`.

**What it contains**
- **Context:** Why concurrent edits need a defined outcome, and what a wrong choice looks like: either a review queue the coordinators can't clear before Friday, or exported values no worker submitted together.
- **Criteria:**
  - Major: exported values are observations a worker actually submitted together, and the rules stay maintainable by two coordinators.
  - Moderate: review volume, and the fraction of visits export-ready without action.
  - Minor: tablet storage and submission size.
- **Options:** Whole-visit revisions and field-aware three-way merge, each with a description, an example, and a fit verdict per criterion. I left the merge option's strengths intact: it wins clearly on review volume and export readiness.
- **Selection:** Whole-visit revisions, because they win both major criteria. The doc says plainly that the decision is taken against the goal of making visits export-ready without coordinator action.

**Why the other approach stays credible**
- **Revisit triggers:** Revisit if coordinators can't clear the queue before Friday exports, or if most resolutions turn out to be an unchanged combination of unrelated fields.
- **Upgrade path:** Because revisions are stored whole, a merge could later be added as an assisted proposal a coordinator approves, not as automatic combination.

**What tablet-sync will have to accommodate**
- Keep the base revision ID per local draft and send it with every submission.
- Keep an idempotency key per submission for retries.
- Show pending competing revisions from the current-state response.
- Handle a submission that comes back as competing rather than head, and show the worker "awaiting review" instead of "saved".

**What review-export will have to accommodate**
- A comparison view of competing revisions for one visit.
- A resolution action that records the coordinator's choice.
- An eligibility rule that holds visits with open review work out of the CSV.
- A count of held visits shown before Friday's export.

I didn't touch the HLD or `site-catalog-design.md`, which still describe the choice as open. Should I update both?

The earlier edge-case triage is still waiting on you: the coordinator-edited resolution question matters most, and it affects both the doc's resolution obligations and REC-006.