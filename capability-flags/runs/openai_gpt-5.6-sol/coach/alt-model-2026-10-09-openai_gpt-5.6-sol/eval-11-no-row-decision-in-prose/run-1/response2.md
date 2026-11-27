**F2: The current mechanism conflicts with declared intent.** `docs/intent/job-queue/job-queue-design.md:10-14` says the mini-PC experiences unattended updates and power blips, then specifies that accepted but undispatched jobs exist only in memory and disappear after a restart. Polling printers on startup reconstructs running jobs, but not pending jobs. Persisting uploaded files by content hash also does not preserve the member, printer class, priority, queue position, job ID, or dispatch state needed to reconstruct the queue. Under *tenet cascade* — downstream mechanisms should lean with the HLD’s tenets and goals — this works against both “a submitted job is a promise” and evening-upload/overnight-print/morning-pickup. A routine restart could silently turn an accepted job into no job at all while the member is away.

**F3: The tradeoff is not captured.** Keeping accepted work only in memory is a consequential and reversible choice, but the Decisions & Alternatives table does not explain why durability was rejected or what cost was accepted. Under *docs carry current intent* — a cold reader should be able to reconstruct choices they might reasonably question — a future implementer cannot tell whether this is deliberate, an optimization for modest hardware, or an unfinished design. Because the HLD and LLD point in opposite directions, an implementer would have to invent the governing intent.

There are three valid ways to resolve the tenet conflict:

1. **Change the design:** Preserve accepted queue entries across restarts. The existing SQLite dependency makes a durable queue table an obvious option to evaluate, though an append-only journal or another small local store could also satisfy the intent. The design should define startup recovery, ordering preservation, and reconciliation between pending entries, on-disk G-code, and jobs already running on printers.
2. **Record an explicit exception:** Keep the in-memory queue, but add a Decisions & Alternatives row naming the submission-promise and unattended-operation tradeoff, why durability is not worth its cost, and what members experience after a restart. This would also close the decision-capture finding, but the acceptance UI and HLD goals would likely need adjustment so the service does not promise behavior it cannot provide.
3. **Revise the upstream intent:** If “accepted” jobs are intentionally best-effort until dispatched, revise the HLD tenet and overnight-printing goal to say so. That produces a coherent arrow, but materially changes the product promise.

I would resolve that product choice before adding more specs. If durability remains part of the promise, the next workflow should update the queue LLD and add EARS behavior covering at least:

- An accepted job survives service restart.
- Recovery preserves printer class, priority, and FIFO position.
- Startup reconciles persisted pending jobs with jobs printers report as running.
- Missing or corrupt G-code is surfaced rather than silently dropping the job.
- Recovery cannot dispatch the same job twice.

Run `/linked-intent-dev` with a request such as: “Make accepted queue jobs durable across service restarts while keeping the service suitable for the mini-PC.” That will walk the change through the design decision, edge audit, specs, tests, and implementation rather than prematurely choosing a storage schema.

Which intent do you want: durable acceptance, an explicit best-effort exception, or a revised product promise?