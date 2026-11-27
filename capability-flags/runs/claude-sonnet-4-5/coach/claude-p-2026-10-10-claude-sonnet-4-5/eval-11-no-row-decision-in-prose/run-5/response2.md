**F1 — High. The job-queue architecture loses accepted jobs on restart, contradicting Tenet 1's reliability promise.**

Looking at `docs/intent/job-queue/job-queue-design.md` lines 14-15: "The queue is a per-printer-class list of accepted jobs held entirely in process memory. On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them." Meanwhile, the HLD's first tenet states "A submitted job is a promise: members should be able to upload and walk away." The context acknowledges the mini-PC "takes unattended OS updates and the occasional power blip" — so restarts aren't rare edge cases, they're operational reality.

This is a **tenet cascade** violation — *designs should lean the way the HLD's tenets say to lean*. When a design contradicts a tenet without documenting the tradeoff, future sessions can't tell whether this was a deliberate choice or drift. An agent (or person) reading the HLD would expect the queue to be durable, not volatile. When they discover jobs vanish on restart, they can't tell if that's a gap to fix or an intentional tradeoff against Tenet 3 ("the service stays small"). The lack of a decision record means this tension resurfaces every time someone thinks about reliability — it never settles.

The deeper cost: members who trust "upload and walk away" will lose jobs without realizing it, especially for overnight prints (the primary use case the HLD describes). If the mini-PC restarts during an OS update at 3am, the member's evening upload is gone when they arrive in the morning. That's a broken promise that erodes trust in the system, and it contradicts the first-listed tenet.

## What you could do

You have three paths, and they're not mutually exclusive:

**1. Change the design to honor the tenet.** Persist accepted jobs so they survive restarts. The printer-registry already uses SQLite (line 14 of printer-registry-design.md), so extending that schema with a `jobs` table wouldn't add a new dependency or violate Tenet 3's "service stays small." The in-memory queue could become a cache over the persisted queue — dispatch still happens from memory (fast), but accepted jobs get written to disk immediately and reloaded on startup. Update the job-queue LLD's Architecture section to describe the persistence layer, add a spec (maybe `QUEUE-006`) requiring the system to persist accepted jobs and restore them on startup, and cascade that to the Decisions table if the persistence choice involves interesting tradeoffs (SQLite vs. flat files, for example).

**2. Record the exception — explain why Tenet 3 wins here.** If you've decided that Tenet 3 ("modest hardware; stay small") outweighs Tenet 1 in this dimension, add a Decisions & Alternatives row to the job-queue LLD explaining that choice:

| Decision | Chosen | Rationale |
|---|---|---|
| Queue persistence | In-memory only, no durability across restarts | Keeps the service small and fast (Tenet 3 prioritized over Tenet 1's promise); accepted cost: jobs lost on restart must be manually resubmitted; mitigation: [describe what compensates — maybe member notification of job loss? Or restarts are rare enough to accept the loss?] |

This makes the tradeoff visible and intentional. If you take this path, also consider ordering the tenets (F3) to make it clear Tenet 3 trumps Tenet 1 when they conflict — that makes this row's rationale easier to read.

**3. Revise the tenet to match reality.** If the current design is right and the tenet overpromises, soften Tenet 1 to reflect what the system actually commits to. Something like "A submitted job should reach dispatch or explain why it didn't" — that allows for notification of job loss rather than guaranteeing durability. Then update the job-queue design to describe the notification mechanism (if one exists or should exist).

My read: Path 1 seems most aligned with your HLD's goals ("Evening upload, overnight print, morning pickup — with no member present"). The primary use case depends on jobs surviving overnight, which is exactly when unattended OS updates happen. Persisting to SQLite is a small addition that closes the gap. But if Tenet 3 is weight-bearing — maybe the mini-PC really can't spare the disk I/O, or you've decided simplicity matters more than durability — then path 2 documents that choice so it doesn't resurface every session.

Does one of these paths fit what you had in mind, or is there a constraint I'm not seeing that shapes the choice differently?