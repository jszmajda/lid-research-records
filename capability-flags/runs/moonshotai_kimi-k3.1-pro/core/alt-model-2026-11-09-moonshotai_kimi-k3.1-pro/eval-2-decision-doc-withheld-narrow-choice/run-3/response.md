## Phase 2 — Preview design ready for review

I selected 2Q as requested and updated:

- `docs/intent/previews/previews-design.md`
- `docs/high-level-design.md` to remove the obsolete “eviction policy remains open” note

The design now specifies:

- **A1in:** FIFO resident sheets seen once.
- **Am:** LRU resident sheets with demonstrated reuse.
- **A1out:** bounded FIFO ghost keys evicted from A1in.
- A1in hits promote to Am; Am hits refresh recency.
- Cold misses enter A1in; A1out-backed misses enter Am after rendering.
- Joining an existing pending render does not count as reuse.
- Eviction prefers A1in above its configurable target, otherwise Am’s LRU entry.
- A1in is sized by JPEG bytes; A1out by ghost-key count.
- All policy metadata stays private to the preview worker. The API, pending protocol, render queue, concurrency, and 12 GiB budget remain unchanged.
- Initial queue bounds remain deferred for workload-based tuning.

LRU and aged-frequency alternatives, plus the rationale for choosing 2Q, are recorded in the LLD’s Decisions & Alternatives table.

### Edge cases requiring triage

The design probe found these unresolved cases:

1. **Oversized sheet:** Deliver a JPEG larger than 12 GiB without caching it, or treat rendering as failed?
2. **Ghost removal:** Remove an A1out key immediately when a hit begins rendering, or when the completed sheet enters Am?
3. **Promotion pressure:** When an A1in hit promotes a sheet to Am, which entry is evicted if space is needed, and are queue shares soft targets or hard caps?
4. **Ghost expiring during render:** If the originating A1out key disappears before rendering completes, should the sheet still enter Am based on the original lookup?
5. **Completion atomicity:** Should cache admission and deduplication-map removal appear atomic to incoming requests?
6. **Failed A1out-backed render:** Preserve the ghost key so a retry enters Am after success, or discard it?
7. **Configuration limits:** Should 0% and 100% A1in shares and a zero-key A1out be valid?

Please identify which gaps to settle in the LLD and which to defer, then approve or request changes to the design. I’ll stop here before drafting EARS requirements.