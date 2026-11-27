## Finding F2 Deep Dive: In-Memory Queue Persistence

### What the LLD Currently Says

From `docs/intent/job-queue/job-queue-design.md:14`:
> "On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; **jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them**."

### The Gap

This is a **behavioral choice**, not an implementation detail. The LLD states *what happens* but the Decisions & Alternatives table doesn't capture:
- **Why** this trade was accepted (simplicity? mini-PC constraints? deliberate "ephemeral queue" philosophy?)
- **What the cost is** (member friction: upload at 10 PM, power blip at 2 AM, job gone, member discovers it missing next morning)
- **Whether alternatives were considered** (persist queue to SQLite alongside registry? write accepted jobs to the existing content-hash file store?)

### Why It Matters (Principle: *LLDs close enough of the solution space*)

Two reasonable agents reading this LLD could implement different behaviors:
1. Agent A: "The design says jobs are gone — I'll implement exactly that."
2. Agent B: "That's hostile to members — I'll persist the queue to disk since we're already storing G-code files by content hash."

Both are *compatible* with the written LLD. The LLD doesn't close the edge.

### Recommendation

**Option A: Make the trade explicit (if intentional)**
Add a row to the Decisions & Alternatives table:

| Decision | Chosen | Rationale |
|---|---|---|
| Queue persistence across restarts | Ephemeral — accepted jobs lost on restart | Mini-PC has no UPS; power blips are frequent; persisting queue adds write load and recovery complexity; accepted cost: members resubmit (mitigated by content-hash deduplication making resubmit instant) |

**Option B: Close the edge with persistence (if the current behavior was implicit)**
Add a spec and update the design:
- **New spec**: `QUEUE-006`: When the service shuts down gracefully, the system SHALL persist accepted-but-undispatched jobs to disk and restore them on startup.
- Update the Architecture section to describe the persistence mechanism (e.g., serialize queue to JSON alongside SQLite, or add a `queued_jobs` table).

### My Lean

Given the tenet **"A submitted job is a promise: members should be able to upload and walk away"** — Option B aligns better. An ephemeral queue breaks that promise on every restart. The content-hash store already makes deduplication trivial; persisting the queue order is a small incremental step.

Would you like me to draft the Decision row (Option A) or the new spec + design update (Option B)?