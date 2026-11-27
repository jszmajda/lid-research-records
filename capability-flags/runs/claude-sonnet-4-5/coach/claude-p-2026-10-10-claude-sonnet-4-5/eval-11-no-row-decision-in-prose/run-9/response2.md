You've caught something I should have flagged — this is a **tenet cascade** finding I missed in my initial review.

**The conflict.** The HLD states "A submitted job is a promise: members should be able to upload and walk away" as a tenet, but the job-queue LLD specifies that the queue is held entirely in process memory, and that "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them." The LLD even notes that the mini-PC "takes unattended OS updates and the occasional power blip." Under *tenet cascade* — designs should lean the way the HLD's tenets and goals say to lean — the in-memory choice works directly against the promise tenet whenever the service restarts. A member who uploaded in the evening and walked away might return to find their job was silently dropped.

**Why this matters.** The tenet-vs-mechanism conflict sits unacknowledged in the docs. A future session reading the tenet will try to honor it — maybe by adding retry logic, or notification when jobs are lost, or persistence — and only then discover the in-memory decision. The conflict also isn't recorded in the Decisions & Alternatives table, so there's no explanation of *why* the team accepted breaking the promise. That missing record is a decision-capture gap on top of the tenet conflict.

**What I'd recommend** — you have three remedies, and the choice is yours:

1. **Honor the tenet.** Persist accepted jobs to disk (or the same SQLite file the registry already uses) so they survive restarts. The promise becomes real.

2. **Record the trade-off.** Add a Decisions & Alternatives row to the job-queue LLD naming the tenet traded against and why: "In-memory queue accepted over persisted queue: simpler, no SQLite contention, and restart is rare enough that resubmission is tolerable; accepted cost: jobs lost on restart break the upload-and-walk-away promise." This closes the decision-capture gap and makes the conflict visible, though it leaves the tenet stated but unmet.

3. **Revise the tenet.** If the in-memory choice is load-bearing and the promise isn't actually guaranteed, soften the tenet to match reality: "Members should be able to upload and walk away *in the common case*" or drop it entirely. A tenet the design can't honor isn't guiding future decisions.

My read: the tenet as written is strong and user-facing — "a submitted job is a promise" sets a clear expectation. If you mean it, persist the jobs. If restart-based loss is genuinely acceptable, record why in a Decisions row so future sessions don't try to "fix" it.