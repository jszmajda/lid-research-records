Looking at the job-queue design, this is explicitly documented as a deliberate choice:

> "On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; **jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them**." — `docs/intent/job-queue/job-queue-design.md:14`

This isn't a gap — it's a captured decision. But it does tension with the HLD tenet: **"A submitted job is a promise: members should be able to upload and walk away."**

**What the design gives up:**
- Jobs accepted but not yet dispatched are lost on service restart (OS updates, power blips, crashes)
- Members must notice and resubmit — the "promise" breaks silently

**What it gains:**
- Simplicity: no persistence layer, no schema migrations, no durability concerns
- Fits the "mini-PC is modest hardware; the service stays small" tenet

**Recommendations to consider:**

1. **Persist the queue to disk** (SQLite, like the printer registry) — jobs survive restarts; the promise holds. Cost: added complexity, but the registry already uses SQLite.

2. **Persist only metadata** (job ID, class, priority, file hash) — lighter weight; G-code files already stored by content hash.

3. **Keep as-is but add visibility** — on restart, notify affected members their queued jobs were lost (requires contact info / notification path not yet designed).

4. **Document the trade-off explicitly in the Decisions table** — currently it's only in Architecture prose. A row like:
   | Queue durability | In-memory only; lost on restart | Simplicity for MVP; persist if restart frequency or member complaints warrant |

Would you like to explore one of these, or add a decision row to the LLD to make the trade-off more visible to future readers?