Now I'll run an LLD-level edge-case probe to identify gaps in the 2Q mechanism:

**LLD-Level Edge Cases for 2Q Mechanism:**

1. **Multiple accesses in A1**: When a preview in the A1 queue is accessed multiple times before eviction, does it move to Am immediately on the second access, or does it remain in A1 and only promote to Am when A1 evicts it?

2. **Oversized previews**: What happens when a single completed preview exceeds the entire A1 budget (3 GiB)? Does it bypass A1 and go directly to Am, get rejected, or trigger immediate eviction?

3. **Size accounting during promotion**: When a preview promotes from A1 to Am, how are the queue size budgets adjusted? Is there a moment where the preview counts against both budgets, or is the transfer atomic?

4. **Am full during promotion**: When Am is at its 9 GiB limit and a preview in A1 qualifies for promotion (accessed again), do we evict from Am's LRU position to make room before the A1 eviction completes?

5. **Access semantics**: Does accessing a preview in A1 immediately mark it for promotion but leave it physically in A1 until natural eviction, or does access trigger an immediate queue transfer?

6. **Queue membership and failed renders**: When a render job fails and its deduplication entry is released, could it have already been admitted to A1? If so, does failure remove it from the queue?

7. **Split parameter tunability**: The 25/75 split is specified as fixed values. Is runtime reconfiguration of this split a future concern, or should the mechanism remain fixed at these values indefinitely?

Which of these gaps should be addressed in the LLD now versus deferred as implementation details or future decisions?

---

**Phase 2 Stop: LLD Review** — The previews LLD now specifies the 2Q eviction mechanism with a 25/75 split between the A1 (in) and Am (main) queues, and records the decision with its rationale in the Decisions & Alternatives table. The HLD has been updated to reflect the closed decision.