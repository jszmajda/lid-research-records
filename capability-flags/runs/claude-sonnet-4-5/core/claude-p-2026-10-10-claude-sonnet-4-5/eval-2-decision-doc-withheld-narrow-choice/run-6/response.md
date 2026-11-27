## Phase 2 — Updated Previews LLD

I've updated `docs/intent/previews/previews-design.md` with the 2Q eviction policy decision. Here's what changed:

### New "2Q Eviction Policy" Section

Specifies the two-queue mechanism:
- **A1 (first-access queue)**: 3 GiB (25%), FIFO eviction for entries accessed once
- **Am (main queue)**: 9 GiB (75%), LRU eviction for entries accessed twice or more
- Promotion happens on second access, moving entry from A1 to Am's MRU position
- Eviction prefers A1 over Am to protect the comparison working set

### New "Decisions & Alternatives" Section

Documents two decisions:

1. **Cache eviction policy**: 2Q chosen over LRU and frequency-based aging. Rationale captures that 2Q protects comparison sheets during long screenings, while LRU is vulnerable to sequential scans and frequency-based aging adds overhead and lags project switches.

2. **A1/Am capacity split**: 25/75 chosen over 50/50, 10/90, and 33/67. Rationale explains the balance between giving Am enough capacity for comparison working sets while leaving A1 large enough that screening previews can earn promotion.

The design reads context-free — no reliance on the conversation about the three meetings or the 180-message thread. All eviction tracking remains private to the preview worker per the HLD's tenets.

**Ready for your review.** Please confirm this LLD captures the 2Q design correctly, or point to anything that needs adjustment.