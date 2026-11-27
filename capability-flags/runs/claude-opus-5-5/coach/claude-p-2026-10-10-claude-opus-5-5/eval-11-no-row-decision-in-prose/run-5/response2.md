**F1 — High. The queue's storage works against the project's first tenet and first goal.**
`job-queue-design.md` (Architecture) says the queue is "held entirely in process memory" and that jobs "accepted but not yet dispatched before a restart are gone, and members resubmit them." The same doc's Context says the mini-PC "takes unattended OS updates and the occasional power blip." The HLD's first tenet is "a submitted job is a promise: members should be able to upload and walk away," and its first goal is "evening upload, overnight print, morning pickup — with no member present."

Put together: a member uploads at 9pm, the mini-PC reboots for an update at 2am, and their job is silently gone. The remedy the design offers, resubmitting, needs the one thing the goal rules out, a member being present. Nothing in the design notifies them either, so they find out at pickup.

This falls under *tenet cascade*: leaf designs should lean the way the HLD's tenets say to lean, or record the exception. If it sits, the next session to touch the queue has to guess which of the two documents is the real intent. The content-hash file store softens the cost of resubmitting, but not the broken promise.

There are three ways to close it, and the choice is yours because each one is a statement about what the project wants:

- **Change the design.** Persist accepted jobs so they survive a restart. The registry already keeps a SQLite file on this machine, and the G-code is already on disk, so the missing piece is the queue's order and ownership. The cost is some weight against the third tenet, "the service stays small."
- **Record the exception.** Keep the in-memory queue and add a Decisions row saying it trades against "a submitted job is a promise," and why. A cold reader then knows the loss is deliberate.
- **Revise the tenet.** If the real promise is weaker, for example "best effort, and you are told when a job is lost," say that in the HLD and let the design follow.

**F2 — High. The in-memory choice has no row in Decisions & Alternatives.**
The table in `job-queue-design.md` has rows for scheduling order, job identifiers and upload size, and the first two name what was rejected and what cost was accepted. The storage choice appears only in the Architecture prose, with no alternative and no rationale. It is the choice a cold reader is most likely to question, since a persistent store already exists in the sibling node.

This is *decision capture*: a choice a reader would still question once it has landed needs its alternative and its accepted cost on the page. Without that, a future session will either "fix" it without knowing what it was protecting, or leave it alone without knowing whether it was an oversight.

I recommend a row in the existing table, not a separate decision doc. Nothing else in the design tree leans on this reasoning, so a row is the right size. It should name the alternative considered (most likely the SQLite file), why it was not chosen, and the accepted cost: queued jobs are lost on restart.

**How the two fit together**

- If you record the exception for F1, that same row closes F2.
- If you change the design, F2 still wants a short row for the new choice. It is much easier to write, because it then agrees with the tenet.
- If you revise the tenet, the row is still needed, and the Goals line about "no member present" should be reread against the new wording.

Whichever you choose, one item from F4 follows directly. No spec says what happens to accepted jobs across a restart; QUEUE-004 covers only rebuilding the picture of running jobs. The landed behavior, whether loss, loss with notice, or survival, should get a `QUEUE` spec so there is something to test against. Running `/linked-intent-dev` with the chosen change will walk it from the LLD through specs and tests.

Which of the three directions for F1 fits what you want the queue to promise?