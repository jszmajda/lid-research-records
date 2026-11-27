Yes, this clears the bar. Three credible options (LRU, frequency-with-aging, 2Q) with real tradeoffs, a tunable queue split (25%/75%), and downstream nodes (preview worker, review API) sized around the result — a cold reader would question why 2Q and why that split.

A decision doc belongs in `docs/intent/previews/decisions/` (segment-level, owned by previews). I'll draft one capturing the context, criteria, options, and selection if you want it.

Want me to create it?