**F2 — High. The job-queue design loses accepted jobs on restart, contradicting the "A submitted job is a promise" tenet, with no decision record.**

The HLD's first tenet states "A submitted job is a promise: members should be able to upload and walk away." But `job-queue-design.md:14` says "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them." The tenet says members can walk away; the design requires them to notice the job was lost and come back to resubmit. This is a **tenet cascade** question — does this mechanism, under the operating condition "mini-PC restarts before dispatch," work against one of the project's own tenets? — and also a **decision capture** gap: the choice to accept job loss on restart is live (a cold reader holding the docs would question it, especially after reading the tenet), but no Decisions row or decision doc explains what was traded and why.

Why this matters: Your HLD's tenets are the tie-breakers for future decisions no spec anticipated. When a design contradicts a tenet without recording the exception, future sessions don't know whether the contradiction was deliberate or accidental drift. If a session touches restart behavior or queue persistence later — say, to add a new recovery path — it will read the tenet, assume the promise is load-bearing, and may "fix" the behavior you've already chosen. The tenet stays misleading until the gap is closed.

You have three options:

1. **Change the design** to honor the tenet — persist accepted jobs to disk (maybe alongside the G-code content hash) so they survive restarts. This keeps the promise real.

2. **Record the exception** — add a row to the job-queue Decisions & Alternatives table naming the tenet traded against and why. Something like: "Job persistence | In-memory only; jobs lost on restart | Disk persistence rejected: adds state recovery complexity on modest hardware, and restarts are rare enough that manual resubmit is acceptable; accepted cost: contradicts 'job is a promise' tenet for the restart window." This closes both the tenet-conflict and the decision-capture findings at once. The tenet stays as written, and future sessions know the trade was deliberate.

3. **Revise the tenet** — if job loss on restart is actually fine and the tenet overstated the promise, weaken the tenet to what the design actually delivers. Maybe "A submitted job should dispatch without member attention *unless the service restarts*" or drop that tenet entirely and keep only the other two. This option is rare — usually the tenet reflects real user expectation and the design just hasn't caught up yet — but it's yours to choose.

Which direction feels right for your project?