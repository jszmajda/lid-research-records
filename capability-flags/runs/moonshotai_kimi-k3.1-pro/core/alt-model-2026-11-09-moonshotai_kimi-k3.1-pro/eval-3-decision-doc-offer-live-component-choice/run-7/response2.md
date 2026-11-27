Created `docs/intent/record-store/decisions/whole-visit-revisions.md` and linked it from the record-store LLD.

It records:

- The criteria behind the decision: scientific intent, coordinator workload, merge-rule maintenance, offline simplicity, and review/export complexity.
- A full case for field-aware three-way merging, including its lower review burden and the conditions under which we should reconsider it.
- Why whole-visit revisions better fit TidePlot’s inspectability and preservation tenets.
- The concrete obligations for tablet-sync and review-export, including base revision tracking, contested-state handling, revision comparison, conflict-version checks, provenance, and CSV exclusion.

The earlier LLD edge-case triage and approval remain open before I update the EARS specs.