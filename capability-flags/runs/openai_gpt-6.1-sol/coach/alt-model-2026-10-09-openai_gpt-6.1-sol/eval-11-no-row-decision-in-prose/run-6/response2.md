There are two separate questions here: **does losing accepted jobs match the promise you want to make, and is the reasoning behind that choice recorded?**

### F1 — Restart behavior conflicts with the member promise

`docs/intent/job-queue/job-queue-design.md:10–14` explicitly anticipates unattended OS updates and power blips, but keeps accepted jobs entirely in memory. Imagine a member uploads at 9 p.m., the printer is busy, and the mini-PC restarts at midnight: the queued job disappears. Polling printers recovers running jobs, but cannot recover work never sent to a printer. Keeping the G-code file makes resubmission cheaper; it does not preserve the member’s place in the queue or their submission. Under *tenet cascade* — downstream designs should carry out upstream priorities — that mechanism conflicts with “a submitted job is a promise” and upload-and-walk-away use. The recommended next step is to decide whether restart survival is part of acceptance, then align the design or explicitly qualify that promise.

### F2 — The tradeoff needs a decision record

The queue’s Decisions & Alternatives table explains scheduling order and identifier choices, but does not explain why accepted work is volatile. Under *docs carry current intent* — preserve reasoning a future reader needs to understand a questionable choice — this merits a row because a cold reader would reasonably ask why a service with unattended restarts discards pending work, especially when the registry already uses SQLite. Without the rationale, future sessions may either preserve the choice accidentally or reverse it without understanding your constraints. Once you settle the policy, add a small decision row naming the alternative, the reason for the choice, and the accepted cost; a standalone decision document seems unnecessary here.

### Your choices

The remedy depends on which promise you want:

- **Change the design to preserve accepted jobs.** If upload-and-walk-away includes routine restarts, a small SQLite-backed queue is a plausible fit. Acceptance would follow durable recording of the job and its file reference; startup would recover pending work and reconcile running jobs with printers. The cost is additional state-management and recovery logic.
- **Keep the volatile queue and record an exception.** If losing pending jobs is an acceptable simplicity tradeoff, record why, explicitly naming the unattended-submission tenet being traded against. That also closes F2’s missing-rationale finding. Members would need a clear account of this limitation.
- **Revise the promise.** If this is intentionally a best-effort service, narrow the HLD’s tenet and goal so future implementation work does not assume durable acceptance.

**I recommend settling the meaning of “accepted” before choosing storage.** If you choose durable acceptance, the next `/linked-intent-dev` change should cover restart recovery and interrupted dispatch together: a timeout can mean a printer started the job even though the service never received confirmation, so persistence alone does not settle whether retrying is appropriate.

Which policy fits your intent: should an accepted job survive routine service restarts, or is best-effort submission with possible resubmission acceptable?