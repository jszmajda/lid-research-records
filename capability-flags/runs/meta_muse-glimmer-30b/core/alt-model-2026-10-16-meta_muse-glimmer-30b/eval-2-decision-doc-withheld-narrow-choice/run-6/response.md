Phase 1 – HLD
Updated `docs/high-level-design.md` to record the chosen eviction policy:
- Previews now “owns rendering, pending jobs, and a private 12 GiB cache using a 2Q eviction policy.”

Phase 2 – LLD
Updated `docs/intent/previews/previews-design.md`:
- Private Cache now describes 2Q: two queues A1 (first-use) and Am (reused), new entries start in A1, a hit in A1 promotes to Am, hits in Am update recency in Am, eviction removes from A1 first, queue-size split is tunable, bookkeeping stays private and the external API/queue/concurrency/budget are unchanged.
- Added Decisions & Alternatives table recording the choice of 2Q over LRU and frequency-based eviction with aging, with rationale about protecting comparison sheets during sequential screenings and accepting extra bookkeeping.

Phase 3 – EARS
Updated `docs/intent/previews/previews-specs.md` with 2Q-specific requirements:
- PREVIEW-006: When evicting entries under the 2Q policy, the system SHALL evict from the first-use queue before evicting from the reused queue.
- PREVIEW-007: When a preview is admitted to cache, the system SHALL place it in the first-use queue.
- PREVIEW-008: When a cached preview in the first-use queue is accessed, the system SHALL promote it to the reused queue.
Consistency check: coverage of the 2Q mechanics is now in specs; no contradictions found. Scopes are explicit.

Phase 4 – Intent-narrowing edge audit
Before tests/code, please resolve:
1. Queue size split: the LLD notes a tunable A1/Am split. What split should be the default for the pilot, e.g. 50/50 by bytes or a specific ratio?
2. Empty A1 eviction: PREVIEW-006 prefers A1 over Am. If A1 is empty and admission still requires eviction, should the system then evict from Am, or block admission / grow the cache temporarily?
3. Promotion trigger: Does “accessed” for PREVIEW-008 mean any GET that returns 200 from cache, or also internal hits during deduplication/pending handling?

Confirm these points and I’ll proceed to tests-first and code per the LID workflow.
