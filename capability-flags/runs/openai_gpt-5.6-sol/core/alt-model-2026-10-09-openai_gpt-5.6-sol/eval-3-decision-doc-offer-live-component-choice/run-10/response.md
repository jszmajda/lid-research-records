**Phase 2: Record-Store Design**
Updated:

- `docs/intent/record-store/record-store-design.md`
- `docs/high-level-design.md`

The design now defines complete immutable revisions, base-revision lineage, unresolved conflict sets, whole-revision retrieval, atomic exact-set resolution, coordinator-authored replacement revisions, and downstream contracts for tablet-sync and review-export. Field-level automatic merging is explicitly rejected.

`git diff --check` passes. EARS specs remain unchanged pending design approval.

**Review Questions**
The edge-case probe found these decisions still need confirmation:

1. **Concurrency and retries:** I recommend linearizable per-visit transactions, commit-order race outcomes, and idempotency keys for both submissions and resolutions.
2. **Resolution lineage:** I recommend that coordinator-authored revisions reference every candidate revision as contributors rather than having one base. Future tablet edits may use that resolution revision as their base.
3. **Plot corrections:** Should a known-base revision be allowed to change the plot UUID, or should plot identity become immutable after the first submission? I recommend allowing correction because the plot reference is scientific record content.
4. **Archived plots:** I recommend accepting new offline visits and corrections whenever the plot UUID remains historically resolvable, even if it has since been archived.
5. **Response semantics:** I recommend that stable acceptance results describe commit-time status, conflict retrieval return one token-bound snapshot, and rejection categories be machine-distinguishable.
6. **Decision record:** The whole-visit versus field-aware choice is consequential enough for a standalone decision document. Would you like that, or is the existing Decisions & Alternatives row sufficient?

Please approve these recommendations or give numbered changes. I’ll then finalize the LLD before drafting the `REC-*` EARS requirements.