I recorded **whole-visit revisions** in `docs/intent/record-store/record-store-design.md` and updated the HLD’s status. The existing record-store specs are broadly compatible but don’t yet specify the revision rules; there are no tests or implementation in the repository.

One decision is needed to complete the record-store contract:

**How may a coordinator resolve competing revisions?**

1. **Select an existing revision only.** The chosen submission becomes current intact. Combining corrections requires a separate edit, which preserves a clear distinction between selection and correction but may add work.
2. **Select or author a complete resolved revision.** A coordinator can deliberately combine corrections after comparing submissions. The store records the coordinator and contributing submissions, but must support and retain this additional revision.

For example, if one worker corrects an observer name and another adds a species, option 1 requires choosing one submission first; option 2 lets the coordinator deliberately retain both corrections in a new revision.

Which should the design support?

Separately, the concurrency choice trades review workload against scientific risk and affects both downstream designs. Would you like its reasoning recorded in a full decision document, or is the decision table entry sufficient?