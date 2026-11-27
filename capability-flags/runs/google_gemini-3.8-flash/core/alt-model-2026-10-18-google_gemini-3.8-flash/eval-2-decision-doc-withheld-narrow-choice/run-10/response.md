I have updated `docs/high-level-design.md` and `docs/intent/previews/previews-design.md` to incorporate the 2Q eviction policy for the preview cache and recorded the decision and alternatives.

### Edge-Case Probe (Phase 2)
1. **Queue sizing split**: What ratio or maximum size is assigned to the probationary queue vs. the hot queue (e.g., 25% / 75% or 3 GiB / 9 GiB)?
2. **Ghost cache / out-list ($A1_{out}$)**: Should the 2Q implementation track out-of-cache references via a ghost cache of keys to promote items directly to the hot queue on re-fetch, or strictly promote within resident memory?
3. **Concurrent evictions**: When multiple rendering jobs complete concurrently and both require eviction, how are queue locks managed to avoid over-eviction or race conditions?
4. **Oversized previews**: If an unusually large sheet exceeds the probationary budget by itself, does it evict immediately or bypass probationary allocation?

### Decision Doc Option
Per LID guidelines, would you like to record this choice as a full standalone decision doc in `docs/intent/previews/decisions/` alongside the table row, or does the Decisions & Alternatives table row suffice?

Please review the LLD update, let me know your thoughts on the edge cases and decision doc, and confirm if we may proceed to Phase 3 (EARS specs).