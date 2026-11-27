**Phase 1 — HLD check.** No architectural change: the interface, FIFO render queue, four-job concurrency, and 12 GiB bound are untouched. One stale line corrected — the HLD no longer says the preview eviction policy "remains open"; the root now defers to the previews design.

**Coherence pre-flight.** PREVIEW-001–005 still trace to the previews LLD; no code or tests exist yet in the repo; the HLD and LLD otherwise agree. Clean.

**Phase 2 — Previews LLD (2Q).** Updated `docs/intent/previews/previews-design.md`:
- Replaced the "policy is still open" paragraph with a concrete **Eviction Policy** subsection: a probationary FIFO queue (admitted, not yet re-requested) and a protected LRU queue (re-requested since admission); new sheets enter probationary; a cache hit on probation promotes to protected; eviction drains probation first, then protected LRU; protected is capped at a tunable share of the 12 GiB budget.
- Added a **Decisions & Alternatives** row recording 2Q over plain LRU and aged frequency, with rationale. Recorded as a row (not a full decision doc) since the choice affects only the previews node and a line settles it.
- Added **Open Questions**: size split deferred to implementation.

**LLD-level edge-case probe** — gaps I found, for your triage:
1. **Size-split value** — deferred (already noted).
2. **Pending-ticket references** — the text promotes on a served cached sheet only; a request answered with a 202 ticket does not count as a second reference. Confirm that's intended.
3. **Re-render thrash** — a probationary sheet evicted mid-revisit re-renders and re-enters probation as fresh, so 2Q can't recognize the revisit without tracking recently evicted keys. Accept, or add a ghost-key list?
4. **Durability on restart** — is queue membership/order rebuilt from the cache directory after a worker restart, or does every entry reset to probation? The 12 GiB bound holds either way, but protection resets.
5. **Protected-queue overflow** — confirm promotion to a full protected queue still drains probation first and that the cap is a target the eviction loop enforces jointly with the 12 GiB bound.

I've stopped here (Phase 2 boundary) before touching EARS. Approve the LLD, and tell me which probe gaps to fold in versus defer — then I'll run Phase 3 and draft the spec update (the interface is policy-independent, so I expect the specs to need no change, which I'll confirm there).