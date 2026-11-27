## Phase 2 Complete: Preview Design (LLD)

The Previews LLD is complete with the 2Q eviction policy decision finalized. Here's what's ready for review:

**Finalized sections:**
- **Architecture**: Fixed external contract (200/202/404 outcomes), internal independence
- **Rendering and Deduplication**: Cache-miss sharing and retry semantics
- **Private Cache → 2Q Eviction Policy**: New subsection documenting the two-queue mechanism with 75/25 size split and FIFO eviction within each queue
- **Decisions & Alternatives**: Table recording the 2Q choice against LRU and frequency-based alternatives with full rationale

The design now clearly describes why 2Q trades extra bookkeeping (promotion tracking on second access) for protection of comparison-sheet reuse during large screenings, without the operational overhead of frequency-counter maintenance or aging-window tuning.

**Ready for next phase?** Once you approve, I'll move to Phase 3 (EARS specs draft). The current specs placeholder will need updates to reflect the 2Q mechanism details — particularly around promotion behavior and queue management.