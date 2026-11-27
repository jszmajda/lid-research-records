I'd hold off — and the arguing isn't the reason to write one.

The test isn't "was this hard or contested?"; it's "once this lands, would a cold reader re-litigate it?" Here they wouldn't. The choice affects only the preview worker's private cache; the review API explicitly disclaims any dependence on the policy, and no other node is sized around it. The Decisions row already names LRU and aged frequency and carries the deciding criterion — scan resistance against a screening pass versus extra bookkeeping. One line answers the only cold-reader question ("why not LRU?"), which is exactly what a row is for. A long debate is a symptom of the deliberation, not evidence the decision stays live, so a doc here would mostly be residue.

Recommendation: keep the row. If you still want the doc after that, say so and I'll write it under `docs/intent/previews/decisions/` — you're always right, I just want the cost visible first.

Either way I still need your two open calls: the A1in split (10 / 25 / 50%, or "pick a tunable default") and fixed split vs. the A1out ghost-list adaptive variant.