The key question is **what “accepted” promises a member**. Your HLD suggests they can upload and leave; the queue design currently requires them to resubmit after a restart. That deserves an explicit choice before implementation.

### F1 — Restart behavior conflicts with the unattended-upload promise

In `docs/intent/job-queue/job-queue-design.md:10–14`, unattended OS updates and power interruptions are normal operating conditions, yet accepted, undispatched jobs exist only in memory. For example, a member uploads in the evening, the service accepts the job, and an overnight restart removes it before a printer becomes free. Keeping the G-code file on disk makes resubmission cheaper, but it does not preserve the queued request. Under *tenet cascade* — downstream designs should uphold upstream promises — that mechanism works against “upload and walk away” and morning pickup. Consider explicitly choosing one of these remedies: preserve accepted jobs across restarts; keep the volatile queue and record a justified exception to that promise; or revise the HLD so acceptance clearly offers a weaker guarantee.

### F2 — The trade-off needs a decision record

The queue’s Decisions & Alternatives table explains scheduling well: it names the rejected alternative and the accepted cost. The in-memory queue has no equivalent explanation. Under *docs carry current intent* — a cold reader should understand consequential choices without the original conversation — future contributors need to know whether losing accepted jobs is deliberate or an unresolved design gap. Once you choose the guarantee, add a row in `job-queue-design.md` naming the storage choice, the alternative considered, and the operational cost accepted. If you retain the volatile queue, a row explicitly naming the HLD promise traded against and why would also address F1’s undocumented exception. A separate decision document looks unnecessary here.

### F3 — Startup polling does not specify recovery of queued work

`QUEUE-004` requires polling printers for their current jobs at startup. That discovers work already running on printers; it cannot reconstruct requests that never reached them. Under *effective intent-tree alignment* — design commitments need named behavioral requirements — the chosen acceptance and restart guarantees should appear in `job-queue-specs.md`. If you choose durability, specify that acceptance follows durable storage, pending jobs recover with their class and ordering intact, and ambiguous dispatch outcomes are reconciled before retrying. The last point matters because a printer may have accepted a job just before the service crashed, even if the service never recorded success.

### What I recommend doing next

**Settle the acceptance guarantee first**, then carry that decision through `/linked-intent-dev`: HLD review, queue LLD, EARS requirements, recovery tests, and implementation.

If you choose durable acceptance, a small SQLite-backed job ledger is a concrete option to evaluate against your modest-hardware constraint. It would retain job metadata and references to the existing on-disk G-code files. The registry already uses SQLite, which makes this worth considering, but does not by itself decide whether the queue should share its database. Recovery tests should exercise both an accepted job surviving a restart and a crash during dispatch without blindly sending the same job twice.

**Which promise do you want: accepted jobs survive restarts, a documented exception allowing their loss, or a weaker acceptance promise in the HLD?**