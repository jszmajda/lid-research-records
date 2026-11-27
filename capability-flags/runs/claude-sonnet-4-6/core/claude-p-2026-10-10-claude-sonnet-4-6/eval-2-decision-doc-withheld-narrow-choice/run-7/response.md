Good. Now the Phase 2 edge-case probe — "what happens when..." questions aimed at gaps inside this LLD:

1. **Sheet size vs. K_in**: A typical sheet is 2 MiB; K_in is 3 GiB. But the LLD doesn't state whether a single sheet can exceed K_in. If it could, the eviction loop would drain all of Ain and then evict from Am just to admit one entry to Ain — an odd result. A max-sheet-size bound, or a rule that sheets larger than K_in bypass straight to Am, should be stated.

2. **Am evictions and Aout**: The LLD says evictions from Ain feed Aout; it doesn't explicitly say Am evictions do not. A reader could wonder whether keys evicted from Am should re-enter Aout so another hit can recycle them. The current rule (Am evictions are fully discarded) is implied but unstated.

3. **Concurrent eviction**: Up to four render jobs run simultaneously. If two complete at the same time and both need to evict, the LLD doesn't say whether the eviction loop uses a lock. An unlocked race could allow both jobs to see a budget that looks acceptable after independent evictions, then both admit, landing over-budget.

4. **Aout size relative to screening depth**: N_out = 6 000 entries. A screening run larger than 6 000 distinct clips would cycle through Aout, so clips from the start of a very long run would be treated as "new" rather than "seen before" when revisited. The LLD notes that N_out should exceed a typical screening run, but doesn't state what "typical" is or how to validate the initial value.

5. **State on worker restart**: Ain, Aout, and Am are in-memory structures. On restart they are empty. The first revisit after a restart treats every sheet as "new," so comparison sheets enter Ain rather than Am and are at scan risk until they circulate through Ain and Aout at least once. This is consistent with "a cache miss is ordinary behavior" but the LLD doesn't state the startup behavior.

---

Here is the updated LLD for your review (Phase 2 stop):

---

**`docs/intent/previews/previews-design.md`** (relevant sections, post-update):

```
## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict
enough existing sheets to remain within that bound. Temporary render output is kept
separately and removed on completion or failure. Eviction never deletes source footage
or changes job-ticket semantics.

The cache uses a 2Q replacement policy, which separates first-use sheets from reused
sheets so that long sequential screenings cannot evict comparison sheets.

### 2Q Structures

Three in-memory structures track replacement state. No other component reads or writes them.

- **Ain** (FIFO, capped at K_in bytes of cached JPEG data): holds newly admitted sheets.
  Sequential-screening sheets stream through Ain and are evicted without reaching Am.
- **Aout** (FIFO, capped at N_out entries, no JPEG data): records the keys of sheets
  recently evicted from Ain. A key present in Aout signals the sheet was rendered at
  least once before.
- **Am** (LRU, remainder of the 12 GiB budget): holds sheets requested at least twice.
  Eviction follows LRU order within Am.

**Initial parameters**: K_in = 3 GiB, N_out = 6 000 entries, Am = 9 GiB. These are
starting values; tune based on the observed ratio of sequential screenings to comparison
sessions. N_out should comfortably exceed the number of distinct sheets in a typical
screening run so that revisited sheets are still findable in Aout.

### Admission and Eviction

On a cache miss for key k:
- Before placing k: if admitting k would exceed 12 GiB, evict first. Eviction removes
  the FIFO tail of Ain and appends its key to Aout (dropping the oldest Aout entry when
  N_out is full). Repeat until the budget would not be exceeded, then advance to Am
  eviction (LRU tail) only if Ain is empty and the budget is still exceeded.
- If k appears in Aout: admit to Am (LRU head); remove k from Aout.
- Otherwise: admit to Ain (FIFO tail).

On a cache hit for key k:
- If k is in Ain: no position change; FIFO aging continues.
- If k is in Am: move k to the LRU head of Am.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Cache replacement policy | 2Q: Ain FIFO + Am LRU + Aout ghost FIFO | LRU; frequency-based eviction with aging | 2Q isolates first-use entries from reused entries; sequential screenings drain through Ain without displacing comparison sheets already in Am. LRU provides no such isolation. Frequency-based counting retains popular clips but adds counter maintenance and can keep stale favorites in cache after editors switch projects. |
```

---

**Probe items for you to triage** (fix in LLD vs. defer as open questions):

1. **Sheet-larger-than-K_in**: Should the LLD state a max admissible sheet size, or specify that a sheet exceeding K_in bypasses Ain and goes directly to Am? Or is K_in large enough relative to the expected 2 MiB sheets that this case doesn't need covering?
2. **Am evictions and Aout**: Worth adding one explicit sentence that keys evicted from Am are discarded (not re-queued in Aout), so the in/out cycle is clear?
3. **Concurrent eviction**: Is this worker single-threaded for cache writes (so the eviction loop is implicitly safe), or does the LLD need to specify a lock around the eviction/admission pair?
4. **N_out sizing rationale**: The note says "comfortably exceed a typical screening run" — do you want to add a concrete ballpark (e.g., "editors screen at most ~2 000 clips in a single session")?
5. **Restart behavior**: State explicitly that Ain/Aout/Am are not persisted and are empty on restart, or leave it implicit under "a cache miss is ordinary behavior"?

Which of these do you want folded into the LLD now, and which should stay as open questions or be deferred?