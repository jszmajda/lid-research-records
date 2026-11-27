I can see why you'd feel that way after the deliberation, but let me apply the test from the landed state:

**Would a cold reader re-litigate this choice?** The Decisions & Alternatives table now captures:
- Three credible options (LRU, frequency-based, 2Q)
- The workload pattern that drives the choice (alternating long screenings with repeated comparisons)
- Why each alternative was rejected (LRU's scan vulnerability, frequency-based's staleness)
- Why 2Q fits (scan resistance for the comparison working set)

The choice is contained — other nodes don't need to be sized around it. The HLD's tenet already says cache paths and replacement bookkeeping stay private to the preview worker, so this decision doesn't ripple.

**My read**: The table row settles it. A cold reader seeing "2Q with 25/75 split" can reconstruct the judgment from that rationale without needing the full deliberation history. The amount of arguing doesn't make the landed result more complex — it means you worked hard to get to a choice that now reads cleanly.

**However**, if you think a future reader would question "why accept the two-queue overhead instead of simpler LRU?" despite that rationale, or if the 25/75 parameter feels like it will need re-tuning and you want the criteria preserved at higher fidelity, then yes — capture it as a decision doc.

Your call. Table row is my recommendation, but you know better than I do whether this will stay live.