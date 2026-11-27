**Phase 1 — HLD check: complete. Stop for your review.**

**Pre-flight:** LID configured (Full, v1.4.0) ✓ · HLD exists and covers the change domain ✓ · LLD↔specs coherence noted for downstream phases (previews-design.md still says the eviction policy "is still open" — that's Phase 2 work).

**Change made to `docs/high-level-design.md`** (Architecture section):

```diff
-- Previews: ... Owns rendering, pending jobs, and a private 12 GiB cache. Its eviction policy remains open.
++ Previews: ... Owns rendering, pending jobs, a private 12 GiB cache, and the 2Q eviction policy
++ that governs it — first-use sheets are held apart from reused sheets so long sequential
++ screenings do not displace comparison sets.
```

Nothing else in the HLD needed touching: the tenets, the "same interface for every eviction policy" goal, and the "no promise a clip stays cached" non-goal all still hold under 2Q, and the review-API boundary is unaffected by your scoping (all changes stay inside the preview cache).

**How I plan to record the choice:** as a Decisions & Alternatives row in `previews-design.md` (Phase 2), not a standalone decision doc — the decision's substance lives entirely in the preview worker, so it affects only its own node. The rejected LRU and aged-frequency options and why they lost go in that row's rationale.

Approve this HLD edit (or give numbered feedback) and I'll proceed to Phase 2: revising the previews LLD around 2Q — queue split, size split parameter, admission/eviction flow — followed by an LLD-level edge-case probe.