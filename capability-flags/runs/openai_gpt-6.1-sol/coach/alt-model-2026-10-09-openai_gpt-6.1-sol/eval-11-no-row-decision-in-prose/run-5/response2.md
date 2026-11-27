The issue is **what “accepted” promises a member**, rather than whether an in-memory queue is inherently unsuitable.

### F1: Restart behavior conflicts with the member promise

In `docs/intent/job-queue/job-queue-design.md:10–14`, the service anticipates unattended OS updates and power blips, yet accepted, undispatched jobs disappear on restart. Keeping the G-code on disk makes resubmission cheaper, but does not preserve the job’s place in the queue or get it printed. A member could upload in the evening, receive acceptance, and arrive the next morning to find that nothing happened. Under *tenet cascade*—component mechanisms should uphold the project’s declared priorities—that works against the HLD’s “submitted job is a promise” tenet and upload-and-walk-away goal. The next step is to decide explicitly which promise you want acceptance to carry.

### F4: The storage choice needs its trade-off recorded

The queue design states that jobs live only in memory, but its Decisions & Alternatives table does not explain why that choice is worth requiring members to resubmit after restarts. Under *docs carry current intent*—a future reader should understand consequential choices without the original conversation—this deserves a decision row. Otherwise, one future implementation may preserve jobs while another intentionally drops them, each following a different part of the documentation. A fuller row naming the alternative, the benefit, and the accepted cost should be enough; this does not call for a separate decision document.

### Your choices

There are three coherent ways to resolve the tension:

1. **Change the queue design to preserve the promise.** Make accepted jobs durable before acknowledging acceptance. SQLite is a plausible small-service option given the registry’s existing use of it, though that does not require sharing its database. The design would need to specify persisted queue order, priority, file references, and job state. It also needs restart reconciliation: if a printer accepted a job just before the service crashed, recovery should avoid dispatching it twice. Durability protects the queue; it does not by itself settle that handoff.

2. **Keep the in-memory design and record an explicit exception.** Add a Decisions row explaining why simplicity outweighs the upload-and-walk-away promise during restarts, naming that tenet and the accepted resubmission cost. Acceptance and the queue UI should communicate that limitation clearly. This also closes F4’s missing-rationale finding, while leaving a deliberate exception to the tenet.

3. **Revise the HLD promise.** If best-effort scheduling is what you actually want, narrow the tenet and goal so members are expected to monitor or resubmit jobs. Then align the queue design and specs with that expectation.

**My recommendation is to settle the acceptance contract first**, then walk the chosen change through `/linked-intent-dev`: design, EARS requirements, behavioral tests, and implementation. That keeps storage choices downstream of the promise you intend to make.

Do you want an accepted job to survive a service restart without the member taking any action, or is best-effort acceptance an intentional limit?