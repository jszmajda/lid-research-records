Done. The previews design is finished with 2Q — here's what changed, followed by the review stops.

**Design — `docs/intent/previews/previews-design.md`**
- New **Cache Replacement (2Q)** section: A1 is a FIFO recency queue that absorbs one-pass screening traffic; A2 is an LRU queue holding sheets that got a second access. New admissions enter A1; an A1 hit promotes to A2's MRU end; an A2 hit refreshes position. Eviction: when A1 exceeds its bound, drop A1's LRU entry entirely (it never had a second access); otherwise evict A2's LRU. Eviction always runs before admission to hold the 12 GiB byte bound.
- A1 is bounded by entry count (one quarter of entries) rather than bytes — sheets are near-uniform at ~2 MiB, so a count bound tracks the byte bound with cheaper bookkeeping. The split ratio is tunable after pilot observations.
- Added a **Decisions & Alternatives** table recording the 2Q choice against LRU and aged-frequency, with rationale, plus open questions (split tuning; re-request of an evicted A2 sheet re-enters via A1 — confirm during pilot).
- The old "eviction policy is still open" paragraph is gone; the external contract (200/202/404), four-job FIFO render queue, deduplication, and disk budget are untouched.

**Specs — `docs/intent/previews/previews-specs.md`** — added six EARS lines:
- PREVIEW-006 admit → A1 MRU end
- PREVIEW-007 A1 hit → promote to A2 MRU end
- PREVIEW-008 A2 hit → refresh to MRU end
- PREVIEW-009 A1 over its count bound → evict A1's LRU entry, discard data
- PREVIEW-010 eviction needed and A1 within bound → evict A2's LRU entry
- PREVIEW-011 any eviction happens before admission, holding 12 GiB

**Consistency check** — each spec line traces to the 2Q section; PREVIEW-004 (12 GiB eviction before admission) and PREVIEW-011 now overlap in subject, so 011 is phrased as the ordering rule over any eviction while 004 stays the byte-bound rule — tell me if you'd rather merge them. No contradictions with PREVIEW-001–005. I also updated the HLD to say the replacement policy is 2Q instead of "open," and removed its stale "for every eviction policy" wording. No code or tests exist yet, so the arrow currently ends at specs.

**Please review:**
1. The 2Q mechanics as written above — especially the A1-over-bound eviction rule, which silently drops a first-use sheet that had exactly one access.
2. The A1/A2 split default of one quarter, and whether you want it expressed as bytes rather than entry count.
3. Whether to merge PREVIEW-004 and PREVIEW-011.

On your approval, next phases are the intent-narrowing edge audit, then tests-first implementation.