Looking at the decision doc guidance under the *earns-its-place heuristic*:

> **Apply the test from the landed state, looking forward — not from the deliberation, looking back.**
> The question is *not* "was this hard to decide?" Plenty of decisions are contested while the work is in flight and then read as obvious, even native, once they land. The question is: **once this lands, would a cold reader of the result find the choice non-obvious — would they question it, or be tempted to reverse it, not knowing why it went this way?**
>
> That yields three outcomes:
> 1. **Record nothing** (obvious/native).
> 2. **A Decisions & Alternatives row** (a cold reader wonders "why this?", and one line settles it — e.g. an inherited constraint or clear trade).
> 3. **A full decision doc** (the choice stays genuinely *live*, requiring deep trade-offs across multiple criteria that a reader would re-litigate without the full document).

Here, the debate and 180-message thread reflect deliberation friction, but once landed:
- The replacement policy affects only the private internals of the preview cache; external APIs, render queues, and other nodes remain unchanged.
- The Decisions & Alternatives table row in `previews-design.md` directly captures why 2Q was selected over LRU and frequency-based eviction (protecting comparison sheets from sequential scan thrashing with minimal bookkeeping).
- A cold reader examining the domain sees a standard scan-resistant cache pattern.

Because of this, the Decisions & Alternatives row in the LLD already provides sufficient justification without needing a dedicated decision doc. However, under the tenet that *the user is always right — with warning*, if you still want a standalone decision doc at `docs/intent/previews/decisions/cache-eviction-policy.md` to preserve the full criteria, options, and analysis, I am happy to draft it.

Would you prefer to keep it in the LLD table row, or shall I draft the standalone decision doc?