## Phase 2: LLD Update Complete

I've updated the previews design with the 2Q eviction policy decision. Here's what changed:

**Updated LLD section (Private Cache):** Now specifies 2Q with concrete mechanics:
- **Queue A** (3 GiB): New entries, FIFO eviction—sheds one-use screening clips quickly
- **Queue B** (9 GiB): Reused entries (accessed twice+), LRU eviction—protects comparison sheets during screenings
- **Promotion rule**: Second access moves an entry from A to B
- **Eviction sequence**: FIFO from A first, then LRU from B if needed

The 25/75 split (3/9 GiB) reflects the workload: long sequential screenings generate many one-use clips (A), while comparison sessions repeatedly access a smaller working set (B). This matches the design intent to accept extra bookkeeping in exchange for protection during big screenings.

## Phase 3: EARS Specs (Cascaded)

Since the LLD change affects behavior spec'd in EARS, I've cascaded Phase 3 specs within the same segment:

Added six new specs (PREVIEW-010 through PREVIEW-015) that lock in 2Q mechanics:
- Queue placement and sizing rules
- Promotion on second access
- Eviction sequence and order
- Access-time tracking for LRU within B

**Consistency check**: All specs are scope-explicit (each names the queue it addresses), concrete (no "as discussed" assumptions), and atomic (each spec is one behavior, not compound).

---

**Ready to proceed?** Approve Phase 2 & 3 and I'll move to Phase 4 (intent-narrowing edge audit) to check for cross-segment interactions or ambiguities with the 2Q design before writing tests and code.