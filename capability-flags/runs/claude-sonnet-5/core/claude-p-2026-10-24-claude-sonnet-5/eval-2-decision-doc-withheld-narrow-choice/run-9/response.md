I've finished the Phase 2 LLD work for the preview cache's eviction policy — here's where it stands.

**Updated `docs/intent/previews/previews-design.md`:**
- Private Cache section now describes 2Q concretely: a once-seen queue for freshly admitted sheets and a reused queue for sheets requested again, with eviction drawing from once-seen first and falling back to reused only when once-seen is empty.
- Added a **Decisions & Alternatives** table recording the choice (2Q over LRU and frequency-with-aging) with the rationale from your message.
- Added **Open Questions & Future Decisions**: the once-seen/reused size-split value and tuning method are still unset — deferred.
- Also fixed `docs/high-level-design.md`'s Previews bullet, which still said "its eviction policy remains open" — now says it uses 2Q.

**Decision doc offer:** this choice has real competing criteria (bookkeeping cost, scan resistance, retention) and a downstream parameter (the queue-size split) that will get sized around it — a cold reader might reasonably ask "why not LRU?" months from now. I can write a full decision doc instead of just the table row if you want that preserved at higher resolution. Otherwise the row stands as-is. Your call — happy to leave it as the row given you're done arguing about this.

**LLD edge-case probe** (delegated to a blind reader, scoped to this doc's own gaps — not cross-component) surfaced these before I write EARS specs:

1. A hit *inside* the reused queue — does it reorder anything, or is the reused queue unordered until eviction needs a victim?
2. Victim-selection order once eviction falls back to the reused queue — undefined in the current text.
3. Does "requested more than once" mean *ever*, or *while still resident*? No ghost/history list is described, so a re-rendered sheet's prior popularity is currently forgotten.
4. Race between a sheet being evicted and a concurrent hit on that same key.
5. Does a failed render job ever touch queue state, or is retry guaranteed to start clean?
6. Can the reused queue alone grow past 12 GiB if once-seen is empty (comparison-heavy workload)?
7. Is the size split a hard per-queue cap or a soft target only enforced at eviction time?
8. Ordering guarantee between a promoting hit and a concurrent eviction targeting the same entry — can a hit "rescue" a victim?
9. What happens if a single new sheet exceeds 12 GiB even after evicting everything?

Which of these do you want settled in the LLD now, and which should I carry forward as open questions into the EARS/implementation phases? Once you triage these (and tell me row-vs-doc on the decision), I'll move to Phase 3 (EARS).