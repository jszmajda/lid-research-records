Phase 2 complete: the previews LLD now specifies 2Q eviction, and the HLD architecture line no longer says the policy is open. The design uses a FIFO probationary queue for first-use sheets and an LRU protected queue for reused sheets, promotes on a hit, caps protected at 80% (9.6 GiB) as a pilot starting value, and evicts probationary entries first. LRU and aged frequency remain recorded as rejected alternatives. No other node's design changes.

The LLD-level edge probe found these gaps worth your ruling before I write EARS:

1. **What counts as reuse?** If a client retries a 202 pending response, or several requests share one in-flight render, should those count toward promotion? My proposal: only a 200 served from a resident entry counts; 202 never does, and concurrent waiters count once when served.
2. **Demotion semantics.** When protected overflows, an LRU protected sheet moves to probationary. My proposal: queue position governs, so its reuse history resets and its next hit re-promotes it. The alternative is to exclude demoted sheets from immediate re-promotion.
3. **Superseded renderer versions.** The key includes renderer version but the URL does not, so old-version entries can linger protected forever. Invalidate them on version change, or leave them to normal eviction pressure?
4. **Render succeeds but cannot be admitted** (oversized or cache write failure): serve the current waiter, leave the key uncached, and remove its dedup entry — confirm?
5. **Dedup entry lifetime after success:** remove it on success, or retain it while the cached entry remains resident?

I can fold in the mechanical invariants without asking: entries belong to exactly one queue; admission/eviction is serialized; the 12 GiB bound wins over probationary-first preference; admission is all-or-nothing; and 200 responses are marked non-cacheable so the worker actually sees reuse.

Do you approve the LLD as drafted, and which of 1–5 should I settle now versus defer? Say if you want a different starting protected share than 80%. Once you approve, I’ll update the EARS specs.