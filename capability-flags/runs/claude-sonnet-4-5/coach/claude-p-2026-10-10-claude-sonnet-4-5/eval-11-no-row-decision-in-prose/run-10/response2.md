**F1 — High. The job-queue design conflicts with the "promise" tenet without recording the tradeoff.**

The HLD establishes "A submitted job is a promise: members should be able to upload and walk away" as a tenet, but the job-queue LLD's architecture section states "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them." A cold reader holding both docs would question this: if a job is a promise, why does a restart break it? The tension gets sharper when they see that G-code files *are* persisted to disk (under content hash), but queue state isn't — files survive restarts, accepted jobs don't.

The implicit reasoning never appears on the page: restarts are rare (the mini-PC takes "unattended OS updates and the occasional power blip"), and persisting queue state would require more machinery than the "stays small" tenet allows for such an infrequent event. That's a defensible tradeoff between two load-bearing tenets, but it lives only in the design conversation that produced these docs, not in the docs themselves. This is exactly what the *decision capture* principle protects against — a future session reading these docs cold will either miss the tension entirely and assume the design is incoherent, or notice it and have to re-derive the reasoning (and might land on a different answer).

Under LID's *tenet cascade* principle — designs should lean the way tenets say to lean, and when they can't, the exception gets recorded — a mechanism that works against a tenet under described operating conditions needs to either change or be explained. Here the operating condition is "a restart happens while jobs are queued," the mechanism is "in-memory queue state," and the tenet being traded is "a promise."

**You have three remedies, your choice:**

1. **Record the exception.** Add a row to the job-queue Decisions & Alternatives table naming the tenet conflict explicitly. Something like: "Queue persistence | Ephemeral (in-memory only) | Persisting queue state across restarts would honor 'a job is a promise' fully, but restarts are rare (OS updates, power blips) and the added complexity conflicts with 'stays small'; accepted cost: members resubmit jobs lost to restarts." This closes both the tenet-conflict finding and the decision-capture gap.

2. **Change the design.** Persist the queue state — SQLite is already in use for the registry, so a second table for accepted jobs would fit the existing stack. This would honor the promise tenet at the cost of a bit more code, and you'd update the LLD to reflect it.

3. **Revise the tenet.** If "a promise" was aspirational but the restart behavior is actually fine for your makerspace's reality, weaken the tenet to match what you're willing to build — maybe "A submitted job is visible and tracked" or add a caveat "...except across service restarts." Then the docs are coherent again.

Option 1 is the lightest lift and keeps the design tension visible for future sessions. Option 2 makes the system match the tenet. Option 3 makes the tenet match the system. Which way feels right for how your makerspace actually works?