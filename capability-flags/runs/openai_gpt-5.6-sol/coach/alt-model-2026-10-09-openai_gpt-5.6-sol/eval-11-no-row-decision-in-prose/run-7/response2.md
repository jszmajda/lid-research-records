### Tenet Conflict

**The in-memory queue works against the project’s central promise.** `docs/high-level-design.md:20` says that a submitted job is a promise and members can “upload and walk away.” The goal at line 26 is specifically evening upload followed by unattended overnight printing. But `docs/intent/job-queue/job-queue-design.md:10-14` says the mini-PC experiences unattended updates and power blips, while accepted but undispatched jobs disappear after either event. Polling printers on startup recovers jobs already running, not jobs waiting in memory.

Under *tenet cascade* — leaf designs should follow project-level preferences unless an exception is deliberate — these statements cannot all remain current intent. Retaining the G-code file by content hash does not close the gap: after a restart, the service no longer knows the member, target class, priority, queue position, or even that the retained file represents an accepted job. Requiring resubmission also breaks the unattended workflow because the member may be asleep when the restart happens.

### Decision Capture

**The durability tradeoff is not recorded as a decision.** The in-memory architecture is stated as fact, but the Decisions & Alternatives table does not explain why it was selected over persistent queue metadata or acknowledge that accepted work can be lost. Under *docs carry current intent, written to be read cold* — consequential choices retain enough rationale for a future reader — this leaves the most questionable choice in the component unexplained.

A future implementation session is likely either to follow the LLD and contradict the HLD, or “fix” the LLD by introducing persistence without confirming that operational complexity is acceptable. Capturing the decision prevents both forms of drift.

### Tenet Precedence

**The design exposes a conflict between two unordered tenets.** “A submitted job is a promise” leans toward durable acceptance, while “the service stays small” can lean toward an in-memory queue. Under *tenets capture forward-looking preference* — tenets are tie-breakers between defensible choices — the HLD should make clear which consideration wins here. Otherwise each future session can resolve the same tradeoff differently.

### Recommended Path

LID leaves the product choice with you. There are three coherent resolutions:

1. **Keep the unattended-job promise and change the queue design.** Persist enough job metadata to reconstruct accepted work after restart: job identity, owner, target class, priority, ordering, file hash, and lifecycle state. Startup would reload queued jobs and reconcile dispatched or running jobs against printer state. The existing content-addressed G-code storage can remain.

2. **Keep the in-memory design and record an explicit exception.** Add a Decisions & Alternatives row naming the unattended-job tenet and overnight goal being traded away, why the simpler design is worth that cost, and what members are actually promised. The HLD and user-facing acceptance language would then need to describe jobs as best-effort until dispatch rather than durable upon submission.

3. **Revise the tenet itself.** If “upload and walk away” was aspirational rather than a reliability commitment, narrow it to the intended guarantee. The LLD can then remain volatile without contradicting upstream intent.

If the existing HLD remains unchanged, durable queue metadata follows most directly from the declared intent. I would handle that through `/linked-intent-dev` before implementation:

1. Confirm the durability boundary: at what point is a submission officially accepted?
2. Update the HLD only if the promise or tenet precedence changes.
3. Update `job-queue-design.md` with the chosen storage and restart-reconciliation model.
4. Add a Decisions & Alternatives row covering volatile versus durable queue state, the rejected option, and the accepted cost.
5. Add EARS requirements for durable acceptance, restart recovery, ordering preservation, persistence failure, and reconciliation with already-running printers.
6. Write tests citing those new spec IDs before implementing the queue.

The key decision is: **does “accepted” mean durable across service restarts, or only acknowledged in the current process?** Once you answer that, the rest of the arrow can be made coherent.