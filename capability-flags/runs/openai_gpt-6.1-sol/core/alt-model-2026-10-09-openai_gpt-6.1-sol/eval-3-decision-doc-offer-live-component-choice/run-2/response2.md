Written in [`docs/intent/record-store/decisions/concurrent-visit-edits.md`](docs/intent/record-store/decisions/concurrent-visit-edits.md) and linked from the record-store LLD.

The document covers:
- **Why whole-visit revisions win:** preserving scientifically related observations and avoiding maintained merge rules outweigh a smaller review queue.
- **The strongest case for field-aware merging:** conservative rules can protect known relationships while reducing coordinator work. Reconsidering it would make sense if measured queue volume or Friday omissions become unacceptable and the team can support domain-owned rules and field-level provenance.
- **Tablet obligations:** durable base revision IDs, complete payloads, stable retry keys, and distinguishing stored submissions from resolved current visits.
- **Review/export obligations:** whole-revision comparison, traceable coordinator outcomes, protection against stale resolutions, and exclusion of unresolved visits from CSV.

The decision is consistent with the HLD and LLD; `git diff --check` passed.

To finish the record-store contract, let’s take the remaining choices one at a time:

**While a visit has competing revisions, should retrieval expose the previously current revision as explicitly provisional, or report no usable current revision until resolution?**

The former keeps a reference available but risks readers treating it as settled. The latter makes the uncertainty explicit; history and competing revisions would still be available for comparison.