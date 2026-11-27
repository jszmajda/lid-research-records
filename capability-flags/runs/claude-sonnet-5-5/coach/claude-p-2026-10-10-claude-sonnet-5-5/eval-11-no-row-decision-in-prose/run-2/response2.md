**F1 (high): accepted jobs live only in memory, which works against the HLD's lead tenet.**

`job-queue-design.md` (Architecture) says the queue is "held entirely in process memory" and that jobs "accepted but not yet dispatched before a restart are gone, and members resubmit them." The HLD's first tenet is "A submitted job is a promise: members should be able to upload and walk away," and its first goal is "Evening upload, overnight print, morning pickup — with no member present." The design's own Context section says the mini-PC "takes unattended OS updates and the occasional power blip." So the condition that defeats the promise is one the doc already describes: a restart overnight, between the evening upload and the printer freeing up. The member who walked away finds nothing printed in the morning and no explanation. The two docs never share wording, so the conflict is easy to miss when reading either one alone. QUEUE-004 specifies that startup rebuilds farm state by polling printers, but nothing says what happens to accepted jobs, so the loss is implicit rather than a stated, chosen behavior.

This follows *tenet cascade*: each design node should lean the way the HLD's tenets and goals say to lean, and any exception should be recorded.

If left alone, the loss stays invisible until the first overnight update. By then the queue, the member-facing promise and the "no silent reordering" explanation all disagree about what the system does.

**F2 (medium): the in-memory choice has no Decisions row.**

The table records scheduling order, job IDs and upload limit, but not why the queue isn't persisted. A cold reader can't tell whether this was a deliberate trade against the "service stays small" tenet or an accident of the first implementation. They also can't tell what cost was accepted. This follows *decision capture*: a choice that stays live once landed should keep its reasoning on the page. Recording the exception closes F2 and gives F1 an honest paper trail.

**F3 (medium): the tenets are unordered, and two of them conflict here.**

Both tenets are legitimate tie-breakers. "A promise" and "the service stays small" are the pair that in-memory-versus-durable tests. This follows *tenets capture forward-looking preference*, which says to order tenets when they can conflict. Without an order, the next session meets this choice cold and picks whichever it finds first.

**What I'd recommend**

Which option to take is your call. These are the choices, and I'd lean toward the first:

1. **Change the design.** Persist accepted jobs so a restart doesn't lose them. The registry already uses a single SQLite file, so a jobs table beside it fits the "stays small" tenet at little cost, and it makes the tenet and the goal true as written.
   - Adjust the Architecture paragraph in `job-queue-design.md`.
   - Add an EARS spec, e.g. `QUEUE-006`, for restoring accepted jobs on startup, alongside QUEUE-004.
   - Make sure the cascade also reaches the tests.
   - Add a Decisions row for the chosen store.
2. **Record the exception.** Keep the in-memory queue and add a Decisions row. It should name the tenet traded against ("a submitted job is a promise" gives way to "the service stays small"), the accepted cost (jobs lost on restart, members resubmit), and why that is acceptable. Then consider a spec requiring the UI to tell members a job may need resubmission, so the loss is at least not silent. Under this option the HLD goal and tenet should also be reworded, otherwise they still over-promise.
3. **Revise the tenet.** If the promise really is best-effort, say so in the HLD. This is the weakest fit with the "walk away overnight" goal, so I'd only take it if the other two are off the table.

Whichever you pick, put the tenets in priority order (F3). Recording the exception also closes F2, so the Decisions row does double duty. If you tell me which direction you prefer, I can help draft the row or the spec wording with you. I won't edit files from the coach.