The 2Q decision is recorded and the design is finished at the LLD level. Per the workflow, this is the Phase 2 stop — please review before I cascade to EARS specs.

**What changed**

- `docs/intent/previews/previews-design.md` — "Private Cache" now specifies 2Q concretely: **A1-in** (FIFO, 3 GiB ceiling — first-appearance sheets), **Am** (LRU, remaining budget — sheets requested twice or more), and a byteless **A1-out ghost list** (2048 keys) so a re-requested one-off is recognized as reuse and admitted straight to Am. Eviction drains A1-in's FIFO tail first (feeding the ghost list), then Am's LRU tail. A Decisions & Alternatives table records the 2Q choice over LRU and aged frequency, and the A1-in/ghost parameters sit in Deferred for pilot tuning. Nothing in the HTTP contract, render queue, or disk budget moved — the change is entirely inside the worker's replacement bookkeeping.
- `docs/high-level-design.md` — replaced "Its eviction policy remains open" with the settled 2Q pointer.

**Coherence pre-flight:** PREVIEW-001–005 still trace to the LLD; no contradiction — PREVIEW-004's generic eviction requirement is now realized by the 2Q mechanism (its wording will get an EVICT-facet update in Phase 3).

**LLD edge-case probe — gaps to triage** (fix in the LLD now, or defer as open questions?):

1. **Miss-after-admission race** — a client holds a 202 ticket, the sheet is admitted, then immediately evicted by a large concurrent admission before the retry lands. The retry becomes an ordinary miss and re-renders. I consider this acceptable ("a miss is ordinary behavior"), but the LLD doesn't say so.
2. **Ghost-list overflow** — implied FIFO drop of the oldest key when 2048 is exceeded; not stated.
3. **Promotion into a full Am** — a hit promoting a sheet from A1-in to Am when Am is at budget: eviction from Am's tail is implied by the byte rules but never stated outright.
4. **Oversized sheet** — a sheet larger than the A1-in ceiling (or hypothetically the whole budget) has no defined admission path. Impractical at ~2 MiB/sheet, but currently undefined.

**One offer, then I'll stop asking:** this choice cleared the bar for a full decision doc (credible options traded on more than one criterion, and queue sizing will be tuned against it later). Want me to write `docs/intent/previews/decisions/eviction-policy.md` memorializing the three-way comparison, or is the Decisions & Alternatives row enough?

Please review the updated LLD, tell me how to triage the four probe gaps, and answer the decision-doc question — on your go-ahead I'll draft the EARS spec updates (Phase 3).