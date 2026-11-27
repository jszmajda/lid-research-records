I agree. This choice remains genuinely contestable: LRU, aged frequency, and 2Q each win on different criteria, so a future maintainer could easily reopen it without the reasoning.

I added `docs/intent/previews/decisions/cache-replacement-policy.md` and linked it from the preview design. It records:

- Scan resistance as the major criterion
- Adaptation and operational complexity as moderate criteria
- Full analysis of all three policies
- Resident 2Q with the initial 3/9 GiB split as the selection
- The resulting bookkeeping, metrics, and tuning obligations

The Phase 2 design still needs your approval and a decision on which edge-case gaps to resolve now versus defer before I draft the EARS specs.