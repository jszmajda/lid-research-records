My honest read: I'd lean row-only, but it's your call.

The choice is genuinely close — LRU is the obvious default, and a cold reader could reasonably ask why we pay for two queues. That's the "would they re-litigate it?" half of the test, and it passes. The other half doesn't: this stays entirely inside the preview worker, and no other node is being sized around it. That's exactly the case the method says a Decisions row is for — a full doc here risks memorializing the argument rather than the current intent, and "it was heavily debated" isn't itself the bar.

That said, if you want it, I'll write it properly: a decision doc under `docs/intent/previews/decisions/` with the selection criteria (scan resistance, bookkeeping cost, adaptation to project switches), the three options scored against them, the selection and its consequences, and the split as the tunable left open — linked from the Decisions row.

Which do you want: **row only**, or **full decision doc**? And I still need your call on the LLD itself and the provisional 3 GiB / 9 GiB split before I move to EARS specs.