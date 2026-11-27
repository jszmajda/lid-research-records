**F1 — High. Accepted jobs are not durable despite the project defining acceptance as a promise.** `docs/intent/job-queue/job-queue-design.md:14` says queued jobs exist only in process memory and disappear after a restart. The same document says the mini-PC experiences unattended updates and power interruptions, so this is an expected operating condition rather than an exceptional failure. It conflicts with the HLD tenet that “a submitted job is a promise” and the goal of uploading in the evening and collecting the result the next morning. Under *tenet cascade* — leaf designs should follow project-level preferences unless they explicitly record an exception — the current queue design leans against the intent above it.

Keeping G-code under a content hash does not preserve the job itself. After a restart, the service loses the owner, target printer class, queue position, priority, submission time, and any staff reordering. `QUEUE-004` only reconstructs jobs already running on printers; it cannot reconstruct accepted jobs that had not dispatched. Members may not even know they need to resubmit.

There are three valid ways to resolve this, depending on which intent is authoritative:

1. **Change the queue design.** Persist accepted-job metadata while continuing to keep G-code files on disk. A small SQLite-backed queue would fit the existing single-machine architecture and “service stays small” tenet. Acceptance should occur only after both the G-code and queue record are durable; startup should restore pending jobs and reconcile them with jobs reported by printers.

2. **Record an explicit exception.** Keep the in-memory queue, but add a Decisions & Alternatives row naming the “submitted job is a promise” tenet and overnight-printing goal being traded away, why volatility is acceptable, and what users experience after restart. The specs would then need to define the resulting loss and notification behavior. This preserves the implementation choice but makes the service materially best-effort.

3. **Revise the HLD intent.** If submission was never meant to promise durable queuing, rewrite the tenet and overnight goal to describe best-effort behavior, then cascade that meaning into the queue design and specs. This is the clean option when the HLD currently overstates the intended guarantee.

If durable acceptance remains the intended promise, the corresponding EARS coverage should include at least:

```text
When the system confirms a job as accepted, the system SHALL persist
the job and its queue metadata before returning confirmation.

When the service starts after an interruption, the system SHALL restore
accepted jobs that had not completed or been cancelled.

When restored queue state conflicts with a printer's reported current job,
the system SHALL reconcile the state without dispatching the same job twice.
```

The exact IDs and reconciliation policy should be settled during design rather than copied directly from these sketches.

Because this is a fresh project and the choice changes behavior from HLD through code, use `/linked-intent-dev` with a request such as: “Make accepted queue jobs survive service restarts.” It will walk the decision through the HLD, queue LLD, EARS edge cases, tests, and implementation in order.

Which intent should govern: durable acceptance, an explicit volatility exception, or best-effort submission?