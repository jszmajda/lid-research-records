I've recorded 2Q in the previews design and stopped at the Phase 2 review. No specs, tests, or code have been written yet.

**What changed**
- `docs/intent/previews/previews-design.md` (Private Cache section):
  - **Mechanism:** The "policy is open" paragraph is replaced with the 2Q mechanism.
    - **Queues:** A probationary FIFO queue holds first-use sheets. A protected LRU queue holds sheets that were served from the cache while still probationary.
    - **Eviction:** Eviction takes from the probationary head while that queue is over its target share, and otherwise from the protected LRU end.
    - **Accounting:** The target share is a soft, tunable parameter, and accounting is in bytes.
  - **Decisions & Alternatives:** A new row records 2Q against LRU and aged frequency, using your rationale: protect comparison sheets from big screenings, and accept two queues plus a share to tune.
- `docs/high-level-design.md`: I changed the line "Its eviction policy remains open" to say the policy is 2Q. That line was stale after your decision. It is the only HLD edit, and the HLD architecture is otherwise untouched.

**Decision doc:** I didn't offer one. The choice is internal to the previews node and the HTTP contract and other nodes are unaffected, so a table row covers it.

**Review API:** No cascade is needed. The review API design already says it never touches eviction state.

**Edge-case probe on this LLD.** These need your call:
1. **Variant (a real fork):** Right now a sheet evicted from probation leaves no trace, so a re-request after eviction counts as first use. Full 2Q keeps a metadata-only "ghost" list of recently evicted keys, so a quick return is recognized as reuse and goes straight to protected. Which do you want? Ghosts help when a screening is long enough to push a sheet out of probation before the editor returns to it. They add a third structure, though you said "two queues." I lean toward starting without ghosts and revisiting if the data shows premature evictions.
2. **Target share:** The design leaves the initial value open. I'd suggest probation at 25% of the 12 GiB (about 3 GiB, or roughly 1,500 typical sheets) and making it configurable. Do you want to fix that now or leave it to tuning?
3. **Concurrent requesters:** Several editors may ask for a sheet while its shared job is pending. The design counts completion as a single first use. Should several waiting requesters instead count as reuse and place the sheet straight into protected?
4. **Restart:** After a worker restart, should queue membership persist, or should every cached sheet start probationary? I lean toward cold-start probationary, since it needs no persistence.
5. **Eviction during a read:** If an entry is evicted while a 200 response is streaming it, the read has to either finish or fail cleanly. I haven't specified which. I'd cover it as a Phase 3 spec once the design is approved.

**Next step:** Tell me your answers, or numbered edits to the design. Once you approve, I'll move to Phase 3, the EARS specs (the new `PREVIEW-006` and onward, plus an update to `PREVIEW-004`).