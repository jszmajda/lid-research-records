**The Core Tension**

`docs/intent/job-queue/job-queue-design.md:14` says accepted-but-undispatched jobs live only in memory and disappear after a restart. The same document explicitly anticipates unattended OS updates and power blips at line 10.

That conflicts with two higher-level statements:

- HLD tenet: “A submitted job is a promise: members should be able to upload and walk away.”
- HLD goal: “Evening upload, overnight print, morning pickup.”

A member can receive acceptance, walk away, and return to discover that the job silently vanished during a routine restart. Under *tenet cascade* — leaf mechanisms should lean with project-level promises — the queue design currently works against the intended product behavior under a normal operating condition.

**Why It Matters**

This is more than a storage implementation choice. It defines what “accepted” means:

- If acceptance is durable, it promises eventual dispatch unless the user or staff cancels the job.
- If acceptance is volatile, it means only “queued until this process stops.”

The current UI-facing concept says the former while the architecture provides the latter. Implementing the design as written would likely produce internally consistent code and tests that still violate the user-level promise.

The behavior is also absent from `job-queue-specs.md`. `QUEUE-004` rebuilds farm state by polling printers, but it does not say what happens to previously accepted queued jobs. That leaves future implementation work free to guess at a load-bearing behavior.

**Decision Capture**

The in-memory choice is not included in the Decisions & Alternatives table. Under *docs carry current intent* — a cold reader should be able to reconstruct consequential choices and accepted costs — this decision needs a row because a reader will naturally question why expected restarts are allowed to lose accepted work.

The row should name:

- The durability model chosen.
- The principal alternative rejected.
- The tenet or goal being traded against, if volatility remains.
- The accepted operational cost and any mitigation.

A separate decision document would be excessive unless choosing persistence requires substantial research across several storage strategies. A Decisions & Alternatives row is probably sufficient.

**Available Directions**

1. **Make accepted jobs durable.** Persist queue metadata and reconstruct pending jobs after restart, while continuing to keep uploaded G-code on disk by content hash. Add specs covering durable acceptance, restart recovery, and reconciliation with jobs already running on printers. This aligns the leaf design with the current tenet and goal.

2. **Keep the volatile queue but record an explicit exception.** Preserve the in-memory design, add a Decisions row naming the submitted-job tenet being traded away, and specify visible recovery behavior. For example, the service could warn that acceptance lasts only until restart, retain enough contact information to notify affected members, or expose lost submissions for resubmission. The HLD promise would still need qualification because “upload and walk away” would not be dependable.

3. **Revise the HLD promise.** If simplicity on the mini-PC matters more than durable submissions, redefine acceptance as best-effort and adjust the overnight-print goal accordingly. The LLD and specs could then remain intentionally volatile, but the resulting product is materially different from the one currently described.

LID treats these as user choices rather than selecting one automatically. Given the project’s purpose, the key question is: **does telling a member that a job was accepted promise that it will survive a routine service restart?**

If yes, direction 1 should drive a `/linked-intent-dev` change through HLD confirmation, the queue LLD, new EARS specs, tests, and implementation. If no, choose direction 2 or 3 and make that reduced guarantee explicit before implementation begins.