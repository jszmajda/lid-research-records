Now let me run the **LLD-level edge-case probe** as required by Phase 2:

**Edge-case probe for 2Q design:**

1. **A1in full on admission** — Evict from A1in tail (FIFO). New entry goes to A1in head. ✓ Covered.

2. **Am full on promotion** — Evict from Am tail, demote its key to A1out head. Promoted entry goes to Am head. ✓ Covered.

3. **A1out full on demotion** — Evict from A1out tail (FIFO, keys only). Demoted key goes to A1out head. ✓ Covered.

4. **Hit in A1in (second access)** — Promote: move entry from A1in to Am head. A1in shrinks, Am grows. ✓ Covered.

5. **Hit in Am (repeated access)** — Move to Am head (standard FIFO refresh for recency within master queue). ✓ Covered.

6. **Hit in A1out (ghost hit)** — Re-admit: create entry in Am head, remove key from A1out. ✓ Covered.

7. **Queue size enforcement** — A1in/Am tracked by **byte count** (JPEG data ≤ 3 GiB / 9 GiB). A1out tracked by **key count** (≤ 3 GiB worth of keys). Admission checks byte budget before write. ✓ Covered.

8. **Concurrent metadata access** — All queue operations serialized through the preview worker's single-threaded event loop (implied by "private to the preview worker" and fixed 4-job render queue). No lock-free structures needed. ✓ Implied.

9. **Cold start** — All queues empty. First admissions fill A1in. ✓ Covered.

10. **12 GiB limit enforcement timing** — Checked **at admission** before writing JPEG to cache. If admission would exceed limit, evict from target queue's tail until space exists. No periodic compaction needed. ✓ Covered.

11. **Renderer version change invalidates key** — Cache key includes renderer version; version bump = new key = cold admission to A1in. Old entries age out naturally. ✓ Covered by key definition.

12. **Failed render after admission check** — Admission check happens *after* render completes (per "Before admitting a completed sheet"). Failed jobs never reach admission. ✓ Covered.

13. **A1out stores keys only, no JPEG data** — Memory overhead: ~200 bytes/key × ~15,000 keys (3 GiB / 200 KiB avg sheet) ≈ 3 MiB. Negligible. ✓ Covered.

**Gaps to fix in LLD:**
- Explicit statement that Am hits refresh to head (FIFO recency within master queue).
- Explicit statement that A1out stores keys only, no JPEG data.
- Clarify that admission eviction is from the *target queue's tail* (not global LRU).

---

**STOP for user review** — Please review the updated LLD and the edge-case probe. Confirm the design or request changes before I proceed to Phase 3 (EARS specs).