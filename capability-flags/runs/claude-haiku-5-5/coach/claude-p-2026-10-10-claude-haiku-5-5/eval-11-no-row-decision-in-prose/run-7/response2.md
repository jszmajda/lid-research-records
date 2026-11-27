## The in-memory queue: what I found and what I'd do

Two findings come from the same decision, so I'll cover them together. They are F1 (high) and F3 (medium).

**What the design says now.** The job-queue LLD keeps the queue "entirely in process memory." On restart, "jobs that were accepted but not yet dispatched... are gone, and members resubmit them" (`docs/intent/job-queue/job-queue-design.md`, line 14). The uploaded G-code files survive, since they're on disk under a content hash, but the queue that says which file runs next does not.

**Why it's a finding.** The LLD states the behavior, so it isn't an accident. The coach flags it for two reasons:

1. **It pulls against the HLD.** The first tenet is "A submitted job is a promise: members should be able to upload and walk away." The main goal is "Evening upload, overnight print, morning pickup — with no member present." The HLD also says the mini-PC "takes unattended OS updates and the occasional power blip." A restart at 2 a.m. is therefore a normal event, and it erases jobs that members believed were queued. Nobody is present to resubmit them, so the morning pickup fails silently. That is the exact case the tenet and goal are written to prevent.
2. **The choice isn't recorded.** The job-queue Decisions table has rows for scheduling order, job IDs, and upload size, but none for "queue lives in memory." A cold reader sees a design that contradicts the first tenet and finds no explanation. Under the decision-capture lens, that's a live choice with no row, so the next person to read it will want to reverse it.

**What I'd recommend.** I'd persist accepted jobs, and I'd add a Decisions row either way. Here's the reasoning.

- **Persist the queue records.** Write each accept, dispatch, failure-return, and reorder to disk. On startup, reload the queue alongside the printer polling that QUEUE-004 already does. The G-code files are already on disk, so the new state is small job records, which keeps the service small (tenet three). A plain file or small store is enough. This matches the tenet and the overnight goal, and it turns a silent loss into a non-event.
- **Decide where the records live.** The registry's Decisions table says a single SQLite file was chosen because "nothing else needs concurrent writers." Putting queue writes into that same file would undercut that rationale. The cleaner path is a separate store, or an explicit revisit of the registry's row. That crosses a node boundary, so it needs your confirmation before I propagate it.
- **Update the spec and the LLD together.** QUEUE-004 should say what it restores (the queue, not just farm state). The Architecture paragraph should drop the "gone" sentence. Add a Decisions row for the persistence choice, naming what it costs (write frequency, a little startup time).

**The alternative if you want to keep memory-only.** That's your call. The coach's rule is that an exception is acceptable when it's recorded. If you keep the in-memory design, add a Decisions row that names the first tenet (and the overnight goal) as the thing traded against, states the cost (queued jobs are lost on restart, and members resubmit), and says how members find out. Then the conflict is a documented choice rather than a surprise.

Either way, the decision is yours. I haven't changed any files, since this review is advisory. If you want to go with persistence, I can draft the LLD, spec, and Decisions-row edits for you to review.