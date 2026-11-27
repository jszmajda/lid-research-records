**F1 — High. The queue's storage design pulls against your first tenet and your first goal.** `docs/intent/job-queue/job-queue-design.md` (Architecture, line 14) says the queue is "held entirely in process memory" and that jobs "accepted but not yet dispatched before a restart are gone, and members resubmit them." The same doc's Context (line 10) says the mini-PC "takes unattended OS updates and the occasional power blip." Put together, the docs themselves describe this night: a member uploads at 9pm, the machine reboots for an update at 2am, and the job has vanished with nobody there to resubmit it. That runs against the HLD tenet "a submitted job is a promise: members should be able to upload and walk away" and the goal "evening upload, overnight print, morning pickup — with no member present." This is what the *tenet cascade* lens checks: whether leaf designs lean the way the HLD's tenets and goals say to lean. It matters because a tenet is the tie-breaker a future session reaches for when no spec covers a choice. If the design quietly contradicts it, the next agent either "fixes" the queue against your wishes or concludes the tenet is decorative and stops honouring it elsewhere. The remedy is your choice (options below).

**F2 — High. The in-memory choice is the one decision in this doc a reader would want to reverse, and it has no row.** The Decisions & Alternatives table in the same file covers scheduling order, job identifiers and upload size, each with a rejected alternative and an accepted cost. Queue storage is not there. A cold reader sees `printer-registry` persisting to "a single SQLite file" on the same machine, so the obvious question is why the queue doesn't use it too. The third tenet ("the mini-PC is modest hardware; the service stays small") may be the reason, but nothing on the page says so. This is *decision capture*: a choice that stays questionable after it lands needs what was given up and what cost was accepted written where the next reader will find it. Without that, the reasoning lives only in your head, and every session that touches the queue will re-argue it or silently change it. The smallest fix is one fuller Decisions row. This does not need a separate decision doc.

**What to do about it**

There are three ways to resolve F1, and which one is right depends on intent only you hold:

1. **Change the design.** Persist accepted jobs so they survive a restart. The G-code is already on disk under a content hash, so only the queue entries and their order need to be stored. This would cascade to:
   - the Architecture paragraph in the `job-queue` design;
   - QUEUE-004, which today only rebuilds running jobs by polling printers;
   - a new spec for restoring the queue on startup;
   - a Decisions row for the store you choose.
2. **Record the exception.** Keep the in-memory queue and add a Decisions row that names the tenet and goal being traded against, the alternative rejected, and the accepted cost (overnight jobs lost on restart; members resubmit). If you go this way, also add a spec for the loss-on-restart behaviour, since it has none today. Consider too whether members are told their job was dropped, because "the queue explains itself" is also a tenet.
3. **Revise the tenet.** If "promise" really means best effort, soften the tenet and the overnight goal in `docs/high-level-design.md` to say so, and let the design stand.

Option 2 closes F2 as a side effect, because the row is the missing capture. Options 1 and 3 still need a row for whichever storage choice lands.

One related item from the report bears on this decision: the three tenets are unordered (F7), and this is exactly a collision between "promise" and "stays small". Ordering them would settle which way the queue should lean, and it would settle the same question the next time it comes up.

I don't edit files in a coach run. When you've picked a direction, running `/linked-intent-dev` with a description of the change will walk it through the HLD, LLD and specs in order.

Which of the three matches what you intended for the queue?