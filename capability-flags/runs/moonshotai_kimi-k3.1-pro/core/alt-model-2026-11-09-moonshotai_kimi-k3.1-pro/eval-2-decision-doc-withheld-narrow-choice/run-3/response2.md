Yes—I think it earns a proper decision doc. Not because the debate was long, but because a future maintainer could reasonably question or reverse the choice: LRU, aged frequency, and 2Q trade scan resistance, adaptation, retention, and bookkeeping differently, and the A1in/A1out tuning depends on that reasoning.

I’d create `docs/intent/previews/decisions/cache-replacement-policy.md`, covering:

- The workload and constraints
- The three credible options
- Criteria for comparing them
- Why 2Q wins
- The accepted bookkeeping and tuning costs
- Downstream implications for the preview cache

Then I’d link it from the existing 2Q row in the LLD. The unresolved edge cases would remain in the LLD rather than being settled implicitly by the decision doc.

Shall I draft it as part of this Phase 2 design review?