The in-memory queue is the finding I'd look at first. It's the one place where the design's own text works against the HLD's promise to members.

**What the design does now.** `job-queue-design.md` (Architecture, line 14) keeps each printer class's queue entirely in process memory. If the service restarts, jobs that were accepted but not yet dispatched are gone, and members have to resubmit them. On startup, the service only rebuilds what's already running on each printer (QUEUE-004).

**Why it matters.** The HLD makes two promises that this design can break:
- Tenet 1: "A submitted job is a promise: members should be able to upload and walk away."
- Goal 1: "Evening upload, overnight print, morning pickup, with no member present."

The job-queue design itself says the mini-PC "takes unattended OS updates and the occasional power blip." So the failure isn't hypothetical. A member who uploads at 9pm can lose the job at 2am, and find out at pickup time. Nothing in the Decisions table records that trade, so a future reader would have no way to know it was chosen.

**The two things I'd want you to decide between:**

1. **Persist the queue (my recommendation).** Uploaded G-code already survives restarts, because it's stored on disk under a content hash. Only the queue's ordering and membership are lost. Writing that list to the same SQLite file the registry already uses would close the gap. The HLD's "small service" tenet still holds, since it's one table in an existing file with one writer. On startup, the queue would reload its jobs, then reconcile against printers (QUEUE-004) so a job that was dispatched just before the crash isn't sent twice. This would also need a new spec (something like QUEUE-006: "When the service restarts, the system SHALL restore accepted, undispatched jobs in their original order") and a Decisions row for the persistence choice. If the in-memory design was an accident, this is the cleanest fix.

2. **Keep it in memory, and say so.** If the loss is an accepted cost, the design should say that explicitly: add a Decisions row naming the tenet traded against and the cost accepted (members resubmit after restarts), and soften tenet 1 or goal 1 so they don't promise overnight durability. That's honest, but it means the promise members hear ("upload and walk away") is weaker than the one the HLD currently makes.

**What I can't tell from the docs.** The text reads as if the in-memory choice was deliberate ("members resubmit them" sounds like an accepted cost), but there's no Decisions row, and nothing about the restart case in the HLD. Whether it was a choice or a default is the question that decides between the two options. I'd only answer that from you.

**Related items.** The same restart and failure seam shows up in two other findings. F6 is that retiring a printer's last slot can strand queued jobs, and F3 is that neither the in-memory choice nor the staff-first priority has a Decisions row. If you go with option 1, I'd fix F3 and F6 in the same pass, since both touch the queue's state.

I haven't changed any files; this is advisory. If you tell me which option you want, I can draft the spec, Decisions row, and tenet wording for you to review before anything is written to the docs.