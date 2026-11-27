I've written `docs/intent/record-store/decisions/concurrency-policy.md` and linked it from `docs/intent/record-store/record-store-design.md`:

- **Context & Elements**: Frames the 24-worker / 12-tablet / 6,000-visit scale and evaluates options against four weighted criteria (*Preservation of coupled scientific intent* [major], *Low operational and rule-maintenance burden* [major], *Coordinator review volume* [moderate], *Tablet and sync simplicity* [moderate]), tied to the HLD tenets.
- **Options & Selection**: Gives both **Whole-visit revisions** and **Field-aware three-way merge** full analysis, selects whole-visit revisions, and documents why field-aware three-way merge remains a credible alternative if disjoint concurrent edits ever outgrow the two coordinators' weekly Friday review capacity.
- **Downstream Obligations**: Captures what `tablet-sync` (`base_revision_id`, `idempotency_key`, whole-visit payloads, acceptance outcomes) and `review-export` (whole-visit comparison view, `expected_pending_submission_ids` guard, excluding `has_unresolved_review: true` from CSV exports) must accommodate.

Before we move to **Phase 3 (`record-store-specs.md`)**, please:
1. Triage the 14 edge-case probe items above (which to fix in `record-store-design.md` now vs. defer as open questions).
2. Confirm you're ready to proceed to Phase 3.