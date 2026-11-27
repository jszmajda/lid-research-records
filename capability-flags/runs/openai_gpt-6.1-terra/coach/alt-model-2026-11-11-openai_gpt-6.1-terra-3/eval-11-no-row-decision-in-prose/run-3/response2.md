**The conflict:** The HLD promises that members can upload a job and walk away, including for overnight printing. But `docs/intent/job-queue/job-queue-design.md:14` says accepted, undispatched jobs are lost on restart and members must resubmit them. That matters because the same design anticipates unattended OS updates and power blips. Polling printers on startup recovers information about jobs already running; keeping G-code files on disk makes resubmission cheaper, but neither restores the waiting queue. Under *tenet cascade*—component designs should carry through the project’s stated priorities—this tradeoff needs an explicit choice.

**The missing decision record:** The queue design does not explain why in-memory storage was chosen over a durable queue or acknowledge the cost to the upload-and-walk-away promise. Under *decision capture*—preserving the reasoning behind choices a future reader might reasonably question—a short Decisions & Alternatives row would make that tradeoff visible. A separate decision document does not appear necessary.

I recommend deciding among three paths:

- **Change the design:** persist accepted jobs and restore the queue after restart. This supports the existing promise but adds persistence and recovery work.
- **Keep the in-memory queue as an exception:** record why losing waiting jobs is acceptable, explicitly naming the promise traded away. This also resolves the missing decision record.
- **Revise the HLD promise:** if unattended durability is not actually a goal, make that expectation clear and align the queue design with it.

Whichever direction you choose, the design and EARS specs should state the intended restart behavior, followed by tests and implementation through `/linked-intent-dev`. Which path best matches what you want members to be able to rely on?