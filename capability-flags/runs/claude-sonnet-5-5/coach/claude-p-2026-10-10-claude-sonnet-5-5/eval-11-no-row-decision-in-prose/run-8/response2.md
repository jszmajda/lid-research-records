**F1 (high): the queue can lose accepted jobs on restart, which works against the project's top tenet.**

`docs/intent/job-queue/job-queue-design.md` (Architecture) says the queue is "held entirely in process memory." It adds that jobs accepted but not yet dispatched before a restart "are gone, and members resubmit them." QUEUE-004 only rebuilds what printers are *currently running*, so it does nothing for jobs that were still waiting.

The same LLD's Context section says the mini-PC "takes unattended OS updates and the occasional power blip." The HLD's tenet is "a submitted job is a promise: members should be able to upload and walk away." Its first goal is "evening upload, overnight print, morning pickup — with no member present."

Put together, these produce a concrete failure. A member uploads at 9pm, the machine patches and reboots at 3am, and the job is gone. The member finds nothing in the morning and has no way to know why. None of the docs share wording across that gap, which is why it's easy to miss. The queue LLD never contradicts the tenet in so many words.

This is *tenet cascade*, the principle that each design node should lean the way the HLD's tenets say to lean. It matters because the one scenario the HLD is built around is the one this mechanism breaks, and the printer-registry already persists its state in SQLite, so durability is within reach.

**F2 (high): the choice has no Decisions row.**

The in-memory queue is one of the most consequential choices in the LLD, yet the table records only scheduling order, job IDs, and upload size. A cold reader would question it immediately and would be tempted to reverse it. Nothing says what was weighed or whether the lost-job cost was deliberately accepted. Right now a future session can't tell a considered trade-off from an oversight. This is *docs carry current intent*: a live decision should carry its reasoning on the page.

**Remedies, which are your choice. I'm not picking one for you.**

1. **Change the design.** Persist accepted jobs, for example in the same SQLite file the registry uses. Then rewrite the Architecture paragraph and QUEUE-004 so that startup restores queued jobs and also polls printers. Add a spec such as "When the service restarts, the system SHALL retain accepted-but-undispatched jobs." Add a Decisions row too, naming the rejected alternative (in-memory only) and the cost accepted (a bit more code and disk writes on a "modest" machine, which touches the third tenet, "the service stays small").
2. **Keep it in memory and record the exception.** Add a Decisions row that names the tenet being traded against ("a submitted job is a promise"), says why (for example, "restarts are rare and resubmission is cheap thanks to content-hashed uploads"), and states the accepted cost. If you go this way, consider whether the queue should at least tell members about lost jobs, so the promise fails loudly instead of silently.
3. **Revise the tenet.** If the real intent is "best-effort until restart," soften the HLD tenet and the overnight goal so they match what the design delivers.

Either of options 1 and 2 closes F2 as well, because the Decisions row is the record F2 asks for. A full decision doc isn't warranted here. A well-written row is the right size for this choice.

A few related notes if you pick option 1. The "suspect printer" gap in F3 is a good thing to settle in the same pass. The content-hashed uploads on disk already give you half of the persistence story, so only the queue ordering and job metadata would need to be stored.

I haven't edited any files. Tell me which direction you lean and I can help you draft the wording.