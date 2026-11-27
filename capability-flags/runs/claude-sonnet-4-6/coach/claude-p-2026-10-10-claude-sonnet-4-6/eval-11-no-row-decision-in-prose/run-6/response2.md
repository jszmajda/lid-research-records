F1 and F2 are related — let me walk them together since they both live on the same design choice.

**F1 — High. The in-memory queue can silently break the "submitted job is a promise" tenet on the very restarts the project anticipates.**

The job-queue LLD's Architecture section describes the in-memory design plainly: "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them." That's a real design choice, and it may be the right one for a mini-PC running a small makerspace queue. But the first HLD tenet is *"A submitted job is a promise: members should be able to upload and walk away."* The LLD also tells you the mini-PC takes *unattended OS updates and the occasional power blip* — events that happen overnight, while members are away, exactly when the promise is supposed to be most load-bearing. Under *tenet cascade* — mechanisms are evaluated against project tenets under conditions the project itself describes — this is a direct conflict: the tenet promises reliability; the in-memory store breaks that promise the moment the OS decides to restart at 3 a.m.

This matters because the tenet is the statement members and staff are working from when they decide to trust the system. A member who uploads from home, goes to sleep, and finds their job missing the next morning didn't experience a bug — they experienced a broken promise. If this trade-off is deliberate (simplicity wins, members can resubmit, the queue is explicitly not a guarantee), that's a viable call, but it means either the design needs to be adjusted or the tenet needs to be revised so it's not setting expectations the system can't keep.

**F2 — Medium. The no-persistence choice sits in the Architecture narrative, not in Decisions & Alternatives.**

The LLD's Architecture section describes the in-memory queue as an observed fact about how the system works. It never appears in the Decisions & Alternatives table, so there's no record of what was considered, what the accepted cost is, or why durability was traded against simplicity. Under *decision capture* — a choice a cold reader would question or try to reverse should appear in D&A with the rationale — this is exactly the kind of choice that will come up the moment someone asks "why doesn't the queue survive a restart?" The answer isn't on the page.

---

**What I'd recommend:** You have three paths, and picking between them is yours to make:

1. **Change the design** — persist accepted jobs to disk (SQLite is already there for the registry; it could hold the queue too). This resolves the tenet conflict cleanly and keeps the promise. If you go this route, update the Architecture section in `job-queue-design.md` to reflect persistence and add a D&A row recording the choice to store the queue in SQLite alongside the registry.

2. **Record the exception** — keep the in-memory design but add a D&A row that names the conflict honestly: "Queue persistence: in-memory only; trade-off: violates the 'submitted job is a promise' tenet under restart conditions; accepted cost: members may need to resubmit overnight jobs after an OS update; rationale: simplicity on modest hardware, and the failure mode is visible and recoverable." This also closes F2. You'd also want to revisit whether the tenet needs softening — "best-effort promise" or a qualification like "once dispatched, delivery is guaranteed" — so it doesn't over-promise.

3. **Revise the tenet** — if the project genuinely intends the in-memory design and the promise the tenet makes is aspirational rather than architectural, rewrite the tenet to reflect what the system actually guarantees. This is the riskiest path because tenets shape downstream decisions; a weaker tenet means future agents lean less strongly toward durability across the whole system.

My read is that option 1 is the cleanest — SQLite is already in scope, the queue data is small, and "persisted job queue" is a natural fit for a system making reliability promises — but you know the hardware constraints and the makerspace context better than I do. If you want to sketch what option 1 would look like in the LLD before touching code, `/linked-intent-dev` with a description of the change is the right entry point.