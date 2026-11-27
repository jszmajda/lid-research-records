Added [Decision: Whole-Visit Revisions](docs/intent/record-store/decisions/whole-visit-revisions.md) and linked it from the record-store design.

It records:
- **Why whole-visit revisions wins:** preserving scientific relationships and avoiding maintained merge rules outweigh the larger review queue.
- **The strongest case for field-aware merging:** fewer repetitive reviews and more complete Friday exports. Reconsidering it would require both measured queue pressure and confidence that scientific dependencies can be maintained in the rules.
- **Tablet obligations:** base revision IDs, complete payloads, durable retry envelopes, and clear accepted-for-review outcomes.
- **Review/export obligations:** whole-revision comparison and provenance, version-checked resolutions, and exclusion of unresolved visits from CSV.

Documentation checks passed.

To finish the record-store contract, let’s settle the next choice: **may a coordinator author a new complete revision during resolution, or must they select an existing submitted revision?**

Selecting an existing revision preserves one worker’s intact submission but may require a separate correction afterward. Authoring a new revision allows explicit scientific reconciliation, with the coordinator and contributing submissions recorded as provenance.