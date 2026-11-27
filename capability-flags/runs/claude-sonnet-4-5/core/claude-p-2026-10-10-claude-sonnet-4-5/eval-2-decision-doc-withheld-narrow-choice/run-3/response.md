Now I'll run the LLD-level edge-case probe to identify gaps in the 2Q mechanism specification.

**LLD Edge-Case Probe — Previews 2Q Design**

1. **Oversized sheet admission**: What happens when a rendered sheet exceeds 3 GiB (the entire A1 capacity)? Should it be admitted directly to Am, rejected, or handled differently?

2. **Admission when total eviction is insufficient**: What happens when evicting everything from both A1 and Am still doesn't make room for a new sheet (sheet > 12 GiB)?

3. **Queue size accounting**: Are the 3 GiB and 9 GiB limits tracked precisely by bytes, or are they approximate thresholds? Do we account for metadata overhead?

4. **Re-rendering with version change**: When a sheet is re-rendered due to a renderer version update, does it enter A1 as a new entry (potentially duplicating the key temporarily), or does it replace the existing entry in-place in whichever queue holds it?

5. **Cache initialization**: On worker restart, does the cache start empty, or does it attempt to restore queue state from disk? If restoring, what queue does each sheet enter?

6. **Promotion mechanics when Am is at capacity**: When promoting from A1 to Am while Am is exactly at 9 GiB, do we evict from Am tail first (creating space), then add to Am head? Or do we allow temporary overflow?

7. **Queue exclusivity invariant**: The design implies a sheet exists in exactly one queue at a time, but this isn't stated explicitly. Should this be an explicit invariant?

8. **Head and tail structure**: Is each queue a doubly-linked list, or is there a different data structure assumed? What's the complexity guarantee for access/eviction operations?

---

**Context-free check**: The updated LLD reads independently — rationale is present, alternatives are named with their trade-offs, and no conversation residue remains. The Decisions & Alternatives table captures why 2Q was chosen without referencing the "three meetings" or "180-message thread."

**Phase 2 LLD — STOP for user review.**

Please review the updated previews design. The Private Cache section now commits to 2Q with the 25/75 queue split, and the Decisions & Alternatives table records the eviction policy choice with its rationale. The edge-case probe above lists gaps to triage — which should be addressed in the LLD vs. deferred as implementation details?