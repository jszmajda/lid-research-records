**What the current design means**

`docs/high-level-design.md:20` says, “A submitted job is a promise: members should be able to upload and walk away,” and the primary goal is unattended overnight printing. But `job-queue-design.md:10-16` says accepted jobs exist only in process memory and are lost during the power interruptions and OS updates the design explicitly anticipates.

Keeping the G-code file on disk does not preserve the promise. After a restart, the service may still possess the file bytes, but it has lost the job’s owner, target printer class, priority, queue position, and dispatch state. `QUEUE-004` only reconstructs what printers are currently running; it cannot reconstruct accepted but undispatched work.

Under *tenet cascade* — downstream mechanisms should support project-level promises unless an exception is explicit — these two levels currently disagree. The practical risks are silent job loss, members incorrectly believing a print remains queued, duplicate submissions after uncertain recovery, and lost fairness or staff ordering.

There is also a decision-capture issue. In-memory queuing is consequential enough that a cold reader will ask why it is acceptable, but the Decisions & Alternatives table does not record the tradeoff. Under *docs carry current intent* — questionable choices retain enough rationale for future readers — that leaves a future implementation session to rediscover or accidentally reverse the choice.

**Available Directions**

LID treats this as an intent decision, so the project needs your choice rather than an automatic correction:

1. **Make acceptance durable.** Persist enough job metadata to restore every accepted, undispatched job after restart. This preserves the current HLD promise.
2. **Keep the in-memory queue and record an explicit exception.** Explain why modest resource usage outweighs reliable acceptance and clearly expose the possibility of loss to members. The Decisions row should name the “submitted job is a promise” tenet being traded against and the accepted cost.
3. **Revise the project promise.** Define submission as best-effort rather than durable acceptance, then update the HLD goal and user-facing behavior accordingly.

Recording an exception would also resolve the missing decision-capture finding. Revising only the decision table, however, would not resolve the HLD conflict unless the exception is genuinely the intended product behavior.

**If You Choose Durability**

A small durable queue is the most direct design candidate. The project already expects SQLite for the printer registry, so queue metadata could use SQLite without introducing a separate storage system. The design should establish these invariants:

- Acceptance is reported only after both the G-code file and queue record are durable.
- Restart restores accepted, undispatched jobs with their target class, priority, and ordering.
- Startup reconciles restored records with jobs already running on printers.
- Recovery cannot dispatch the same job twice.
- Cancellation, completion, and failed dispatch have defined durable state transitions.
- Missing or corrupt file content produces visible recovery behavior rather than silent disappearance.

The LLD would then need to specify whether queue and registry data share one database, how ordering survives staff reordering, and what the authoritative job states are. Those details belong in `job-queue-design.md`, not the HLD.

Likely EARS coverage would include acceptance durability, restart restoration, running-job reconciliation, duplicate-dispatch prevention, and recovery failure visibility. `QUEUE-004` would need refinement because “rebuild farm state” currently hides the distinction between printer state and queued-job state.

The appropriate next step is to run `/linked-intent-dev` with a request such as: “Make accepted queue jobs durable across service restarts while preserving order and preventing duplicate dispatch.” That workflow will pause at the design decision, then cascade the selected intent through the LLD, EARS specs, tests, and implementation.