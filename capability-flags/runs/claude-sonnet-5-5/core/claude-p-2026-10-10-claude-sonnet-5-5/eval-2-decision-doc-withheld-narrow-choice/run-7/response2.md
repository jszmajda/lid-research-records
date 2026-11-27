I don't think this one earns a decision doc, and I'd keep the table row.

The test is whether a cold reader of the landed design would question the choice or be tempted to reverse it. How long the debate ran doesn't count toward that.

- **The choice is contained.** It only changes the preview worker's private replacement bookkeeping. The review API, render queue, HTTP contract, and disk budget are identical under all three options, and no other node is being sized around the result.
- **The row already gives the cold reader what they need.** It says why 2Q was chosen over LRU and aged frequency, tied to the workload (long one-pass screenings alternating with repeated comparisons). A reader who wonders "why not LRU?" gets the answer in one line.
- **The remaining live questions are tuning, not selection.** The probation share and the definition of reuse are open questions in the LLD, and they will probably be settled by observing real screenings, not by re-arguing the policy.

If measured workload evidence came out of the meetings and the 180-message thread, that would change my view. Numbers like the share of one-use sheets in a screening, or working-set sizes during comparison, would let a future reader re-run the judgment. I'd fold those into the Rationale cell first, or into a decision doc if there's enough of them to need the space.

If you'd still like the full doc, I'll write it. It would be `docs/intent/previews/decisions/eviction-policy.md`, linked from the Decisions row, and it would set out the criteria, the three options, and the verdict. Do you want that, or should we stay with the row and go on to the two open decisions (reuse rule, probation share and history length)?