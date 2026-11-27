Yes. A decision doc is warranted: 2Q remains a credible choice to revisit because its scan resistance, bookkeeping cost, and queue-size tuning trade against alternatives, and the preview design will depend on that choice.

It belongs under `docs/intent/previews/decisions/`, owned by the previews segment rather than the HLD, because it affects only the preview worker's private cache. I would record the chosen policy, LRU and aged-frequency alternatives, the relevant criteria, and the downstream obligations for queue sizing and tests.

Please approve the Phase 1 HLD update and this decision-doc scope, and I’ll draft the preview LLD and decision doc in Phase 2.