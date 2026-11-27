I have updated the design docs for **Phase 2 (LLD)**:

- **`docs/high-level-design.md`**: Updated the `Previews` architecture bullet to reflect 2Q eviction (removing the stale open-policy note).
- **`docs/intent/previews/previews-design.md`**:
  - Replaced the open-policy text in `## Private Cache` with the **2Q** design (`A1in` probation FIFO, `A1out` ghost FIFO, `Am` protected LRU) within the 12 GiB JPEG budget.
  - Added `## Decisions & Alternatives` recording **2Q** over **LRU** and **frequency-based eviction with aging** (kept as an LLD table row rather than a standalone decision doc since replacement bookkeeping is private to `previews`).
  - Added `## Open Questions & Future Decisions`, deferring the exact `A1in` / `Am` size split and `A1out` ghost capacity to pilot tuning.

### LLD-Level Edge-Case Probe (`previews-design.md`)

Please triage which of these gaps to resolve in the LLD now versus defer under `## Open Questions & Future Decisions`:

1. **Cache hit in `A1in`**: On a `GET` hit to an entry still in `A1in`, does it stay in `A1in` in FIFO order (standard 2Q, promoting only via `A1out` on re-render) or promote immediately to `Am`?
2. **Eviction fallback when `Am` is empty or `S > 12 GiB`**: If admitting `S` bytes exceeds 12 GiB while `A1in` is at/below its target budget and `Am` is empty (or `S > 12 GiB` alone), what is the fallback (spill eviction into `A1in`, or skip caching / return an error)?
3. **`A1out` overflow**: When `A1out` is at its bounded capacity and an `A1in` eviction records a new key, confirm that the oldest ghost key in `A1out` is dropped FIFO.
4. **Concurrent read vs. eviction**: If an entry is evicted while a concurrent `GET` is streaming its JPEG bytes, does the worker rely on open-file-descriptor semantics, per-entry pinning/refcounting, or re-render?
5. **Failed render job for ticket holders**: When a render fails and its deduplication entry is removed, do callers polling with an existing `202` ticket silently re-enqueue on their next 2-second retry, or receive an error?
6. **Completion-to-admission ordering**: What is the ordering between admitting a rendered sheet into `A1in`/`Am` and clearing its key from the deduplication map (especially if admission fails or is immediately evicted)?
7. **Queue backpressure and worker restart**: Is the FIFO render queue unbounded or capped (with `503` shedding), and on worker restart are existing cached JPEGs cleared or re-indexed into `A1in`?

---

**Phase 2 STOP:** Please review the updated `docs/intent/previews/previews-design.md` (and `docs/high-level-design.md`), let me know how you'd like to triage items 1–7, and confirm when you're ready to proceed to **Phase 3 (EARS spec updates)**.