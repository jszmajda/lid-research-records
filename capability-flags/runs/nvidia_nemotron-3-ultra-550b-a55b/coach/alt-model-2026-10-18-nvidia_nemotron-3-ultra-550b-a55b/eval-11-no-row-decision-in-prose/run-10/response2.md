## Deep dive: In-memory queue vs. "upload and walk away" tenet

### The conflict

**HLD Tenet 1** (line 20): *"A submitted job is a promise: members should be able to upload and walk away."*

**Job-queue Design** (line 14): *"On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them."*

These are in direct tension. The tenet says the system holds the job reliably once accepted. The design says a restart loses undispatched jobs.

### Why this matters

This isn't just a documentation inconsistency — it's an **unrecorded architectural trade-off**. The tenet sets a user-facing guarantee; the design chooses a simpler implementation (in-memory queue) that breaks that guarantee under a realistic condition (OS updates, power blips — both called out in the LLD context).

Because no Decisions row captures this, a future session will:
1. Read the tenet and assume durability is required
2. Read the design and see in-memory is the choice
3. Have no record of *why* the tenet was relaxed, or what mitigations exist (staff reordering? resubmission UX?)

### What the design *does* say

The LLD context (line 10) acknowledges the mini-PC takes "unattended OS updates and the occasional power blip" — so restarts are expected, not edge cases. The design explicitly accepts job loss on restart.

### Recommendations

**Option A: Persist the queue (align design to tenet)**
- Add a lightweight persistence layer (SQLite, same as printer-registry)
- On startup, reload undispatched jobs from disk
- Add a Decisions row documenting: "Queue persistence added to honor tenet 1; accepted cost: extra disk I/O, schema migration on changes"

**Option B: Relax the tenet (align tenet to design)**
- Change tenet 1 to: *"A submitted job is a promise while the service runs; members should be able to upload and walk away unless a restart occurs before dispatch."*
- Add a Decisions row: "Tenet relaxed to match in-memory queue simplicity; accepted cost: members must resubmit after restarts; mitigated by staff visibility and cheap resubmit (content-hashed files)"

**Option C: Explicit exception (keep both, document the gap)**
- Keep tenet as-is, keep design as-is
- Add a Decisions row in job-queue LLD: *"Restart durability exception — tenet 1 ('upload and walk away') is intentionally not met for undispatched jobs on restart. Rationale: in-memory queue simplicity fits mini-PC constraints; mitigated by content-hash dedup making resubmit instant, and staff reordering visibility."*
- This is the minimum fix per *decision capture* — the exception is recorded, future readers aren't misled.

### My suggestion

**Start with Option C** — it's the smallest change, captures the decision that was already made implicitly, and satisfies *docs carry current intent written to be read cold*. You can evolve to A or B later if the restart-loss proves painful in practice.

Would you like me to draft the Decisions row for Option C, or explore what Option A's persistence schema might look like?