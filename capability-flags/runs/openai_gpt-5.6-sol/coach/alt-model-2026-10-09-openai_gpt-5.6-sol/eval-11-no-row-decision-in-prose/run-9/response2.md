The key issue is that the design makes a stronger promise than the queue can currently keep.

`docs/high-level-design.md:20` says, “A submitted job is a promise: members should be able to upload and walk away.” The primary goal is evening upload followed by unattended overnight printing. Meanwhile, `job-queue-design.md:10` explicitly anticipates OS updates and power blips, and line 14 says accepted but undispatched jobs disappear after either event.

That is not merely an unhandled edge case. It is a documented operating condition directly defeating a project tenet and goal. Retaining the G-code by content hash preserves the payload, but not the job intent: submitter, printer class, priority, queue position, or the fact that it was accepted. Requiring resubmission also assumes the member is available to notice the restart, which conflicts with “upload and walk away.”

Under *tenet cascade* — leaf designs should follow project-level preferences unless an exception is deliberate — the project needs to make one of three choices:

1. **Keep the promise and change the design.** Persist accepted queue metadata before confirming acceptance, restore pending jobs after startup, and reconcile that state with what printers report they are currently running.
2. **Keep the in-memory queue and record an explicit exception.** Add a Decisions & Alternatives row stating that accepted jobs may be lost during restarts, naming the reliability tenet being traded against and explaining why that cost is acceptable.
3. **Revise the HLD promise.** Narrow the tenet and overnight-printing goal so they accurately describe a best-effort queue rather than durable acceptance.

Those are intent choices, so I would not silently select one as a coaching action. Conditional on the current HLD remaining authoritative, however, option 1 is the design that follows from it.

The same choice is also under-captured. A cold reader will naturally question why a service designed for unattended operation stores accepted work only in volatile memory. Under *docs carry current intent* — consequential choices and accepted costs should be reconstructable without prior conversation — `job-queue-design.md` should contain a Decisions & Alternatives row for queue durability. A separate decision document would be unnecessary unless you want to preserve a substantial comparison of storage and recovery strategies.

If durable acceptance is the intended direction, I would walk the change through `/linked-intent-dev` in this order:

1. Update `job-queue-design.md` to define the durable job record and startup reconciliation behavior without dropping into schema-level implementation detail.
2. Add a Decisions & Alternatives row comparing durable metadata with the current memory-only approach.
3. Add EARS specs covering acceptance persistence, restart recovery, and dispatch reconciliation.
4. Audit the boundary with `printer-registry`, especially what happens when a restart occurs during dispatch and a printer reports a job already running.
5. Write tests first for restart before dispatch, restart during dispatch, missing payload, and recovery from printer polling failures.
6. Implement only after those behaviors are settled.

The most important edge to resolve is the dispatch handoff. “Persist before acceptance” prevents queued jobs from disappearing, but a restart between sending a job and recording the printer’s acknowledgement can otherwise cause either duplicate dispatch or a stranded queue entry. The design needs an explicit reconciliation rule for that case before implementation begins.