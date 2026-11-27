Looking at the job-queue architecture, there's a design decision worth examining against your declared intent.

**The current design:** Jobs accepted from members are held entirely in process memory. If the service restarts before a job is dispatched to a printer, that job is lost and the member must resubmit it. The system rebuilds state by polling each printer for what's currently running, so it knows what *is* printing, but not what *was queued*.

**The tension:** This design conflicts with your first tenet — *"A submitted job is a promise: members should be able to upload and walk away."* A promise that vaporizes if the service crashes before dispatch isn't quite a promise. More concretely, your goal is *"Evening upload, overnight print, morning pickup — with no member present."* If a member uploads at 8 PM and the service crashes at 11 PM (unattended OS updates, power blip), the job is gone by morning. The member's promise is broken.

**Why the current choice exists:** The mini-PC is modest hardware (your third tenet), and persisting a queue adds complexity — either a second database file or changes to the SQLite schema. The team clearly prioritized simplicity and accepted the risk.

**What to consider going forward:**

1. **Clarify the trade-off explicitly.** Is it acceptable for queued jobs to be lost if the service crashes before dispatch? If yes, document that exception in a Decisions row or note — *"accepted cost: jobs in memory are lost on restart until dispatched."* That makes the boundary clear to future sessions. If no, the design needs to change.

2. **Capture it in specs.** If you accept the trade-off, spec it: *"When the service starts, unacknowledged queued jobs from before the restart are not recovered."* That way tests can verify this behavior intentionally rather than discovering it by accident.

3. **Consider a lighter persistence option** if you want to keep the promise. Persisting just the queue index (member ID, file hash, target printer class) to the SQLite file costs very little and lets you recover queued-but-not-dispatched jobs on restart. The G-code itself is already keyed by hash, so you're not duplicating files.

The design isn't wrong — it's a deliberate trade-off. But it's worth making the trade-off explicit (especially in specs, so tests capture it) so future sessions know it was chosen, not overlooked.