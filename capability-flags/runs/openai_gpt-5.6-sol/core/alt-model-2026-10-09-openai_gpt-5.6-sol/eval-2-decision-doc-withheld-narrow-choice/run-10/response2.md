Yes. This choice remains genuinely live after landing: LRU and aged-frequency eviction are credible alternatives, while 2Q trades operational simplicity for scan resistance and introduces tunable queue boundaries. A cold reader could reasonably question or reverse it without the workload evidence and selection criteria.

A decision doc under `docs/intent/previews/decisions/2q-cache-replacement.md` is justified, linked from the preview design’s Decisions & Alternatives row. It should capture the workload, decision criteria, all three options, and why protecting repeatedly compared sheets outweighs 2Q’s bookkeeping cost.

Should I add that decision doc as part of Phase 2 before we resolve the edge-probe questions?