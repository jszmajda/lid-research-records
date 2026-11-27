Yes, I think it does. Here's why:

The 2Q choice clears the bar for a full decision doc:

1. **It stays live for a cold reader.** Someone joining the project later, seeing "2Q cache with 1/4 / 3/4 split," would reasonably ask "why not LRU?" without the context of editor workflow patterns and the three-meeting analysis.

2. **Multiple credible options traded against real criteria.** LRU is simpler; aged frequency is better retention; 2Q is more complex but protects working sets during scans. Those are genuine tradeoffs, not "one option dominates."

3. **Other design choices depend on it.** The A1/Am queue structure, the size split, the promotion logic — they're all sized around accepting this complexity for scan resistance. A reader needs to understand *why* that complexity exists.

4. **The debate was real and extended.** "Three meetings and 180 messages" suggests this wasn't obvious, which is exactly when a doc preserves the reasoning so it doesn't get re-litigated.

I'd suggest putting it at `docs/decisions/cache-eviction-strategy.md`, linked from the Decisions & Alternatives row in the previews LLD. The doc would lay out:
- The editing patterns that motivated the choice (sequential screenings + comparison work)
- Each option's tradeoff (bookkeeping cost, adaptation speed, scan resistance, retention)
- Why 2Q won despite its complexity
- The 1/4 / 3/4 size split and how it was chosen

Should I draft it?