Phase 2 (LLD revision) is complete. The previews LLD now specifies 2Q and the stale "policy remains open" line in the HLD is synced. The choice is recorded in the previews LLD's new Decisions & Alternatives table (LRU and frequency-with-aging as rejected alternatives with rationale) — it affects only this segment, so a table row is the home for it.

**What the design now says** (`docs/intent/previews/previews-design.md`):

- Three private structures: **A1** (FIFO, first-use sheets, ~25% of 12 GiB ≈ 3 GiB), **A2** (LRU, reuse-proven sheets, ~75%), and a **ghost list** (2,048 keys recently evicted from A1).
- **Admission**: a completed sheet whose key is in the ghost list goes straight to A2 (reuse evidence); otherwise A1. A hit in A1 serves bytes without promoting; a hit in A2 refreshes recency.
- **Eviction**: each queue trims to its own budget — A1's FIFO end feeds the ghost list; A2's LRU end leaves entirely; budgets sum to 12 GiB.
- Split and ghost length are worker-private tunables; tuning against pilot workloads and whether A2 evictions deserve their own ghost list are recorded as deferred open questions.

**Phase 2 edge-case probe — triage requested.** A blind reader probed the draft and surfaced these gaps; please triage which to fix in the LLD now vs. defer as open questions (numbered replies fine):

1. A single sheet larger than A1's (or A2's) whole budget — does the evict-until-fit loop empty the queue and evict the new sheet itself? What does the requester get?
2. Render completes but admission hasn't run — request arrives in that window: does it see a miss and start a duplicate render?
3. A render that hangs indefinitely — timeout to a PREVIEW-005-style failure, or does it hold one of four slots forever?
4. Ticket retry arrives after the sheet was admitted *and already re-evicted* — fresh 202, and is a stale ticket ever distinguished from a failure?
5. Ghost-hit admission while A2 is full but A1 has slack — is the 25/75 split hard, or can queues borrow?
6. Two admissions interleaving check-budget → evict → admit — is budget accounting atomic, or can queues end up over budget?
7. Worker crash/restart — is cache residency, ghost list, and dedup state rebuilt from disk or lost? What happens to in-flight tickets and accumulated reuse evidence?
8. A hit arriving for a sheet that is concurrently the eviction victim — does the read succeed, and does it have any policy effect?
9. Temp render output — counted against 12 GiB or not, and what cleans up files orphaned by a crash?
10. Render "succeeds" but produces corrupt/zero-byte output, or persistence fails — is that a failure (PREVIEW-005) or a success admitting unusable bytes?
11. Misses enqueue faster than four slots drain during a screening — is the pending FIFO unbounded, with no defined backpressure?
12. Renderer version bump — are stale-version sheets and ghost keys invalidated, or do they squat on budget and ghost capacity until natural eviction?

**One confirm-point on the drafted mechanism**: I specified promotion as the classic 2Q rule — reuse counts only *after* a sheet's A1 tenure ends (ghost-list hit), not on a second request while it still sits in A1. This maximizes scan resistance (twice-touched one-offs stay out of the protected queue) but costs one re-render cycle before a comparison sheet earns protection. If you'd rather promote on second touch while in A1, say so and I'll flip that row.

Once you've triaged the gaps and approved (or amended) the LLD, I'll draft the Phase 3 EARS specs for the 2Q admission/promotion/eviction behavior and bring them back for review.