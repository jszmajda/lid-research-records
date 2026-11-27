**F1 (high): the in-memory queue works against the "a submitted job is a promise" tenet.**

`docs/intent/job-queue/job-queue-design.md` (Architecture) holds the queue "entirely in process memory." It also says that "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them." QUEUE-004 rebuilds only what printers are currently running, so nothing in the design recovers queued work.

The same doc's Context says the mini-PC "takes unattended OS updates and the occasional power blip." The restarts are therefore expected, not hypothetical.

Under *tenet cascade* (design nodes should lean the way the HLD's tenets say to lean), this conflicts with two HLD statements:
- **Tenet:** "A submitted job is a promise: members should be able to upload and walk away."
- **Goal:** "Evening upload, overnight print, morning pickup — with no member present."

The uploads happen in the evening and the dispatching happens overnight. That is when unattended updates and power blips land. A member who uploaded at 8pm and walked away may come back to a job that never ran, and nothing tells them.

The docs share almost no wording, which is why this is easy to miss. The HLD says "promise," and the LLD says "gone, and members resubmit." The LLD's mechanism does a reasonable thing for the "modest hardware, stay small" tenet, so the tension is real and not a plain mistake.

**F2 (high): the choice is not recorded as a decision.**

The Decisions & Alternatives table has rows for scheduling order, job identifiers and upload limit. It has no row for the volatile queue, the choice with the largest consequence for members. A cold reader would likely question it, and could not tell whether the loss on restart was deliberate and accepted, or an oversight.

**What I'd recommend**

These are your choices, and I'd rather lay them out than pick one for you.

1. **Change the design.** Persist accepted jobs. REG already uses a single SQLite file, and job files are already on disk under a content hash, so a small jobs table is a natural fit. It also fits the "service stays small" tenet. QUEUE-004 would then rebuild the queue from storage as well as polling printers, and you'd likely add a spec such as "when the service restarts, the system SHALL restore accepted-but-undispatched jobs in their prior order." Add a Decisions row saying what was rejected (in-memory only) and why.
2. **Keep it volatile and record the exception.** Add a Decisions row that names the tenet and goal being traded against, and why. For example: "accepted jobs lost on restart; accepted cost: members resubmit; chosen to keep the service small." If you keep this route, consider making the loss visible to members so it isn't silent, and acknowledge the tension with the "promise" tenet.
3. **Revise the tenet.** If losing queued jobs on restart is acceptable, narrow the tenet's wording and the overnight goal to match what the service actually promises.

Recording the exception (option 2) also closes F2. Option 1 closes F2 as well, as long as the new Decisions row records the choice.

If you go with option 1 or 3, which changes the design or the HLD, `/linked-intent-dev` is the place to walk the change through the arrow (HLD, then LLD, then specs). I haven't edited any files. Which way do you want to lean?