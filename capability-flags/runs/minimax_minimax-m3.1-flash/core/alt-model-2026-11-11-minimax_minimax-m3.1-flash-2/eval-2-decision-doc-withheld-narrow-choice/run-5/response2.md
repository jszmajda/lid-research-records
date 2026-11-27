Done — the decision doc is in place.

**`docs/intent/previews/decisions/2q-replacement-policy.md`** (new, `node: previews`), linked from the `previews` design's Decisions row and its Resolved list.

Structure follows the house template: Context (why the cache's replacement policy is the editors' problem), Decision Elements (two gates — scan resistance, bounded carry-over between projects — plus six weighted criteria, with the "Reuse over recency" tenet named as the basis for the major criterion), Options in the Domain (2Q, LRU, frequency-with-aging, each at its strongest honest representation, with verdicts and basis), and Selection (what 2Q wins, what it gives up, what it obliges).

Two blind cold reads ran over it, and both found real defects I fixed rather than papered over:

- The first read showed my "2Q passes the carry-over gate" verdict wasn't supported by 2Q's own mechanics — previous-project sheets *do* hold protected space until pressure reaches them. I rewrote the gate to "bounded carry-over" (displaced by ordinary cache pressure, never kept alive by a decay mechanism) and stated the cost plainly in both the analysis and the Selection.
- The second read found the 2Q demonstration contradicted the design (the comparison sheets would have been evicted as first-use entries), an overstated protection verdict, and a criterion that was never weighed. All corrected.

The doc carries no requirement IDs, per house rule. It also records the honest limits of the choice: a working set above the 6 GiB hot cap gets only partial protection, a briefly-reused-then-abandoned sheet occupies hot space until recency evicts it, and the ghost list costs worker memory outside the JPEG budget.

**Still open for you:** the two starting numbers (hot cap 6 GiB, ghost list 50,000 keys — the split you said we'd tune), and the two deferred questions the doc now points at: whether hot-queue evictions should leave a ghost entry, and whether counts survive a restart. Phases 5–6 (tests, code) still can't run — this repo is design docs only.