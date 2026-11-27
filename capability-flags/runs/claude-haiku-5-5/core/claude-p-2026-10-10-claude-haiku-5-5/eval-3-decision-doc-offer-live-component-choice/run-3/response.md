**Phase 1 (HLD check) is done. Stopping for your review before the record-store LLD.**

Whole-visit revisions is the choice, and it's recorded at the record-store node, since the HLD says the concurrency mechanism belongs there. The HLD covers this domain, and the only change it needs is the record-store state:

- `docs/high-level-design.md`: the record-store state now reads "Drafted; concurrency policy: whole-visit revisions" instead of "concurrency choice open". Nothing else in the HLD changed.

**Proposed tenet** (not written yet): *Keep each submitted visit whole as the unit of coordinator review, even when that adds review work.* It follows from your choice. The reverse, "merge field edits automatically over keeping visits whole," is a defensible position, so it passes the platitude test. It states a lean rather than a triggered action, so it belongs under Tenets. Should I add it, change the wording, or leave it out?

**Decision record:** this choice will stay live for a cold reader. Two credible options were traded against review volume, submission size, and scientific-relationship safety, and tablet-sync and review-export will be sized around it. I offer to record it as a decision doc at `docs/intent/record-store/decisions/concurrency-policy.md`, with a row in the record-store Decisions table pointing to it. Otherwise I'll record it as a row only. Which do you want?

**Next:** after you approve the HLD (and answer the tenet and decision-record questions), Phase 2 rewrites `record-store-design.md` as a complete LLD around whole-visit revisions. Then come the EARS specs, the edge audit, tests, and code. Tablet-sync and review-export wait for the record-store contract.