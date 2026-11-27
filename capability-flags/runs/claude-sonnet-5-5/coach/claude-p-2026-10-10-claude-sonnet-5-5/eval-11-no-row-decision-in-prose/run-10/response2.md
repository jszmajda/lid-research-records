**F1 — High. The job-queue keeps accepted jobs only in process memory, which works against the "a submitted job is a promise" tenet.**

`docs/intent/job-queue/job-queue-design.md` (Architecture) says the queue is "held entirely in process memory" and that "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them." That sits against two things in the HLD:

- **The tenet:** "A submitted job is a promise: members should be able to upload and walk away."
- **The goal:** "Evening upload, overnight print, morning pickup — with no member present."

The LLD's own Context says the mini-PC "takes unattended OS updates and the occasional power blip." Together these describe a normal evening: a member uploads at 8pm, the machine restarts at 2am, and the job disappears. Nobody is there to resubmit it, so the member finds nothing in the morning.

The two docs never share wording, so the conflict is easy to miss. The queue doc describes a mechanism, and the HLD describes a promise. Under *tenet cascade* (design nodes should lean the way the HLD's tenets and goals say to lean), this is a mechanism that defeats a tenet under a condition the docs themselves describe. Left alone, every future session reads "queue is in memory" as settled design and builds on it. The tenet keeps promising something the system can't deliver.

A related gap is that no Decisions & Alternatives row records this choice (F2). The existing rows (FIFO, slugs, 64 MB limit) each name a rejected alternative and an accepted cost, which is good practice. The most consequential choice in the doc is the one without a row, so a cold reader can't tell whether losing the queue was deliberate. Two parts of the design are consistent with the in-memory choice: QUEUE-004 rebuilds from running printers only, and the "modest hardware" tenet favors keeping things small. Neither is recorded as the reason.

**Your options (your call; I'm not picking one):**

1. **Change the design.** Persist accepted jobs, for example in the same SQLite file the registry already uses. The mini-PC is already running that, so it fits "the service stays small." On startup the queue would reload undispatched jobs, and QUEUE-004 would grow a counterpart spec. This is the choice that honors the tenet as written.
2. **Record the exception.** Keep the queue in memory and add a Decisions row. It would name the tenet traded against ("job is a promise"), the rejected alternative (persistence), and the accepted cost (jobs lost on restart, members resubmit). You'd likely also want to say how members find out, since "upload and walk away" no longer holds. This closes the decision-capture finding too.
3. **Revise the tenet.** If the real intent is "a job is a promise *unless the service restarts*," the tenet should say so. Then the HLD and the LLD agree, and the Decisions row still records the cost.

Whichever you choose, I'd make sure the Decisions row exists. A table row is enough here. This doesn't need a separate decision doc.

If you go with option 1, a new spec such as "when the service starts, the system SHALL restore accepted-but-undispatched jobs to their class queues" would be the natural companion. That change would go through `/linked-intent-dev`, since it's a design change that cascades LLD → specs → tests → code. Which option do you lean toward? I can help you word the Decisions row or the tenet revision.