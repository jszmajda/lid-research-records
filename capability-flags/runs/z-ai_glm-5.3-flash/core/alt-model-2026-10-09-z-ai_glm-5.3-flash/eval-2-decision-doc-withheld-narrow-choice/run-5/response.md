Phase 2 is done — the previews LLD now commits to 2Q, per your selection. Here's what landed (`docs/intent/previews/previews-design.md`):

**Cache Replacement (2Q)** — new section:

- **A1 — first-use queue** (FIFO, 4 GiB): every newly completed sheet enters here.
- **A2 — reused queue** (LRU, remainder of the 12 GiB budget, 8 GiB initially): only sheets hit again while in A1 enter here.
- Hit in A1 → promote to A2's MRU end (metadata-only move; the JPEG file doesn't move). Hit in A2 → refresh recency.
- On admission: place the new sheet in A1, then evict oldest-A1 first, and A2-LRU only once A1 is within its bound and the total still exceeds budget. A long screening cycles A1 without displacing comparison sheets in A2.

The "eviction policy still open" paragraph is gone, and the HLD's architecture line now says the worker's cache uses 2Q instead of "policy remains open". New Decisions & Alternatives rows record: 2Q over LRU and aged-frequency; ghost lists omitted (a 450 ms re-render beats the extra bookkeeping); byte-based 4/8 GiB split, to be tuned in the pilot.

**LLD edge-case probe** — gaps I found pointed at this LLD; triage which to fix now vs. defer:

1. A single completed sheet larger than 12 GiB: admit it (displacing everything) or serve it once from temp output and never cache it? Currently listed as a deferred open question.
2. Cache persistence across worker restart: are surviving JPEG files re-adopted into the queues (and in what order), or does the cache start empty and repopulate on demand? The design is currently silent.
3. A render completing for a key whose entry was just evicted: re-admit into A1 (I'd say yes, no spec needed) — confirm.
4. Promotion when A2 is already at its bound: does promotion evict A2-LRU immediately, or can the cache briefly exceed the split? Currently unspecified.

**One offer, then I'll stop pushing:** the 2Q choice clears the bar for a full decision doc (three live options, multiple criteria, the split parameter will be sized around it). Say the word and I'll write one in `docs/intent/previews/decisions/`; otherwise the Decisions table row above is the whole record, and I won't ask again.

Please review the section above and triage the probe gaps. On your approval I'll move to Phase 3 (EARS updates — PREVIEW-004 will get sibling specs for A1 admission, promotion, and eviction order) and stop again for your review there.