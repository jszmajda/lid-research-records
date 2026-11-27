I'd skip it: the length of the argument isn't what earns a decision doc, and this choice doesn't need one.

- **Nothing else is sized around it.** 2Q lives entirely inside the preview worker. The HTTP contract, render queue and 12 GiB budget are the same under all three policies, so reversing it later costs one node's internals.
- **The row already answers "why not LRU?"** The Decisions table in `docs/intent/previews/previews-design.md` names both rejected policies and the reason each lost. A full doc would restate that at greater length.
- **A full doc invites the re-argument you want to end.** It lays the options out at full resolution to be re-judged, which is worth it only for a choice that stays live.

There is one thing worth salvaging from the three meetings and the thread. If they produced evidence the row lacks, such as a measured screening length, an incident where comparison sheets were evicted, or a criterion someone insisted on, tell me and I'll put it in the row's rationale.

It is your call, though. If you still want the doc, say so and I'll write it at `docs/intent/previews/decisions/` and link it from the row.

The two calls and five gaps from my last message are still waiting on you either way.