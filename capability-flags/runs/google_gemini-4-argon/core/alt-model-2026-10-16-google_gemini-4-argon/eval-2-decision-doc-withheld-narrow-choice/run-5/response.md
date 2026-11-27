I have updated `docs/intent/previews/previews-design.md` to specify the 2Q replacement policy and recorded the choice—alongside LRU and aged frequency-based eviction—as a row in its **Decisions & Alternatives** table (since the choice is confined to the `previews` node and does not warrant a standalone decision doc). I also removed the note in `docs/high-level-design.md` that marked the eviction policy as open.

### Updated `docs/intent/previews/previews-design.md` (excerpt)

```markdown
## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

Cache eviction uses a 2Q policy to isolate repeatedly compared contact sheets from one-off sequential screening scans. Newly rendered sheets enter a probationary first-use queue (A1in). When an entry in A1in is evicted, its JPEG bytes are deleted from disk while its key moves to a bounded ghost-history queue (A1out). If a request hits an entry still resident in A1in or matches a key in A1out (after re-rendering and re-admission), the entry is promoted to the protected main LRU queue (Am). Within the 12 GiB resident budget, space is partitioned between A1in and Am; admissions evict from A1in when A1in exceeds its target share and from the tail of Am otherwise. All queue structures, ghost keys, and size-split parameters remain internal to the preview worker.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q (two-queue replacement with probationary A1in, ghost history A1out, and protected LRU Am) | Plain LRU; frequency-based eviction with aging | Documentary editors interleave long sequential screenings of one-off clips with repeated comparisons of a small working set. Plain LRU has minimal bookkeeping and adapts quickly on project switches, but sequential screening scans flush the comparison working set. Frequency-based eviction with aging retains popular clips across scans, but adds per-hit counter and aging maintenance and can retain stale favorites after editors switch projects. 2Q admits single-use screening sheets into a probationary queue and promotes only revisited sheets to the protected LRU queue, preventing scan pollution while confining all complexity to the preview worker's private replacement metadata. |
```

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review the LLD and let me know how you want to triage these component-level edge cases (fix in the LLD now vs. defer to Open Questions):

1. **Queue budget split (`A1in` vs. `Am` vs. `A1out`)**: What is the concrete target split of the 12 GiB budget between `A1in` and `Am` (e.g., 25% / 3 GiB for `A1in` and 75% / 9 GiB for `Am`), and how is `A1out` bounded (e.g., by key count such as 3,000–6,000 keys, or by tracked byte footprint)?
2. **Repeat hits inside `A1in` (simplified vs. classic 2Q)**: Should a cache hit on a sheet that is still resident in `A1in` immediately promote it to `Am`, or does `A1in` act as a strict FIFO filter where promotion to `Am` happens only when a key is re-requested while in `A1out`?
3. **Oversized or variable-size sheets**: Contact sheets average ~2 MiB, so byte-bounded eviction may require evicting multiple entries from `A1in` or `Am` for a single larger admission; what happens if a single rendered sheet exceeds the `A1in` target partition (or the 12 GiB cap)?
4. **Startup / crash recovery of 2Q metadata**: On worker restart, is the 2Q queue state persisted alongside cached files, reconstructed by scanning existing cache files into `A1in`/`Am`, or is the cache directory cleared on startup?
5. **Render Queue Full / Backpressure**: Four active jobs run concurrently in a FIFO render queue; is the waiting FIFO queue unbounded, or is there a maximum queue depth beyond which the worker sheds load?

How would you like to resolve or defer these items, and do you approve the LLD to proceed to Phase 3 (EARS specs)?