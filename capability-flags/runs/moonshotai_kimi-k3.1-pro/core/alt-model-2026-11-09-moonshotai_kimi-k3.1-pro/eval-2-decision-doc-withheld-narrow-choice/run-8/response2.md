I’d record it as a **Decisions & Alternatives row in the preview LLD**, not a standalone decision doc.

The deciding factor isn’t how much debate it took, but whether a future reader would need the full analysis to avoid re-litigating the choice. Here, the decision is confined to the preview cache; the API, render queue, and disk budget stay fixed. A row capturing **2Q over LRU and aged frequency-based eviction, because scan resistance is worth the extra queue bookkeeping and tuning**, should preserve the durable reasoning without adding another design artifact.

If you specifically want the fuller trade-off record despite that, I can write the decision doc—but my recommendation is the LLD row.