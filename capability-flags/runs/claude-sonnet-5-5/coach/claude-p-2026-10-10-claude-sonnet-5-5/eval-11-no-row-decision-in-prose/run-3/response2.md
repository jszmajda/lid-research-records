Two findings touch this, F1 (the design works against a tenet) and F2 (the choice has no recorded reasoning). They are the same choice seen from two sides.

**F1 (high): accepted jobs live only in memory, which works against the "promise" tenet.** The job-queue LLD's Architecture section says the queue is "held entirely in process memory" and that after a restart, "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them." The two docs never share wording, but they conflict under a condition the LLD itself describes. The same Context section says the mini-PC "takes unattended OS updates and the occasional power blip." The HLD's first tenet is "A submitted job is a promise: members should be able to upload and walk away," and its first goal is "evening upload, overnight print, morning pickup — with no member present." A restart at 2 a.m. silently erases the evening's accepted jobs, and the member who walked away learns about it at pickup time. QUEUE-004 only rebuilds what is *running*, so nothing in the specs covers the lost jobs either. This is *tenet cascade* (design nodes should lean the way the HLD's tenets say to lean). If it sits, the tenet becomes untrue in the normal overnight case, and the next session reading the HLD will assume a durability the queue doesn't have.

**F2 (medium): the choice has no Decisions & Alternatives row.** The table records scheduling order, job IDs and upload size, but not the in-memory queue, which is the choice most likely to make a cold reader ask "why?". They would also see that the registry persists to SQLite while the queue does not, and wonder whether that is deliberate. The reasoning, what was given up, and what cost was accepted exist only in the author's head. This is *docs carry current intent* (a live decision's reasoning belongs on the page). Without the row, a future session can't tell whether in-memory was a considered trade for a small service or an accident.

**Your options.** The choice is yours, and I'd rather lay out what each costs than pick one for you:

1. **Change the design: persist accepted jobs.** The registry already runs a single SQLite file, so the queue could share that mechanism. The G-code files already survive on disk by content hash, so only the queue entries and their order would need to persist.
   - This honors the tenet as written.
   - It costs some of the "service stays small" tenet, the third in the HLD.
   - It would change QUEUE-004 to cover rebuilding queued jobs as well as running ones, and probably adds a spec for restoring the queue.
2. **Record the exception.** Keep the in-memory queue and add a Decisions row naming the tenet it trades against and why: staying small on modest hardware, plus the rejected alternative of persisting and the accepted cost that restarts drop queued jobs.
   - This closes F2 as well as F1.
   - It leaves the first tenet and the overnight goal knowingly weaker, and you may want to say what members are told, since "resubmit" assumes someone is present.
3. **Revise the tenet.** If a restart-tolerant promise is what you actually mean ("accepted jobs run unless the service restarts"), rewrite the tenet and goal to match.
   - This is honest, but it concedes the unattended-overnight story the HLD is built around.

Option 2 is the smallest edit, but it only reads as healthy if you really are content for the overnight promise to be conditional. Option 1 is the one that keeps both HLD statements true. Which of these reads closest to what you intended when you wrote the LLD?

I haven't edited anything. Whichever you choose, you apply it directly in `docs/intent/job-queue/job-queue-design.md` and `job-queue-specs.md`. If you pick option 1, I can also help you work through how it should cascade into the specs.