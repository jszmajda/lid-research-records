The skill has a specific test for this: not "was it hard to decide?" but "would a cold reader of the finished LLD find the choice non-obvious and be tempted to reverse it?"

My read: probably not. The LLD's Context section already says editors alternate long screening scans with repeated comparisons of a small working set — that's the whole discriminator. A cold reader who reads that context will follow the logic from workload to 2Q. LRU is simpler, but "simpler but vulnerable to scans given this workload" is a one-sentence rationale that a table row can carry.

A decision doc earns its place when the competing options and criteria have to be laid out at length before the choice makes sense. Here the criteria are already in the LLD body; the doc would mostly restate them.

The skill also flags that people offered a doc tend to say yes whether they need it or not — which is exactly what's happening here. The debate was long, but that's a property of the deliberation, not the landing.

My recommendation: a Decisions table row. Something like:

| Eviction policy | 2Q | LRU, frequency with aging | LRU is vulnerable to sequential screening scans evicting the small comparison set; frequency with aging adds counter maintenance and lags project switches; 2Q separates first-use entries from reused ones, protecting the comparison set at the cost of two queues and a queue-size parameter to tune. |

That's the full rationale a cold reader needs. If you still want the full doc — the debate felt important enough to memorialize — I'll write it, but I wouldn't on the merits.