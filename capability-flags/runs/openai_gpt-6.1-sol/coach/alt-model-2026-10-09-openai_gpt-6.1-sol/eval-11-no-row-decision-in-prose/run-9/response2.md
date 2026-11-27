The key issue is **what “accepted” promises a member**. Keeping the queue in memory is simple, but the current design makes acceptance temporary while the HLD presents it as dependable.

### F1 — Restart behavior conflicts with the upload promise

`docs/intent/job-queue/job-queue-design.md:10–14` explicitly anticipates unattended OS updates and power interruptions, yet says accepted jobs that have not dispatched disappear after a restart. A member could upload in the evening, receive acceptance, and find nothing printed or queued the next morning. Keeping the G-code file on disk makes resubmission cheaper; it does not preserve the member’s place in the queue or their request to print. This is a **tenet cascade** concern—component mechanisms should carry out the project’s declared priorities—because the HLD says “a submitted job is a promise” and members should be able to “upload and walk away.” Consider resolving that mismatch explicitly before implementation.

### F2 — The trade-off needs a decision record

The queue’s Decisions & Alternatives table explains scheduling, identifiers, and upload limits, but not the choice to lose pending jobs on restart. Under **docs carry current intent**—docs should explain consequential choices to someone reading them cold—a future developer needs to understand why that reliability cost was accepted. Otherwise, one session may preserve the memory-only design for simplicity while another adds persistence to honor the HLD. A fuller Decisions & Alternatives row is enough here: name the alternative, the reason for the choice, and the accepted cost. A separate decision document seems unnecessary.

### What I’d recommend doing next

First, choose which promise you want the service to make. There are three legitimate ways to reconcile the documents:

- **Change the design to uphold the promise.** Preserve accepted, pending jobs across restarts. A small SQLite-backed queue is a plausible fit for the mini-PC. The design would need to define when acceptance becomes durable, how ordering survives restart, and how startup distinguishes pending jobs from jobs already sent to printers. Persisting the queue alone does not settle duplicate dispatch after a crash.
- **Keep the memory-only design and record an explicit exception.** Add a Decisions row naming the “upload and walk away” tenet being traded against, why simplicity wins here, and the accepted consequence: members may need to resubmit after a restart. Recording that exception also addresses F2.
- **Revise the HLD promise.** If best-effort unattended printing is the intended service, narrow the tenet and goal accordingly, then align the queue design and member-facing acceptance behavior with that weaker guarantee.

My recommendation is to **settle that acceptance guarantee first**, then use `/linked-intent-dev` to carry the chosen intent through design, EARS requirements, tests, and implementation. That keeps a storage choice from silently deciding the product’s reliability promise.

**Should an accepted job remain queued across an ordinary service restart, or is losing it and requiring resubmission an acceptable trade-off?**