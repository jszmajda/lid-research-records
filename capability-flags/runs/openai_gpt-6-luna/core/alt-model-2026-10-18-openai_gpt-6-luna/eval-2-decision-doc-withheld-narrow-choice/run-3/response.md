## Phase 1 — HLD check

The HLD keeps eviction bookkeeping inside the preview worker, so the 2Q choice fits the existing architecture. I updated its architecture entry to record the selected policy:

> Previews: `docs/intent/previews/previews-design.md`, with `docs/intent/previews/previews-specs.md`. Owns rendering, pending jobs, and a private 12 GiB cache using a 2Q eviction policy.

The coherence pre-flight found the preview LLD still lists eviction as open, while `PREVIEW-004` specifies the cache limit but not the replacement policy. Those are the downstream items to address in the next phase.

**Please approve this HLD update so I can proceed to the preview LLD phase.**