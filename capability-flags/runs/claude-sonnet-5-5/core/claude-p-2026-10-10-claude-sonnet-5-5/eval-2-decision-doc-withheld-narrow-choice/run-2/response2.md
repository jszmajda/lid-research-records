My recommendation is to keep this as a Decisions & Alternatives row and not write a full decision doc.

The test is whether a cold reader of the landed design would re-litigate the choice without the full tradeoffs in front of them. A long debate doesn't change that. The row already carries the three options, the workload that drove the choice, and the cost accepted. A reader who wonders "why not LRU?" gets the answer in one line.

Two things would normally push a choice toward a full doc, and neither applies here:
- **Other nodes sized around it.** The review API, the render queue, the preview interface and the disk budget are all unchanged by the policy. The design pins this explicitly. A reader of any other node never meets this decision.
- **A choice that stays contested after it lands.** 2Q follows from the workload described in the HLD (long screenings plus repeated comparison of a small set). The open parts are tuning questions (share size, ghost list, restart behavior), and those belong in Open Questions, not in a doc about which policy.

One thing could change my answer. If the team expects to revisit the policy after the pilot, a doc would help the next person re-run the judgment from the criteria. In that case I'd write the revisit trigger into the row itself, for example "revisit if pilot hit rates show the first-use share is starved or scans still evict comparison sheets".

If you still want the full doc, say so and I'll write it. It would sit at `docs/intent/previews/decisions/replacement-policy.md` with the options weighed against gates and criteria, tied to the tenets on private bookkeeping and cache misses as ordinary behavior, and linked from the row. It is your call.

Independent of that, the six edge-case gaps from my last message are still waiting on your triage, especially items 2 and 5, before I move to the specs.