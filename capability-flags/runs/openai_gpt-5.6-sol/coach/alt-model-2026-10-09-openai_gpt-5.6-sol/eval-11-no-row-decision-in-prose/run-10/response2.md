**F2 and F7 describe the same design choice from two angles: a product-intent conflict and missing rationale.** `job-queue-design.md:10` says the mini-PC experiences unattended updates and power blips, while line 14 says every accepted but undispatched job disappears after a restart. That works against the HLD tenet that “a submitted job is a promise” and the goal of uploading in the evening and walking away until morning. Under *tenet cascade* — leaf mechanisms should follow project-level preferences unless an exception is explicit — a member can receive an acceptance response, leave, and later discover that the promised job silently vanished.

The persisted G-code does not close that gap. The content hash makes resubmission cheaper, but the member still has to notice the loss and resubmit. `QUEUE-004` also only reconstructs currently running printer jobs; polling printers cannot recover pending jobs, their ordering, staff priority, or previous staff reordering. Future implementers could easily misread “rebuild farm state” as broader recovery than the design permits.

The choice also lacks a Decisions & Alternatives row. Under *decision capture* — a cold reader should be able to reconstruct a consequential tradeoff and its accepted cost — it is unclear whether in-memory queuing is deliberate simplicity, an early-stage placeholder, or an accidental contradiction. Because the project explicitly anticipates restarts, this is a choice future readers will question.

LID leaves three legitimate remedies for you to choose:

1. **Change the design to preserve the promise.** Persist each accepted queue entry and its ordering before confirming acceptance. Startup then restores pending jobs and reconciles them with jobs reported by printers. The LLD should also define what happens around an interrupted dispatch so recovery cannot send the same job twice.
2. **Keep the in-memory queue and record the exception.** Add a Decisions & Alternatives row naming the “submitted job is a promise” tenet being traded away, why modest-resource operation justifies that trade, and the accepted user-visible cost. The UI and specs should then make acceptance explicitly best-effort across restarts rather than silently implying durability.
3. **Revise the HLD tenet.** If the intended product only offers unattended operation while the service remains running, narrow the promise at the HLD level and cascade that weaker guarantee into the queue design and specs.

If you choose durable acceptance, I would update the intent in this order:

1. Amend `job-queue-design.md` to define the durable acceptance boundary, startup restoration, and interrupted-dispatch reconciliation.
2. Add a Decisions & Alternatives row comparing durable queue metadata with an in-memory queue and naming the storage and complexity cost.
3. Replace or sharpen `QUEUE-004` and add specs covering persistence before acknowledgment, restoration with ordering intact, and duplicate-dispatch prevention.
4. Run `/linked-intent-dev` with that change description so the revised design proceeds through specs, tests, and implementation in order.

Which product guarantee do you want: durable accepted jobs, explicitly best-effort acceptance, or a narrower HLD promise?