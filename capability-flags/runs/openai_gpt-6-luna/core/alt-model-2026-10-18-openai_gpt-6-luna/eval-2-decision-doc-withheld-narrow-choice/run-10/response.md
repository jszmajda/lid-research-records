## Phase 1 — HLD check

The HLD’s architecture still matches the selected design: cache ownership remains inside the preview worker, and the review API contract is unchanged. Its statement that the eviction policy “remains open” is now stale, so I updated the preview entry:

> Previews: `docs/intent/previews/previews-design.md`, with `docs/intent/previews/previews-specs.md`. Owns rendering, pending jobs, and a private 12 GiB cache; its replacement policy is specified in the preview design.

`git diff --check` passes. Only `docs/high-level-design.md` is modified.

Does this HLD update land cleanly? Please approve it so I can proceed to Phase 2 and finish the preview design.