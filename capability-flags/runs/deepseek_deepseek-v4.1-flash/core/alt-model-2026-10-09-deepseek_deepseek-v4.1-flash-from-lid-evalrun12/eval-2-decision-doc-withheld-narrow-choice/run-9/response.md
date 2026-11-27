Pre-flight and Phase 1 are clean; I've drafted the Phase 2 LLD around 2Q and stopped there for your review, as the workflow requires.

## Coherence pre-flight
- Previews specs (`PREVIEW-001…005`) trace to the previews LLD; no tests exist yet.
- Review API specs trace to their LLD and stay independent of the eviction policy.
- HLD architecture still matches the previews LLD (external interface, 4-job FIFO render queue, 12 GiB budget all unchanged).

## Phase 1 — HLD check
The eviction choice is policy-internal, so no architectural change. One stale line needed fixing: `docs/high-level-design.md` said "Its eviction policy remains open," which is no longer true. Updated to "…a private 12 GiB cache, including its eviction policy."

## Phase 2 — LLD update (`docs/intent/previews/previews-design.md`)
Replaced the open-candidates paragraph in **Private Cache** with the 2Q design and added a **Decisions & Alternatives** table:

- **A1in (probationary)** — sheets admitted and not yet referenced a second time.
- **Am (hot)** — sheets referenced at least twice.
- A1in capped at a tunable share of the budget (default 25% ≈ 3 GiB); Am takes the remainder.
- Hit in A1in → promote to Am; hit in Am → move to most-recent.
- Admission enters A1in most-recent; over budget, evict A1in least-recent, falling back to Am least-recent when A1in is under its cap.
- Rationale records why LRU and frequency-with-aging were rejected; a second row records the A1in split and its tuning.

## LLD-level edge-case probe (triage these)
1. **Re-reference after A1in eviction** — with only two queues (no ghost queue), a sheet evicted from A1in and later requested restarts as a first-use entry, so a clip revisited just after a scan could still be evicted repeatedly. Accept, or add a ghost queue?
2. **Kin units** — I specified bytes; confirm bytes vs. entry count.
3. **Oversized entry** — a sheet larger than the A1in cap: admit straight to Am, or allow A1in to exceed its cap for it?
4. **Pending requests** — should a 202 (job in flight, not yet cached) count as a reference, or only completed-cache hits? I assumed hits only.
5. **Concurrent queue mutation** — hits and admissions mutate both queues under 4 render jobs; the LLD doesn't yet name the synchronization.

## Stop for review
Per LID I'm stopping before Phase 3 rather than cascading to EARS. Approve the LLD as-is, or give numbered feedback (including your calls on gaps 1–5), and I'll proceed to the spec draft.