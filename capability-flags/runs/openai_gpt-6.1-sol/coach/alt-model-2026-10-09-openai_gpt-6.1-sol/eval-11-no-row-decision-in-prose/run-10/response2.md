The concern is that **“accepted” means different things in the HLD and the queue design**. Saving the uploaded file protects its contents, but it does not preserve the commitment to print it.

### F1 — The restart policy conflicts with the submission promise

In `docs/high-level-design.md:20`, “a submitted job is a promise”: members should upload and walk away. The overnight-print goal reinforces that expectation. But `docs/intent/job-queue/job-queue-design.md:10–14` explicitly anticipates unattended updates and power blips, then says accepted jobs awaiting dispatch disappear after a restart. A member could upload successfully, go home, and find no print in the morning. Polling printers recovers jobs already running; it cannot recover jobs that never reached a printer. This is a *tenet cascade* concern — the component’s mechanism should uphold the project’s stated priorities under the operating conditions its own docs describe. Consider resolving that mismatch explicitly through one of the choices below.

### F2 — The trade-off needs a decision record

The in-memory queue is stated in the architecture, but its Decisions & Alternatives table does not explain why losing accepted jobs is preferable to persistence. Under *docs carry current intent* — future readers should understand consequential choices without access to the original conversation — that leaves an important question unanswered. A later implementer might preserve the loss policy assuming it is deliberate, or add persistence without understanding the simplicity constraint. Consider a single fuller Decisions row recording the chosen approach, the alternative, and the accepted cost; a separate decision document seems unnecessary here.

### What I’d recommend doing next

First settle what acceptance promises. There are three legitimate ways to reconcile the docs, and the choice is yours:

- **Change the queue design to uphold the promise.** Persist accepted jobs and their scheduling metadata before reporting acceptance. The design would also need to explain restart recovery and what happens if a printer accepted a dispatch just before the service crashed; durable queue storage alone does not settle that uncertainty.
- **Keep the volatile queue and record an explicit exception.** Explain why simplicity outweighs the submission promise and overnight goal, and what members should expect after a restart. This decision row would also close F2, although the reliability trade-off remains.
- **Revise the HLD promise.** Define submission as best-effort rather than a durable commitment, then align the queue design and member-facing expectations with that intent.

Once you choose, use `/linked-intent-dev` to walk the change through HLD review, the queue LLD, EARS requirements, tests, and implementation. If recovery requires changing the registry’s contract, that crosses into the registry segment and deserves its own confirmation.

**Which direction matches your intent: preserving accepted jobs across restarts, keeping job loss as a documented exception, or making submission explicitly best-effort?**