### Phase 1 — HLD check

Updated `docs/high-level-design.md` to record the selected policy:

> Previews owns rendering, pending jobs, and a private 12 GiB cache using 2Q eviction.

The existing architecture remains coherent: replacement bookkeeping stays private to the preview worker, while the preview API, render queue, and 12 GiB limit remain unchanged.

Please approve this HLD update so I can proceed to **Phase 2: the detailed preview LLD**.