**2Q is recorded as the selected policy** in `docs/intent/previews/previews-design.md`. Its rationale belongs in that design’s Decisions & Alternatives table: protecting comparison sheets during sequential screenings justifies the extra bookkeeping.

I also removed the stale “eviction policy remains open” statement from `docs/high-level-design.md`.

### Design update for review

The preview cache uses two resident queues:
- **First-use sheets:** FIFO ordering.
- **Reused sheets:** LRU ordering.

Both queues share the **12 GiB JPEG-data budget**. Queue membership, ordering, and any nonresident key history remain private to the preview worker. The separation protects comparison sheets against one-off screening traffic without guaranteeing permanent retention.

| Decision | Chosen | Alternatives considered | Rationale |
|---|---|---|---|
| Cache replacement | 2Q | LRU; frequency-based eviction with aging | Prioritize scan resistance, accepting queue bookkeeping and size tuning. LRU is simpler and adapts quickly but is vulnerable to scans. Aged frequency counts retain popular clips but add maintenance and can lag project switches. |

### Design probe findings

The probe identified these remaining gaps, now recorded as open questions:
1. **Reuse qualification:** resident-hit promotion versus promotion after revisiting an evicted key.
2. **Queue sizing:** first-use byte allowance, reclaim target versus hard partition, and any history bound.
3. **Reference events and admission:** whether pending retries count as reuse, variable-size victim selection, and promotion rebalancing.
4. **Concurrency:** atomic publication and byte accounting, simultaneous completions, and eviction during reads.
5. **Failure and recovery:** oversized sheets, publication failures, ticket lifetime, and worker restart.

The selected policy fits the existing architecture. `git diff --check` passes.

**First, which 2Q variant do you want?**
- **Simplified 2Q:** promote on a second request while the sheet is still cached. Less bookkeeping, but closely spaced screening requests can qualify as reuse.
- **Full 2Q:** retain a bounded history of evicted first-use keys and promote when one is requested again. More bookkeeping, but stronger filtering of short-lived screening traffic.

I recommend **full 2Q** for the screening/comparison distinction you described. Shall I use that?