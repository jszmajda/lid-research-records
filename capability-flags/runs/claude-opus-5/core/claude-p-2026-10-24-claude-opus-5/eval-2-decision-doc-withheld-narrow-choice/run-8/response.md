Done — Phase 2 is drafted and I've stopped there. 2Q is recorded as settled; no more options, no re-litigating.

**What landed**

`docs/intent/previews/previews-design.md` now has a **Replacement Policy** section specifying 2Q concretely: A1in (first-use, FIFO), Am (reused, LRU), A1out (keys only, the reuse signal), the four reference rules, the eviction order, and the sizing — A1in 3 GiB (~1,500 sheets), Am the remaining ~9 GiB, A1out 3,000 keys. Resident queues are accounted in bytes rather than entries, since sheet size varies with clip length and an entry-count split would let A1in overrun its share of disk.

Four Decisions & Alternatives rows carry the rationale: the policy choice itself (with LRU and aged-frequency named and why each was trimmed), the accounting unit, leaving A1in hits in place, and not recording Am evictions into A1out. I did **not** open a decision doc — all three options were credible, but the choice is contained entirely within this node; nothing else gets sized around it, so a row is the right home and a doc would just be a second place to keep the same thing current.

Two stale lines in `docs/high-level-design.md` said the policy was open: the Previews architecture bullet now reads "under a scan-resistant replacement policy," and the interface goal now says "whether a sheet was never rendered or was evicted" instead of "for every eviction policy."

**One thing I need from you**

The three numbers are the bookkeeping you agreed to pay for, and they're the only genuinely unsettled part left. The 25/75 split assumes a screening pass runs longer than ~1,500 sheets — below that, a pass never flushes A1in and Am is never pressured; far above it, comparison sheets are safe but a project switch takes longer to warm up. I've written 3 GiB / 9 GiB / 3,000 keys as starting values with a deferred note to retune against pilot measurements. Confirm those, or give me a different split.

**Edge probe (blind subagent, previews-internal only)** — triage which to fix in the LLD now vs. defer:

1. **Which bound terminates eviction** — my own text is ambiguous: is A1in's 3 GiB a continuously enforced invariant, or advisory under a 12 GiB total? If advisory, A1in can balloon and scan resistance is gone. I'd fix this one regardless.
2. **Worker restart** — are JPEGs and queue state persisted, JPEGs kept with queues rebuilt (and survivors land where?), or everything cold?
3. **Renderer-version bump** — every resident entry becomes permanently unreachable; is there a wholesale purge, or do dead sheets and stale A1out keys occupy the budget until normal eviction grinds them out?
4. **Render failure and in-flight pollers** — PREVIEW-005 releases the dedup entry, but holders of the ticket get... a 202 that silently restarts a deterministically failing render, or a failure outcome the three-outcome contract doesn't list?
5. **A1out removal timing** — at miss time or at admission time? At miss time, a failed render destroys the reuse signal and the retry is treated as first-use.
6. **Eviction during an in-flight 200** — reader finishes from an open file, truncates, or eviction waits? Nothing names refcounts.
7. **Admission that can't be satisfied** — may an oversized A1in-bound sheet evict from Am (crossing the split), and can admission be refused while still returning 200 with uncached bytes?
8. **Shared ticket reference counting** — do N concurrent requesters count as one reference or N, and is "a key is never both resident and in A1out" an asserted invariant?

My read: 1, 4, and 5 belong in the LLD now (1 is a real ambiguity in what I wrote; 4 and 5 are failure paths the fixed contract has to cover). 2 and 3 are lifecycle questions worth a sentence each. 6, 7, and 8 are implementation invariants I'd note as deferred unless you want them pinned. Tell me your split and the sizing call, and I'll revise the LLD and go to Phase 3 for the EARS.