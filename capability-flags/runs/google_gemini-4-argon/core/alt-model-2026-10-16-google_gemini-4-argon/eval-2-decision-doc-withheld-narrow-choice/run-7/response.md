I have updated `docs/intent/previews/previews-design.md` to specify 2Q replacement and recorded the choice, alternatives (LRU, frequency-based eviction with aging), and rationale in its `Decisions & Alternatives` table, and removed the "remains open" note in `docs/high-level-design.md`. (Because the eviction policy is strictly local to the preview worker's private cache and leaves the HLD architecture and sibling nodes unchanged, a row in the LLD's `Decisions & Alternatives` table is sufficient without a separate decision doc.)

### Updated `docs/intent/previews/previews-design.md` (excerpt)

```markdown
## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

The cache uses 2Q replacement to isolate comparison working sets from one-off sequential screenings:

- **Probationary queue ($A1_{in}$, FIFO)**: Newly rendered contact sheets enter $A1_{in}$. When $A1_{in}$ exceeds its byte budget, evicted sheets lose their cached JPEG bytes, while their keys move to the bounded ghost history queue ($A1_{out}$, FIFO).
- **Ghost history queue ($A1_{out}$, FIFO)**: Holds keys only (no JPEG bytes) for recently evicted $A1_{in}$ entries, bounded by key count.
- **Protected queue ($A_m$, LRU)**: When a rendered sheet whose key is in $A1_{out}$ is admitted again, it enters $A_m$ instead of $A1_{in}$. Cache hits on entries already in $A_m$ move them to the most-recently-used position; hits on entries still in $A1_{in}$ serve the JPEG without promoting them to $A_m$. When the cache must evict beyond $A1_{in}$'s budget, it evicts the least-recently-used entries from $A_m$.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q ($A1_{in}$ FIFO, $A1_{out}$ ghost FIFO, $A_m$ LRU) | LRU; frequency-based eviction with aging | Documentary editors alternate long sequential screenings with repeated comparisons of a small clip set. 2Q isolates reused comparison sheets in $A_m$ from single-pass screening scans at the cost of extra queue bookkeeping and split parameters, whereas plain LRU evicts comparison sheets during long scans and aged frequency counters add ongoing decay overhead and adapt more slowly when editors switch projects. All replacement tracking remains private to the preview worker. |

## Open Questions & Future Decisions

### Deferred
1. Queue split parameters ($A1_{in}$ share of the 12 GiB byte budget and $A1_{out}$ ghost key capacity) and exact promotion rules on in-window hits.
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review the draft above and let me know how you want to handle these LLD-level questions (fix in the LLD now vs. defer as open questions):

1. **Queue split and ghost capacity ($K_{in}$ / $K_{out}$)**: What portion of the 12 GiB budget should be allocated to $A1_{in}$ vs. $A_m$ (e.g., 25% / 3 GiB for $A1_{in}$, 75% / 9 GiB for $A_m$), and how many ghost keys should $A1_{out}$ retain (e.g., 3,000 keys, roughly half the ~6,000-sheet cache capacity at 2 MiB/sheet)?
2. **Hits while still in $A1_{in}$ (classic 2Q vs. Simplified 2Q)**: Standard 2Q intentionally does *not* promote an entry on a hit while it is still inside $A1_{in}$ (filtering out correlated burst hits from a single screening session, promoting only when re-requested after leaving $A1_{in}$ into $A1_{out}$). However, for editors comparing a small set of clips right after first opening them, do you want strict 2Q (promote only via $A1_{out}$) or direct promotion from $A1_{in}$ to $A_m$ on a second hit?
3. **Variable sheet byte sizes during eviction**: Since the 12 GiB limit is measured in bytes (typical sheet ~2 MiB, but actual JPEG sizes vary), should $A1_{in}$ and $A_m$ budgets be enforced strictly by byte sum (evicting one or more entries until `used_bytes + new_sheet_bytes <= budget`), and what happens if a single abnormally large contact sheet exceeds the target $A1_{in}$ byte threshold?
4. **Metadata persistence across worker restarts**:On preview worker restart, does the worker rebuild its 2Q queues from files on disk (or start with an empty cache directory), or is queue order ephemeral in memory?
5. **Render queue saturation & timeout**: The LLD specifies at most 4 active rendering jobs in a FIFO queue, but no bound on queued waiting jobs or job failure timeout—should the queue be bounded or unbounded during the pilot?

How would you like to resolve or defer these items, and do you approve the LLD changes to proceed to Phase 3 (EARS specs)?