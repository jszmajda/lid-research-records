**Phase 1: HLD Check**
The 2Q choice stays within the preview worker, so it does not alter FrameDesk’s architecture or require changes to HLD tenets, goals, or boundaries.

I removed the stale statement that the eviction policy remains open from `docs/high-level-design.md`. The HLD now describes the Previews node as owning rendering, pending jobs, and its private 12 GiB cache, leaving the specific 2Q mechanism to the preview LLD.

Please approve this HLD update so I can revise the preview design with the complete 2Q policy and run its LLD edge-case probe.