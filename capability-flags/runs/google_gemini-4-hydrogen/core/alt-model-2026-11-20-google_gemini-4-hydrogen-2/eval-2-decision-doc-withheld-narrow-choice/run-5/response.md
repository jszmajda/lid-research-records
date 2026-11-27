Updated the design for **Phase 2 (LLD)** to adopt **2Q** replacement in `docs/intent/previews/previews-design.md` (and removed the stale "Its eviction policy remains open." note from `docs/high-level-design.md`).

### Changes in `docs/intent/previews/previews-design.md`
- **Private Cache — 2Q Replacement Policy:** Added `A1in` (probation FIFO), `A1out` (bounded ghost history FIFO, metadata-only), and `Am` (reused LRU) within the existing 12 GiB JPEG budget.
- **Decisions & Alternatives:** Recorded 2Q as chosen over LRU and aged frequency eviction, with rationale.
- **Open Questions & Future Decisions:** Marked the eviction policy resolved and deferred the `A1in`/`Am` byte-budget split and `A1out` capacity for pilot tuning.

---

### Phase 2 LLD Edge-Case Probe
An independent probe of `previews-design.md` surfaced these internal gaps. Please triage which to specify in the LLD now vs. defer:

1. **Cache hits inside `A1in`:** What happens when a hit occurs on an entry in `A1in`—does it keep its FIFO position, move to the `A1in` tail, or promote to `Am`?
2. **`A1out` lookup vs. removal timing:** What happens if a miss matches `A1out` and the render fails (or `A1out` evicts the key while the render is in flight)—is `A1out` checked/mutated at miss time or at admission time?
3. **2Q queue budget isolation vs. borrowing:** What happens when `A1in` or `Am` is under-utilized while the other hits its share (or a single JPEG exceeds a queue's share)—are budgets hard-partitioned or can they borrow up to 12 GiB?
4. **Concurrency between admission, eviction, and active reads:** What happens when multiple of the 4 active render jobs complete concurrently and run pre-admission eviction, or when eviction picks a file currently streaming a `200` response?
5. **Job-ticket schema, retry signaling, and failure/queue-full responses:** What is the `202` ticket payload and retry header (`Retry-After` vs. JSON), what HTTP error is returned when a render fails, and what happens if the FIFO render queue hits capacity?
6. **Revision resolution timing (`404` vs. `202`):** Does source revision resolution run synchronously in the `GET` handler (returning `404` immediately) or asynchronously in the queued job?
7. **Renderer-version upgrades and unclean shutdown:** On worker restart after a renderer-version bump or mid-render crash, are old-version entries and orphaned temp files purged on startup or counted against the 12 GiB budget?

---

**Next step:** Please review `docs/intent/previews/previews-design.md` and let me know:
1. Whether the 2Q design and `Decisions & Alternatives` entry look right, and
2. How you want to triage items 1–7 (specify vs. defer) before I proceed to **Phase 3 (EARS specs)** in `docs/intent/previews/previews-specs.md`.