**Phase 4 — Intent-Narrowing Edge Audit**

Here are the cross-spec/cross-segment tensions and per-spec divergence forks I found:

---

### Cross-Spec Interactions (within `previews`)

| Specs | Tension |
|-------|---------|
| **PREVIEW-004** vs **PREVIEW-009/010** | PREVIEW-004 governs eviction at the **12 GiB total** level ("evict entries before admission so the cache remains within that limit"). PREVIEW-009/010 govern **queue-specific budgets** (3 GiB / 9 GiB). If both queues are at budget (A1=3, Am=9), admitting a new entry to A1 would push total to >12 GiB unless A1 evicts first. The LLD says "before admission, evict from A1 tail until A1 is within its budget" — but it's ambiguous whether "within budget" accounts for the incoming entry's size. |
| **PREVIEW-006** (admit to A1 head) + **PREVIEW-009** (evict A1 tail when over budget) | Sequencing ambiguity: does PREVIEW-009's "would exceed" check happen **before** admission (reserving space) or **after** admission (reactive)? The LLD describes pre-admission eviction; the spec could be read either way. |
| **PREVIEW-007** (graduation A1→Am) | When an A1 entry is accessed, it moves to Am head. If Am is at 9 GiB, PREVIEW-010 says evict Am tail. But the graduating entry **leaves A1** (freeing space there) and **enters Am** (consuming space). Total cache size is unchanged — only the queue budgets shift. The spec says "evicting from the Am tail if Am would exceed its 9 GiB budget" — this is correct, but the trigger condition ("would exceed") needs to account for the incoming entry's size. |

---

### Cross-Segment (previews ↔ review-api)

| Specs | Tension |
|-------|---------|
| REVIEW-003 (preserves 200/202/404) vs 2Q internals | The review API is correctly insulated — it never sees queue state, eviction counters, or graduation. No conflict. **Consistent.** |
| REVIEW design §Pending Previews | States "The API does not inspect whether a preview was evicted or never rendered." 2Q's scan-resistant Am queue means comparison sheets stay cached longer — this is an **internal benefit** with no API contract change. **Consistent.** |

---

### Per-Spec Divergence Probes (new/changed specs)

| Spec | Plausible Divergent Readings | Fork? |
|------|------------------------------|-------|
| **PREVIEW-006** "admit to A1 head" | 1. Admission = place in A1 head, **then** check budget (reactive)<br>2. Admission = ensure space in A1 first, **then** place (proactive, per LLD) | **Yes** — timing of budget check relative to insertion |
| **PREVIEW-007** "graduate A1→Am, evict Am tail if over budget" | 1. Atomic move: remove from A1, add to Am head, then evict Am tail if needed<br>2. Pre-check: evict Am tail **before** adding to Am (reserve space)<br>3. What if Am is full and the graduating entry is large — evict multiple? | **Yes** — atomic vs. pre-check; single vs. multiple eviction |
| **PREVIEW-009/010** "when queue would exceed budget, evict tail until within" | 1. Checked **only at admission/graduation** (event-driven)<br>2. Checked **periodically** or on **every access** (continuous)<br>3. "Within budget" = strictly ≤ budget, or ≤ budget after eviction of one entry? | **Yes** — trigger condition and eviction granularity |

---

### Questions for Resolution

1. **Admission sequencing**: Should PREVIEW-006/009 explicitly state that space is reserved in A1 **before** the new entry is inserted (pre-admission eviction), matching the LLD prose?
2. **Graduation atomicity**: Should PREVIEW-007 specify that the A1→Am move is atomic (entry exists in exactly one queue at all times), and that Am tail eviction happens **after** the entry is added to Am head (since total cache size doesn't change)?
3. **Eviction trigger**: Should PREVIEW-009/010 scope "would exceed" to **admission-time** (for A1) and **graduation-time** (for Am) only, not continuous monitoring?
4. **PREVIEW-004 vs queue budgets**: Should PREVIEW-004 be retired (superseded by queue-specific specs), or kept as a total-cache invariant that the queue budgets collectively enforce?

Please resolve these, and I'll narrow the specs accordingly before moving to tests.