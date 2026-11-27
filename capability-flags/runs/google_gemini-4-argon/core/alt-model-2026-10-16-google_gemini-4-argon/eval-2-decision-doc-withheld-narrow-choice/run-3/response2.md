I'd actually recommend keeping this as the `Decisions & Alternatives` table row in `previews-design.md` rather than creating a standalone decision doc, though if you still want a full doc in `docs/intent/previews/decisions/` I'm happy to write one.

Here is why the LID heuristic points toward a table row here:

- **Judge from the landed state, not the deliberation.** A decision doc's job isn't to memorialize how long or painful the debate was; it's for choices where a future cold reader of the landed design would otherwise re-litigate the decision without a full breakdown of criteria and tradeoffs.
- **The choice is strictly local to `previews`.** All replacement bookkeeping stays private to the preview worker; neither `review-api`, the HTTP contract, the render queue concurrency, nor the 12 GiB disk budget is shaped or sized around 2Q. No other design node leans on it.
- **One line of rationale settles the "why".** The workload mixes long sequential screening scans with repeated comparisons of a small working set; a cold reader seeing 2Q and the one-line comparison against LRU (scan vulnerability) and aged frequency counters (counter maintenance + project-switch lag) already has what they need to understand why 2Q was chosen—and to revisit it if production workload patterns change.

If you feel a future maintainer will still be tempted to swap 2Q back to plain LRU unless the full analysis (criteria weights, scan-resistance vs. adaptation speed vs. bookkeeping overhead) is laid out, we can definitely write `docs/intent/previews/decisions/cache-eviction-policy.md`.

Would you like to keep the `Decisions & Alternatives` row as drafted, or have me write the full decision doc? And how would you like to handle the 2Q sizing/behavior questions from the LLD probe above?