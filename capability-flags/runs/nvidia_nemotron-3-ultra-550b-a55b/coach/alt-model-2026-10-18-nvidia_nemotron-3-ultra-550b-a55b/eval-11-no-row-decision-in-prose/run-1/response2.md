This is a design decision captured in `job-queue-design.md:14`:

> "The queue is a per-printer-class list of accepted jobs held entirely in process memory. On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; **jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them**."

**What this means:** Accepted-but-undispatched jobs are lost on any restart (OS update, power blip, deploy, crash). Members must re-upload.

**Trade-offs the doc acknowledges:**
- Simplicity: no persistence layer, no recovery logic
- Honest about the cost: "members resubmit them"

**What's not captured** (connects to my findings F6 and F7):
1. **No decision row** for this choice in the Decisions & Alternatives table — the table covers scheduling order, job IDs, and upload limit, but not the in-memory vs. persisted queue decision.
2. **No HLD-level record** — this is a cross-cutting architectural choice (affects reliability, user trust, staff override semantics) that lives only in LLD prose.
3. **Tenet tension** — Tenet 1: "A submitted job is a promise: members should be able to upload and walk away." An in-memory queue that drops jobs on restart breaks that promise silently.

**Recommendations:**

| Option | When to choose |
|---|---|
| **Persist the queue to SQLite** (same file as printer-registry, or a second table) | You want the "upload and walk away" promise to survive restarts. Low complexity — one `INSERT` on accept, `DELETE` on dispatch, `SELECT` on startup. |
| **Keep in-memory, but make the loss explicit in the UI** | You accept the loss but want members to *know* their job was dropped (e.g., "Your job was accepted but the service restarted — please re-upload"). |
| **Add a decision row** documenting the current choice | If you're not changing the behavior yet, at minimum capture *why* in-memory was chosen and what alternatives were considered, so a cold reader doesn't assume it was an oversight. |

**My take:** For a makerspace where "evening upload, overnight print, morning pickup" is the core user story (HLD Goal 1), losing accepted jobs on the mini-PC's unattended OS updates feels like a broken promise. The SQLite persistence cost is minimal — I'd recommend adding a decision row *and* persisting the queue.

Want me to show what the decision-row entry or a minimal persistence sketch would look like?