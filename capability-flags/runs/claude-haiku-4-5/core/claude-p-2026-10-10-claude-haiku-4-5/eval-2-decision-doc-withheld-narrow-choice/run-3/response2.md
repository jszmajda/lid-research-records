Yes, I'd recommend it. This choice clears the bar:

- **Genuinely contested**: Three credible options, each with real tradeoffs (bookkeeping vs. eviction behavior vs. adaptation speed), and 180 messages of debate signals a live choice that didn't have a dominating option.
- **Cold readers will question it**: Without seeing the tradeoff matrix (LRU's scan vulnerability vs. 2Q's queue overhead), someone reviewing this design in six months would reasonably wonder why you chose the more complex approach and might be tempted to simplify back to LRU.
- **Other design nodes size around it**: The 3 GiB / 9 GiB split, the promotion mechanics, the deduplication handling during eviction — all downstream decisions lean on this choice being sound.

The decision doc would live in `docs/decisions/preview-cache-eviction-strategy.md` and record the three options, the criteria you weighed (sequential-screening resilience, bookkeeping cost, project-switch adaptation, tuning complexity), and why 2Q won — so a future reader can re-run that judgment without re-litigating.

**Should I draft it?** It would hold the context from those three meetings so the next person doesn't have to reconstruct the decision from scratch.