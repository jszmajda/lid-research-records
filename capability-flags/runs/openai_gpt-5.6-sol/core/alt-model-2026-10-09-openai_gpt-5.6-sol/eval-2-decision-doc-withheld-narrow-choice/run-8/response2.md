Yes. Not because the discussion was long, but because the choice remains genuinely contestable after landing: a future maintainer could reasonably replace 2Q with simpler LRU without understanding why scan resistance matters more than bookkeeping cost.

A decision doc would preserve the workload context, compare LRU, aged frequency, and 2Q against the actual criteria, and explain the downstream tuning obligations. The LLD should then link to it from the Decisions & Alternatives table.

If you approve, I’ll add the decision doc as part of the Phase 2 revision.