Two of the findings are about the in-memory queue: F1 (the mechanism works against a tenet) and F2 (the choice isn't recorded). They share a remedy, so I'll take them together.

**F1 — High. The in-memory queue can break the promise the HLD makes to members.** `job-queue-design.md` line 14 says the queue is "held entirely in process memory", and that after a restart, accepted-but-undispatched jobs "are gone, and members resubmit them". Line 10 of the same doc says the mini-PC "takes unattended OS updates and the occasional power blip". Together these describe an ordinary night: a member uploads at 9pm, the job waits behind a running print, the mini-PC reboots for an update at 2am, and the job is gone. `QUEUE-004` rebuilds only what printers are currently running, so nothing brings the waiting job back.

The HLD's first tenet is "a submitted job is a promise: members should be able to upload and walk away", and its first goal is "evening upload, overnight print, morning pickup — with no member present". The design's fallback, that members resubmit, needs the member present, which the goal rules out. Nothing in the design tells the member the job was lost either, which also rubs against "the queue explains itself".

The principle here is *tenet cascade*: leaf designs should lean the way the HLD's tenets and goals say to lean, or record the exception. It matters because the next session implementing `QUEUE-004` reads the leaf, not the HLD. It will build the lossy restart faithfully, and the conflict will surface as a member complaint rather than a design question.

**F2 — High. The choice itself has no Decisions row.** The Decisions & Alternatives table covers scheduling order, job identifiers and upload size, but not where the queue lives. That is the row a cold reader would most want, because the registry next door already persists to SQLite on the same machine and the G-code files are already on disk. A reader can't tell whether in-memory was a deliberate trade (perhaps leaning on the third tenet, "the service stays small") or simply the first thing written down.

The principle is *docs carry current intent, written to be read cold*: a choice a reader would still question needs its rejected alternative and accepted cost on the page. Without that, a future session will either "fix" it by adding persistence nobody asked for, or preserve a loss nobody intended.

**What to do.** There are three legitimate ways out. Which one is right depends on what you want printfarm to promise, so the choice is yours:

1. **Change the design.** Persist accepted jobs so they survive a restart. The lowest-cost shape is probably the SQLite file the registry already uses. The cost is a little more surface on the mini-PC and a restart path that reloads the queue as well as polling printers.
2. **Record the exception.** Keep the in-memory queue and add a Decisions row. It should name the rejected alternative (a persisted queue), the tenet and goal traded against, and the accepted cost: jobs waiting at restart are lost. You would probably also want a mitigation, such as telling affected members.
3. **Revise the tenet.** If "a submitted job is a promise" is stronger than you mean, soften it and the goal in the HLD, for example to best-effort overnight printing. The leaf design then no longer contradicts them.

Options 1 and 2 both close F2, because either way the choice gets a row. Option 3 alone does not; the row is still worth adding.

Two smaller findings move with this decision:

- **F9 (tenet order):** this is the case where "a job is a promise" and "the service stays small" collide. Ranking them in the HLD would settle this decision and the next one like it.
- **F5 and F8 (specs and slugs):** whichever way you go, restart behaviour for waiting jobs deserves its own spec beside `QUEUE-004`. The "slugs recycle after 90 days" row also needs to say where slug history is kept, since an in-memory queue forgets it on restart.

The coach doesn't edit files. To apply any of these, run `/linked-intent-dev` with the option you've chosen and it will walk the change from the HLD or LLD down through the specs.

Which of the three matches what you want the service to promise?