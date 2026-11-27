**The conflict:** `docs/intent/job-queue/job-queue-design.md` says accepted jobs waiting in memory disappear on restart and members must resubmit them. That can happen during the unattended updates or power blips the same document anticipates. Keeping the G-code file on disk makes resubmission cheaper, but does not preserve the accepted job or its queue position. Under *tenet cascade*—downstream design should support the project’s stated goals—this conflicts with the promise that members can upload and walk away.

**The missing decision record:** The queue design’s Decisions & Alternatives table does not explain why volatile storage was chosen or acknowledge the cost of losing accepted work. Under *docs carry current intent*—a future reader should understand consequential choices without the original conversation—a short decision row would help preserve that reasoning.

**The spec gap:** `job-queue-specs.md` requires startup polling of printers but does not say what happens to accepted, undispatched jobs. Under *effective intent-tree alignment*—important design behavior should have testable specs—that leaves the restart outcome easy to miss when implementing or reviewing the queue.

There are three ways to reconcile the conflict:

1. **Change the design:** persist accepted jobs and their queue order, define when acceptance is durable and how restart recovery works, then capture those behaviors in EARS.
2. **Keep the in-memory design and record an exception:** add a Decisions row naming the upload-and-walk-away tenet, the reason for the trade-off, and the accepted loss of queued jobs. This also addresses the missing decision record.
3. **Revise the tenet or goal:** if accepted jobs are not meant to survive restarts, make that expectation explicit in the HLD and align the design and specs with it.

Whichever direction you choose, the next step is to walk the change through `/linked-intent-dev`, updating the affected intent before tests and implementation. Which outcome do you want members to be able to rely on after a restart?