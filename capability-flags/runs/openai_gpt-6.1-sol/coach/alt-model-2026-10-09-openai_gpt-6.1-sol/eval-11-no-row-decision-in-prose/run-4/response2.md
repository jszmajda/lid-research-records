The issue is that **“accepted” currently means less than the HLD promises**: the service can acknowledge an upload, then forget the queued job during an ordinary restart.

### F1 — The design conflicts with the unattended-printing promise

In `docs/intent/job-queue/job-queue-design.md:10–14`, unattended OS updates and power blips are expected operating conditions, but accepted, undispatched jobs live entirely in memory. Keeping the G-code on disk preserves the file, not its place in the queue or the obligation to print it. Polling printers on startup recovers jobs already running; it cannot discover jobs never sent to a printer. Under *tenet cascade* — component designs should carry out the project’s stated priorities — that works against “a submitted job is a promise” and evening-upload/morning-pickup. A member can reasonably walk away after acceptance and find no print the next morning. I recommend explicitly resolving that conflict in the design rather than leaving future implementations to interpret the promise.

### F2 — The trade-off needs a recorded rationale

The same LLD’s Decisions & Alternatives table explains scheduling order, identifiers, and upload limits, but not memory-only queue storage. Under *docs carry current intent* — a cold reader should understand consequential choices without the original conversation — this choice deserves a row because a reader would naturally question it against the reliability promise. The row should identify the alternative considered and the cost accepted; it should not invent a rationale after the fact. A fuller table row is sufficient here; a separate decision document would add little.

### Your choices

There are three ways to reconcile the documents, depending on what you intend:

1. **Change the design to preserve the promise.** Persist accepted queue records and their ordering, then restore them after restart. SQLite is already part of the registry design, so it is a candidate worth evaluating. Acceptance would need to happen only after the file and queue record are durably recoverable. Recovery also needs a rule for a crash after a printer accepts a job but before the service records that fact, so restarting does not blindly dispatch it again.

2. **Keep the design and record an explicit exception.** State that accepted, undispatched jobs may be lost on restart, name the reliability tenet and overnight-print goal being traded against, and explain why that cost is acceptable. This also addresses F2’s missing rationale. It makes the trade-off explicit, but the member-facing meaning of acceptance still needs to match it.

3. **Revise the HLD’s promise.** If best-effort queueing is the intended product, narrow the tenet and goal accordingly, then align the LLD, specs, and member-facing behavior with that contract.

**My recommendation for the next step is to settle the acceptance contract first:** does a successful upload mean the service retains responsibility for that job across restarts? That answer should drive storage and recovery choices. Once you choose, `/linked-intent-dev` can walk the change through design, EARS requirements, recovery tests, and implementation. The coach review itself leaves the files untouched.

Which direction matches your intent: preserve accepted jobs across restarts, retain memory-only queueing with an explicit exception, or narrow the product promise?