## F4 Deep Dive: Job Queue In-Memory Design vs. Tenet 1

### The Conflict

**Tenet 1 (HLD:20):** *"A submitted job is a promise: members should be able to upload and walk away."*

**Job-queue design (job-queue-design.md:14):** *"On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them."*

This is a direct tension: the tenet promises members can upload and walk away; the design breaks that promise when the mini-PC restarts (OS updates, power blips — both called out in the design's Context section).

### Why No Decision Row Captures This

The Decisions & Alternatives table (job-queue-design.md:29-32) records three choices — scheduling order, job identifiers, upload size limit — but **not** the persistence strategy. This is a decision that:
1. A cold reader would question (why discard accepted jobs?)
2. Has a clear trade-off (simplicity vs. promise-keeping)
3. Directly opposes a declared tenet

### Recommendations

**1. Add a Decisions row** — minimal fix, captures the trade-off honestly:
| Decision | Chosen | Rationale |
|---|---|---|
| Job persistence on restart | In-memory only; accepted-but-undispatched jobs lost | SQLite persistence rejected: adds write path, schema migration, and recovery complexity on modest hardware; accepted cost: members resubmit after OS updates/power blips (rare, minutes of downtime) |

**2. If the tenet is non-negotiable**, consider lightweight persistence:
- Append-only log of accepted jobs (one line per upload: job-id, class, file-hash, timestamp)
- On startup, replay log → re-queue undispatched jobs
- Cost: ~few KB/day, trivial recovery, keeps the promise

**3. Or revise the tenet** if "walk away" means "until the next reboot":
> *"A submitted job is a promise until the service restarts; members should be able to upload and walk away between restarts."*

Option 1 is the LID-minimal move: make the implicit decision explicit. Option 2 aligns code with tenet. Option 3 aligns tenet with reality.

Which direction feels right for your context?