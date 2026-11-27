The concern is **what “accepted” promises the member**. The HLD says members should be able to upload and walk away; the queue design requires them to resubmit after a restart. Those expectations diverge under conditions the project explicitly anticipates.

### F1: Restart behavior undermines the promise

In `docs/intent/job-queue/job-queue-design.md:10–14`, the mini-PC takes unattended OS updates and occasional power blips, while pending jobs live entirely in memory. A member could upload at 9 p.m., receive acceptance, and go home; an overnight restart would erase their place in the queue. Keeping the G-code file on disk preserves the payload, but not the accepted job or its scheduling information. Under *tenet cascade* — component designs should carry out the project’s stated priorities — that conflicts with “a submitted job is a promise” and the overnight-print goal. Consider explicitly choosing whether to change the queue design, authorize this exception, or narrow the HLD’s promise.

### F2: The tradeoff needs a record

The queue’s Decisions & Alternatives table explains scheduling, identifiers, and upload limits, but does not explain why accepted jobs are volatile. Under *docs carry current intent* — future readers should understand consequential choices without the original conversation — this choice needs enough rationale to prevent a later agent from guessing whether job loss is deliberate or accidental. A **single Decisions row** should suffice: name the chosen approach, the alternative considered, and the accepted cost. If you retain the volatile queue, a row explicitly naming the reliability tenet being traded against and why would also close this decision-capture finding.

### The choices to consider

There are three legitimate ways to resolve the tension; the reliability-versus-simplicity preference is yours:

| Choice | What it would mean |
|---|---|
| **Change the design** | Preserve accepted, pending jobs across restarts so members can rely on the current promise. |
| **Record an exception** | Keep the memory-only queue and explicitly accept restart-related job loss, explaining why simplicity outweighs reliability here. |
| **Revise the promise** | Make the HLD and member-facing acceptance semantics clearly best-effort, with resubmission sometimes required. |

**My recommendation is to settle that promise first**, then make the design and specs agree with it. If you choose durable acceptance, SQLite is a plausible small-system option worth considering alongside the registry’s existing SQLite design. The queue would need durable job records referencing the stored G-code, with acceptance acknowledged only after the necessary state is saved.

That path also needs two distinctions pinned down before implementation:
- **Pending-job recovery:** restore scheduling information after restart, including staff reordering.
- **Uncertain dispatch:** a timeout may mean the printer accepted the job but its response was lost; recovery should reconcile that uncertainty before retrying.

`QUEUE-004` currently requires polling running printers at startup; it does not specify preserving pending jobs. Once you choose the intended guarantee, use `/linked-intent-dev` to revise the design, add the missing requirements, and carry them through tests and code.

**Which expectation do you want members to have: accepted jobs survive restarts, or acceptance is best-effort with possible resubmission?**