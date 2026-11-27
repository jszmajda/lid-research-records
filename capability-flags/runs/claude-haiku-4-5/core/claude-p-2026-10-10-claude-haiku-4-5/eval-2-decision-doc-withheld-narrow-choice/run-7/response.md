Now I'll run the **LLD-level edge-case probe** to surface any gaps in the 2Q design before moving to spec verification. These are "what happens when..." questions specific to this component:

**Edge-Case Probe for 2Q Cache Design:**

1. **Concurrent promotions** — When two requests hit the same A1 entry within a very short window, should both promotions be queued, or does one write supersede the other? The current design doesn't specify thread-safety guarantees around queue manipulation.

2. **Partial entries during eviction** — If an entry is being evicted and another request tries to read it simultaneously, should the read wait for eviction to complete, return 202 (miss), or fail? Current spec is silent on this race.

3. **A1 target overshoot** — On admission, if the incoming JPEG is itself larger than the A1 target, is it directly added to A2, or forced into A1 and immediately promoted? The design says "move to A2" but doesn't clarify the order of operations.

4. **Deduplication and eviction** — If an in-flight render job for key X is pending, and key X is evicted from both queues before the job completes, should the completed JPEG be re-admitted (and re-evicted?) or dropped? Current design doesn't address this edge.

5. **A1 FIFO within the target window** — The design mentions FIFO for A1, but if A1 is under its target and we hit an entry there, do we move it to update its FIFO order, or leave it in place? Affects whether A1 is truly FIFO or only FIFO-at-overflow.

6. **Empty A2 on A1 eviction need** — If A1 has entries but A2 is empty and we need to evict, do we evict from A1 alone, or force some entries from A1 to A2 first? Current design assumes A1 is checked first, but the order of "move to A2" vs. "start evicting" is ambiguous.

7. **Monitoring and dashboards** — No spec currently defines which metrics are exported (A1 depth, A2 depth, promotion rate, eviction rate). What should operators observe?

---

**Which of these should be clarified in the LLD before moving to EARS specs?** I'd recommend:
- **Items 1, 3, 6**: address thread-safety and admission ordering — these affect the state machine and should be pinned in the LLD.
- **Item 4**: affects the interaction between deduplication and eviction — clarify ownership and lifecycle.
- **Items 2, 5, 7**: can be deferred to EARS (items 2, 5) or Phase 5 (item 7, monitoring).

Should I update the LLD with clarifications on 1, 3, 4, 6, and leave 2, 5, 7 as narrowing targets for Phase 4 (intent audit)?