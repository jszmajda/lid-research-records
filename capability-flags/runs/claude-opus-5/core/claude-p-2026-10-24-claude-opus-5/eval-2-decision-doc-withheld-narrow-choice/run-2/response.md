Phase 2 output — the previews LLD now carries 2Q, with the edge-case probe below it.

**What changed**

`docs/intent/previews/previews-design.md` — the "eviction policy is still open" paragraph is replaced by a `### Replacement` subsection under Private Cache, plus new Decisions & Alternatives and Open Questions sections:

> **Replacement is 2Q.** Cached sheets live in one of two queues, and a third structure remembers keys without holding bytes:
> - **First-use queue** — sheets fetched once and not since re-requested, ordered by admission and evicted from the oldest end (FIFO). Budgeted at 3 GiB of the 12 GiB.
> - **Reuse queue** — sheets re-requested at least once while cached or while remembered, ordered by most recent access (LRU). Holds the remaining 9 GiB.
> - **Recent-eviction key list** — the keys of sheets evicted from the first-use queue, with no JPEG data, capped at 3,000 keys and dropped from the oldest end. A key here costs no part of the 12 GiB budget.
>
> A completed sheet whose key appears in the recent-eviction key list is admitted to the reuse queue, and that key is removed from the list; any other completed sheet is admitted to the first-use queue. A hit in the first-use queue serves the JPEG and changes no ordering, so a screening that touches each sheet once cannot promote its sheets past the comparison sheets in the reuse queue. A hit in the reuse queue serves the JPEG and makes that entry the most recently used.
>
> Admission evicts until both the 12 GiB total and the 3 GiB first-use budget hold: while the first-use queue is over its budget, its oldest sheet is evicted and its key is recorded in the recent-eviction key list; otherwise the least recently used sheet of the reuse queue is evicted and its key is forgotten.
>
> The split is sized for the pilot's 2 MiB sheets: about 1,500 one-use sheets in flight before a screening starts displacing itself, and about 4,500 reused sheets retained. Both budgets and the key-list cap are worker configuration, expected to be retuned once pilot hit rates are observed.

Decisions & Alternatives has three rows: the policy choice (2Q, with LRU and aged frequency counts named as rejected and why), the 3 GiB / 9 GiB / 3,000-key split, and metadata staying worker-private. I recorded the choice as a row rather than offering a decision doc — every candidate's effect was confined to the preview worker's own cache, which is the one thing that keeps a long-debated choice from needing a standalone doc.

Two HLD lines went stale the moment you picked, so I fixed them in `docs/high-level-design.md` — say if you'd rather they read differently: the Previews architecture bullet now ends "a private 12 GiB cache with its replacement policy" instead of "Its eviction policy remains open", and the goal "…through the same interface for every eviction policy" now reads "…whichever previews happen to be cached."

**Edge-case probe — gaps inside this LLD.** Which of these do you want settled in the LLD now, and which deferred?

1. **A frequently-hit sheet that was never evicted never reaches the reuse queue.** As written, promotion happens only via the key list — so an editor comparing six freshly-rendered sheets all morning keeps hitting them in the first-use queue, where hits change no ordering, and a concurrent screening can FIFO them out from under her. This is textbook 2Q behavior, and it's also the exact case you're buying 2Q to protect. The alternative is promoting on a second hit while still resident, which costs a hit counter per first-use entry.
2. **Do concurrent waiters on one job ticket count as reuse?** PREVIEW-003 collapses N concurrent misses into one render. When it completes, the LLD admits the sheet to the first-use queue regardless of whether one editor or nine were waiting.
3. **A brand-new one-use sheet can evict a reused sheet.** When the first-use queue is under its 3 GiB budget but the total is at 12 GiB, the eviction rule takes the reuse queue's LRU entry. Intended, but currently only implied by the rule's ordering.
4. **A renderer-version bump cold-starts everything.** Every key changes at once, so the whole cache is unreachable-but-resident and the key list holds keys that can never match again. Nothing says whether old-version entries are bulk-evicted or whether the key list is cleared.
5. **Restart behavior is unspecified.** Whether cached JPEGs on disk are reclaimed at startup, and if so which queue rebuilt entries enter and what happens to the (in-memory) key list.
6. **Eviction racing an in-flight response.** Nothing states that a sheet chosen for eviction stays readable until a response already streaming it finishes.
7. **Confirm:** reuse-queue evictions are forgotten entirely rather than also entering the key list.

No EARS changes yet — Phase 3 will extend the preview specs (PREVIEW-004 currently says only that the 12 GiB bound holds) once you've ruled on the above.