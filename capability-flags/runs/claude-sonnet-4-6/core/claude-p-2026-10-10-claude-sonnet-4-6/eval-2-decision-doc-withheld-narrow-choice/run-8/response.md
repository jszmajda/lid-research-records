LLD is written. Now for the edge-case probe, then the Phase 2 stop.

---

## Phase 2 — LLD update complete

I've updated `docs/intent/previews/previews-design.md` with the 2Q mechanics and updated the HLD to reflect the settled policy.

**What changed in the LLD:**
- Replaced the open-question eviction-policy section with a full 2Q mechanics description: probationary queue (3 GiB, evict by oldest admission time), protected queue (9 GiB, evict by LRU on re-access), 200-only promotion trigger, serialized admission/promotion via the existing cache lock.
- Added a Decisions & Alternatives table with the eviction policy choice, promotion trigger choice, and queue-size-split choice, all with filled rationale.
- Moved the still-open single-sheet-exceeds-cap invariant to Deferred.
- Minor HLD edit: "eviction policy remains open" → "2Q eviction policy."

No decision doc offered: the choice lands cleanly — the 3 GiB/9 GiB split and the scan-resistance rationale will read as native to any reader who understands the screening/comparison workload, and the review API is explicitly isolated from the policy so no sibling node is sized around it.

---

### LLD edge-case probe

Gaps in *this LLD's own mechanics*, not cross-spec interactions (those come in Phase 4):

1. **Hit tracking for promotion** — the LLD says "a second distinct request served as a 200 triggers promotion," but doesn't say how the entry tracks whether it has ever been served from probationary. The mechanism (a per-entry boolean flag, a hit counter, something else) is unspecified. This needs to be in the LLD before specs are written against it.

2. **LRU update on re-hit in protected** — the LLD defines protected eviction as LRU, but never says that serving a 200 for a protected entry refreshes its last-access timestamp. A reader could implement protected eviction as FIFO-from-promotion-time and satisfy the current text.

3. **Multi-entry eviction for promotion** — "evict the least-recently-accessed entry from protected before completing the promotion" evicts exactly one entry. If protected entries vary in size (and the LLD doesn't say they're uniformly sized), a single eviction might not free enough room. With today's ~2 MiB sheets and a 9 GiB cap this never triggers, but the invariant "evict until the queue fits" vs. "evict one entry" should be stated explicitly.

4. **Startup validation of the queue-size split** — the LLD says the split is configurable at startup but doesn't say whether the worker validates that `probationary_cap + protected_cap ≤ 12 GiB`. An operator could accidentally configure 7 + 9 = 16 GiB, silently exceeding the disk budget.

5. **Read/eviction isolation** — admission and promotion are serialized through the cache lock, but the LLD doesn't say whether a cache read (returning JPEG bytes) holds the lock. If reads don't hold the lock, a sheet could be evicted and deleted from disk while it is being streamed to a client.

**Suggested triage:**
- Items 1 and 2 are spec-blocking: the promotion and LRU behaviors have EARS specs pending and the mechanism must be explicit before those are written.
- Item 3 is worth clarifying with a single sentence ("evict until the queue fits within its cap").
- Items 4 and 5 are implementation-level invariants; they could be deferred to the code phase or specified now depending on how much you want the LLD to pin them.

How would you like to handle 1, 2, and 3 — should I patch those into the LLD now? And for 4 and 5, defer to Deferred or specify?