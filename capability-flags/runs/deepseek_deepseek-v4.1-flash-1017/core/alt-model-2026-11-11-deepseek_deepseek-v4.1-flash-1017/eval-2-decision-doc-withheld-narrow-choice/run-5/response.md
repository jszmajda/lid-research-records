Phase 1 check: the change is local to the preview node, so the HLD only needed its stale "eviction policy remains open" line replaced with "2Q replacement policy."

Phase 2 — Previews LLD drafted (`docs/intent/previews/previews-design.md`). The new `Private Cache` section now specifies:

- **A1in** — first-use sheets, JPEG bytes, FIFO. On a miss the completed sheet enters here.
- **A1out** — keys of sheets recently evicted from A1in, no JPEG bytes, FIFO. A ghost hit admits directly to Am.
- **Am** — sheets seen at least twice, JPEG bytes, LRU. A hit on A1in promotes here; a hit on Am refreshes it.
- Admission over 12 GiB evicts from A1in first, then the least-recent end of Am.
- A one-use sheet in a long screening cycles through A1in/A1out without displacing a reused comparison sheet on Am. Ghost keys are metadata and don't count toward the 12 GiB JPEG bound.
- The split and A1out bound are worker config, with provisional starting values of 3 GiB A1in / 9 GiB Am, and A1out capped at the number of A1in entries that byte share can hold.

The eviction choice is recorded as a Decisions & Alternatives row (2Q vs. LRU vs. aged frequency, with the tradeoffs); a separate decision doc isn't warranted since the choice stays inside this one node. The split is noted under Deferred.

Before I move to EARS specs:

1. Approve the LLD as written, or mark changes?
2. For the provisional split — keep **3 GiB A1in / 9 GiB Am** (A1out ≈ A1in entry count) as the starting configuration, or set a different split and A1out bound now?