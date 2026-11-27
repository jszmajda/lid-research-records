Design is finalized. Here's the Phase 2 + Phase 3 output for your review.

## What changed

**`docs/intent/previews/previews-design.md`** — "Eviction Policy: 2Q" replaces the open-question paragraph:

- **Queues**: A1in (FIFO, first admissions, holds data), A1out (FIFO, *keys only*, records once-seen-and-discarded sheets), Am (LRU, holds data for entries that proved reuse). Comparison sheets revisited during comparison sessions accumulate in Am and are protected from big-screening scans — the property you chose 2Q for.
- **Admission**: first-time completions go to A1in; completions whose key is in A1out go to Am (second access proves reuse); an A1out hit is a data miss and renders normally.
- **Queue Mechanics and Invariants** (added after the zero-context probe — see below): the 12 GiB byte bound is authoritative over the entry-count queue capacities; entries with pending job tickets are never eviction victims; failed renders purge their key from all three queues; Am overflow demotes keys to A1out rather than discarding them, so reuse can be re-proven.
- **Decisions & Alternatives row**: 2Q chosen over LRU and aged frequency counts, with the rationale from your meetings. Since the choice affects only this node, I recorded a row rather than offering a decision doc — say the word if you'd rather have the standalone doc.
- **Deferred open questions**: the initial A1in/A1out/Am size split (tune during implementation against real screening workloads), and behavior if a single sheet ever exceeded 12 GiB (expected unreachable at ~2 MiB sheets).

**`docs/high-level-design.md`** — the "eviction policy remains open" line now says 2Q, private to the worker; the "for every eviction policy" goal became "regardless of cache state." Review API segment untouched — its fixed-interface contract was never policy-dependent.

**`docs/intent/previews/previews-specs.md`** — PREVIEW-004 revised (victim order, non-pending restriction) and eleven new specs, PREVIEW-006 through PREVIEW-014, covering A1in admission, A1out promotion and late-discard races, all three overflow rules, Am LRU touch, the pending-job pin, and failure-time queue purge. Consistency check: every LLD behavior has a spec, no contradictions (007/008 have disjoint triggers), and each spec carries its A1out/A1in/Am context inline so it survives a grep without its section.

## Probe gaps — my dispositions for you to check

A zero-context probe raised nine "what happens when…" questions. I resolved seven in the LLD's invariants section: evicting a pending entry (never — 013), re-request while key sits in A1out with a pending job (renders; promotes at admission — 007), byte-bound vs queue-overflow eviction in one admission (one pass, byte bound authoritative, never self-evicting), count-vs-byte capacity disagreement (bytes win), failed-render metadata (full purge — 014), Am-evicted entry re-requested (demoted to A1out first), and A1out discard racing render completion (takes A1in path — 008). Two I left as deferred open questions: the queue-size split, and the >12 GiB single-sheet case. Please sanity-check especially the "never evict pending entries" invariant — an alternative reading lets eviction take pending entries since job-ticket semantics are unchanged; I chose pinning as the simpler, safer rule, but it's a genuine fork.

**Stop for your review.** If the LLD and specs read right, the next steps are Phase 4's cross-spec divergence check (mainly: does any spec let a blind implementer double-count a reuse event?) and then tests-first implementation of the 2Q queues — say "go" and I'll proceed.