The record-store design is finished. Whole-visit revisions is now the settled mechanism, and the record-store's public contract is defined: revisions carry a base revision ID, a visit advances only on a submission naming its current revision and only while no review round is open, anything else becomes a competing revision for coordinator review, and unresolved visits are held out of the partner CSV.

**What changed**

- `docs/high-level-design.md` — record-store marked Designed; the mechanism summary now states the "under review does not advance" rule and the export-hold rule, and the HLD gained a tenet for preferring an explicit coordinator over automatic combination.
- `docs/intent/record-store/record-store-design.md` — rewritten as a complete design: stored entities, revision status model, single-current invariant with per-visit serialization, a fixed payload schema, the submission contract (idempotency scoping, check order, six concurrency outcomes, accept/reject response shapes), review rounds and resolution, retrieval contracts including the export-eligible set, export eligibility, a Decisions & Alternatives table, and the deferred questions.
- `docs/intent/record-store/record-store-specs.md` — 6 specs became 54, covering the whole contract.

**Phases 5–6 are not done.** This repository contains no implementation code and no test harness, so there is nothing to write failing tests against. The specs are all `[ ]` active gaps. That work needs a codebase to land in.

**Two things I need from you**

1. **Coordinator-authored resolution.** Right now a coordinator who rejects every competing revision must submit a new revision naming the current revision, which joins the open round as competing and needs a *second* resolution round — the same person cannot simply fix the visit. Should the store offer a distinct coordinator-authored resolution that becomes current directly? I left it as deferred because it trades away your "big review queue" stance in one narrow case.

2. **The site-catalog lookup operation.** Record-store's plot validation now needs the catalog to expose a server-side lookup by plot UUID reporting known-or-not and archived status; the catalog currently only publishes a tablet-facing snapshot and has no lookup contract. That operation belongs to the site-catalog segment, so per cascade discipline I did not write it — it needs your go-ahead, since it will also need specs there.

One judgment call worth flagging: I added a tenet to the HLD ("Prefer an explicit coordinator over an automated combination of scientifically related observations") to carry your stated reason for choosing whole-visit revisions, and a rejection log for submissions that fail validation, so that a refused edit leaves a trace rather than vanishing. Both are mine, not yours — say the word if either should be recast.