Looking at the job-queue design more carefully, I actually found something I should have surfaced explicitly as a finding.

## The Design Choice

The job-queue LLD states:

> "The queue is a per-printer-class list of accepted jobs held entirely in process memory. On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them."

This is a deliberate choice: **jobs live only in memory, and restart = data loss**. The design acknowledges the tradeoff — members resubmit lost jobs.

## Why This Matters

This is a *load-bearing decision*. A future implementer or maintainer reading this cold could reasonably ask: "Why not persist to SQLite like we do for the registry? Isn't losing accepted jobs a problem?" The decision is live — someone could legitimately want to reverse it by adding durability.

But here's what's missing: **there is no decision row in the Decisions & Alternatives table explaining why this choice was made.**

Compare to the other rows, which all have rationale:
- Scheduling order: FIFO chosen; shortest-job-first rejected with cost stated
- Job identifiers: short slugs chosen; UUIDs rejected with cost stated
- Upload size limit: 64 MB chosen; cost and reasoning stated

But the memory-only queue? It's described in Architecture but not *decided* — no row, no rationale, no stated alternatives considered or costs accepted.

## The LID Principle at Play

This falls under **decision capture** — the principle that load-bearing design choices should be recorded with their rationale so a cold reader understands what was traded off. If this sits only in prose, future sessions have to reverse-engineer it.

## What I'd Recommend

Add a row to the Decisions & Alternatives table:

| Decision | Chosen | Rationale |
|---|---|---|
| Queue durability | In-process memory only | SQLite rejected: mini-PC disk reliability uncertain, adds complexity; accepted cost: jobs lost on unscheduled restart, members resubmit; mitigated by staff override and clear queue view showing what members are seeing |

This makes the tradeoff visible. A future implementer knows:
- *Why* it's memory-only (not accidents, deliberate)
- *What* breaks if it changes (the simple dispatch loop)
- *What cost* is accepted (resubmits on restart)
- *What alternative* was considered (SQLite)

Without this row, the choice looks like an implementation detail rather than a design decision, and the next session might waste time "fixing" something that was intentional.

---

Should I add this as an additional finding in a revised report, or would you like to fold this back into how the project moves forward from here?