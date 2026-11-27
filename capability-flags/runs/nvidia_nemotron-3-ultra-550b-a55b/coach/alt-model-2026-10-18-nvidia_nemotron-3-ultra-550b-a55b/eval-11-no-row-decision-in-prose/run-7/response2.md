This is a design decision captured in your LLD, not a finding I flagged. Let me analyze it properly.

## The Decision (from `job-queue-design.md:12-16`)

> The queue is a per-printer-class list of accepted jobs held entirely in process memory. On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them.

## What's Captured

The Decisions table records:
- **Scheduling order**: FIFO within two priority classes — *accepted cost: one long job can hold a class for hours*
- **Job identifiers**: Short base32 slugs — *accepted cost: slugs recycle after 90 days*
- **Upload size limit**: 64 MB

**Not captured**: the in-memory-only queue with loss-on-restart semantics.

## Trade-off Analysis

| Aspect | Assessment |
|---|---|
| **Simplicity** | ✓ No DB schema, no persistence logic, fits "mini-PC stays small" tenet |
| **Member experience** | ✗ Evening upload → overnight restart (OS update/power blip) → job gone → member resubmits next morning |
| **Staff experience** | ✗ Reordering work lost on restart |
| **Spec coverage** | QUEUE-004 covers *rebuilding farm state* but not *queue persistence* |

## Recommendation

**Consider persisting the accepted-job queue to disk** (SQLite, same file as registry or separate). Rationale:

1. **Tenet alignment**: "A submitted job is a promise: members should be able to upload and walk away" — losing jobs on restart breaks this promise for the common case (OS updates, power blips on a mini-PC).

2. **Low cost**: You already have SQLite for the registry; a `jobs` table with `(id, class, priority, gcode_hash, status, position)` is ~50 lines of schema + upsert logic.

3. **Spec gap**: No spec currently says "accepted jobs survive restart." Add one (e.g., `QUEUE-006`) and the test will enforce it.

4. **Decision capture**: If you keep in-memory, add a row to the Decisions table:
   | Decision | Chosen | Rationale |
   |---|---|---|
   | Queue persistence | In-memory only, loss on restart | Simplicity; members resubmit; OS updates rare |

   This makes the trade-off visible to future readers (per *docs carry current intent*).

## Quick Win

If you want to stay in-memory for now, at minimum:
- Add a Decisions row documenting the choice and its accepted cost
- Add a spec: `When the service restarts, the system SHALL NOT lose accepted jobs` — marked `[ ]` (not implemented) so the gap is tracked

Would you like me to draft the Decisions row, the spec, or sketch the SQLite schema?