The key distinction is **saving the uploaded file versus saving the accepted job**. Your design keeps G-code on disk, but loses the record that says who submitted it, which printer class it targets, and where it belongs in the queue.

### F1 — The restart behavior conflicts with the service’s promise

`docs/intent/job-queue/job-queue-design.md:10–14` explicitly anticipates unattended OS updates and power interruptions. After either, the service polls printers to discover running jobs, but undispatched accepted jobs disappear. A member can upload successfully, go to sleep, and find that their print never started because the queue vanished overnight. Under *tenet cascade* — component designs should carry out the project’s declared promises — that works against the HLD’s “upload and walk away” tenet and overnight-print goal. Polling printers cannot recover work that never reached them. I recommend resolving this conflict explicitly in the design before implementing restart handling.

### F2 — The durability trade-off needs a recorded reason

The memory-only choice is stated in the Architecture section, but absent from the Decisions & Alternatives table. The HLD’s preference for a small service provides some context, but does not explain why preserving accepted jobs costs too much or why requiring resubmission is acceptable. Under *docs carry current intent* — a future reader should understand consequential choices without the original conversation — this leaves the next implementer guessing whether job loss is intentional or an oversight. A fuller decision-table row is sufficient here: name the alternative, why it was rejected, and the cost accepted. A separate decision document is unnecessary.

### What I recommend doing next

Choose which promise you want the system to make. There are three coherent ways forward:

- **Change the queue design to preserve accepted jobs.** A small SQLite-backed queue is one option consistent with the mini-PC constraint. Acceptance would acknowledge success only after the job record is durable; startup would restore pending work and reconcile dispatched work with printer state. The accepted cost is additional persistence and recovery logic, including handling a restart between sending a job and recording the printer’s acknowledgement.
- **Keep the memory-only queue and record an explicit exception.** Add a Decisions row naming the upload-and-walk-away tenet being traded against, explaining why, and acknowledging that restarts lose pending jobs. This also closes F2’s missing-rationale finding. The exception should be reflected in member-facing expectations.
- **Revise the HLD’s promise.** If best-effort queuing with member resubmission is the intended service, narrow the tenet and overnight-print goal accordingly, then align the queue design and specs with that commitment.

My recommendation is to settle that product decision first, then carry it through `/linked-intent-dev`: update the affected design, specify acceptance and restart behavior, and verify those behaviors with tests before implementation.

**Should an acknowledged upload remain queued across a service restart, or is losing pending jobs an acceptable limitation you want the service to communicate?**