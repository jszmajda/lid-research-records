`docs/intent/job-queue/job-queue-design.md:14` says the queue resides only in process memory: after a power blip or OS-update restart, jobs accepted but not yet dispatched are lost and members must resubmit. That directly conflicts with the HLD’s first tenet at `docs/high-level-design.md:20`: “A submitted job is a promise: members should be able to upload and walk away.” The normal operating conditions described by the LLD make this more than a theoretical tension: unattended updates and power interruptions are explicitly expected, so an evening upload can disappear before the overnight print begins.

This is a *tenet cascade* concern: downstream mechanisms should implement the preference set at the HLD, or make a deliberate, visible exception. Leaving it implicit creates a confusing contract for both members and future implementers. They may build a durable-upload flow based on the HLD’s promise, while the queue implementation intentionally permits loss. It also makes the “resubmitting the same file is cheap” behavior look like a mitigation without establishing whether lost work is acceptable.

You have three valid directions:

1. **Change the design to preserve accepted jobs.** Persist accepted queue records before acknowledging the upload, then reload them on startup and reconcile their state with printer polling. This most directly honors the promise tenet. It would need corresponding queue specs for durable acceptance, restart recovery, and reconciliation, followed by tests before implementation.

2. **Keep the in-memory queue, but record it as an explicit exception.** Expand the `job-queue` Decisions & Alternatives row to name the HLD tenet being traded off, why durable records are not worth the operational or implementation cost, and the accepted user-facing consequence. The HLD and UI contract should then avoid promising unattended completion across a restart.

3. **Revise the HLD tenet.** If “upload and walk away” was meant only to mean no need to wait for dispatch during a healthy service lifetime, state that narrower promise. This makes the system’s reliability boundary explicit rather than leaving it for code to decide.

Which contract do you want the service to offer: durable accepted jobs across restarts, or best-effort jobs that members may need to resubmit after an interruption?