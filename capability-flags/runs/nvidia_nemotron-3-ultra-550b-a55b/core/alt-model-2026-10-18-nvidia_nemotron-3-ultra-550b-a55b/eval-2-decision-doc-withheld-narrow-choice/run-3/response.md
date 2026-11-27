Now let me do the Phase 4 intent-narrowing edge audit. I've identified several potential divergence points in the new 2Q specs:

## Phase 4 — Intent-Narrowing Edge Audit

### Cross-segment check (previews ↔ review-api)
**Clean boundary.** Review API design explicitly states it "does not inspect whether a preview was evicted or never rendered. It neither requests cache pinning nor accesses cache paths, eviction counters, or replacement-policy configuration." No cross-segment interaction on eviction policy.

### Within-segment forks (divergence probes on new specs)

| Spec | Potential Fork | Divergent Readings |
|------|----------------|-------------------|
| **PREVIEW-007** | "accessed a second time" | (a) Any cache hit on an Am entry promotes it; (b) Only a second *distinct* request promotes it (deduped concurrent requests count as one); (c) Only after TTL or time threshold |
| **PREVIEW-011** | "if space permits" when demoting A1→Am | (a) Follow normal Am admission (evict Am tail if needed); (b) Only demote if Am has free space under its 25% budget; (c) Demote but exceed Am budget temporarily |
| **PREVIEW-004 vs 009/010** | Total 12 GiB vs queue budgets | (a) Queue budgets are hard partitions (Am≤3GiB, A1≤9GiB) — total never exceeds 12GiB; (b) Queue budgets are soft — total enforced first, then queues rebalance; (c) Total is the only hard limit, queue budgets are targets |
| **PREVIEW-009/010** | Eviction order when both queues at budget | (a) Always evict Am tail first (design says "Am is evicted from the tail when space is needed"); (b) Evict from whichever queue has the oldest tail entry; (c) Proportional eviction |

### Namespace ambiguity
All new specs use `PREVIEW-` prefix — correct, owned by previews leaf. No collision with `REVIEW-` specs.

### Latent intent narrower than literal specs
The user's stated rationale: "protect the comparison sheets during big screenings." The current specs allow an implementation where Am budget is 25% but a massive screening could still fill Am, evict its tail (oldest one-use entries), and *then* start evicting A1 — which would lose the comparison sheets. The intent is probably: **A1 entries should effectively never be evicted by a screening scan**, meaning Am should absorb all scan pressure up to its budget before A1 is touched at all.

---

**STOP for user review.** Please resolve the forks above (numbered 1–4), especially:
1. What "second access" means for promotion (PREVIEW-007)
2. Whether A1→Am demotion follows normal Am admission or is conditional (PREVIEW-011)
3. Whether queue budgets are hard partitions or soft targets (PREVIEW-004 vs 009/010)
4. Whether A1 should be *effectively immune* to scan pressure (latent intent)