The decision doc is written and linked. We still have the edge-case probe gaps from before that need your triage — that's the one piece left before this Phase 2 stop is closed out.

Decision doc done: `docs/intent/previews/decisions/eviction-policy.md`, linked from the LLD's Decisions row.

Still outstanding from my last message — please triage the edge-case probe (resolve now vs. defer):
1. What happens when a single sheet's size exceeds its queue's bound by itself?
2. What happens when both queues are drained but the incoming sheet still doesn't fit?
3. What happens when a key already in A1in/Am is re-rendered (same clip/revision/renderer-version) — a hit, or a duplicate/overwrite?
4. Does rule 4's direct-to-Am admission run the budget check before or after, and could it evict the entry it just promoted?
5. Does a single A1in eviction suffice before rechecking the budget, or does A1in drain fully before Am eviction ever triggers?
6. Are the 3/9/12 GiB bounds allowed to be transiently exceeded between evict and admit, or must they never cross even momentarily?
7. An entry evicted from Am (not ghosted) that's requested again — does it re-enter A1in from scratch, losing "reused" status? Intended?
8. Can a key silently fall out of A1out (cap eviction) before being re-requested, reverting its future re-admission to probation?
9. Can A1out hold duplicate keys for the same cache key, or does a repeat ghost-insertion refresh the existing one?
10. If a key is in A1out while a render for it is already in flight, is that a hit, a miss, or undefined against rule 4's framing?
11. What breaks ties for "head of Am" when multiple entries share identical recency?

Once you've triaged these I'll fold the resolutions into the LLD and treat Phase 2 as approved.