## F4 Deep Dive: In-Memory Queue with No Persistence

### What the Design Currently Says

**job-queue-design.md:14** states:
> "The queue is a per-printer-class list of accepted jobs held entirely in process memory. On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them."

**Decisions & Alternatives table** (lines 29-33) captures three decisions but *not this one*.

### Why This Is a Decision-Capture Finding

The principle *docs carry current intent, written to be read cold* asks: **would a cold reader of the landed design still question this choice, or want to reverse it?**

A cold reader sees:
- "Jobs held entirely in process memory"
- "Jobs accepted but not yet dispatched before a restart are gone"
- "Members resubmit them"

They would naturally ask: *Why is this acceptable? What about a 14-hour print queued at 10 PM that the service restarts at 2 AM for an OS update? The member loses their place and must re-upload.*

The rationale ("accepted cost: members resubmit") exists only in the Architecture prose — not in the Decisions table where a future reader expects to find it. The decision is **live** (a cold reader would question it) but **under-captured**.

### What's at Stake

| If Unaddressed | If Captured Properly |
|---|---|
| Next session assumes persistence was forgotten, adds SQLite queue table, creates drift from "in-memory" design | Future sessions see the trade-off was deliberate: simplicity over durability for v1 |
| Staff can't explain to members why their overnight queue vanished | The "accepted cost" is on the record; changing it requires a conscious decision, not drift |
| No basis to evaluate whether v2 should add persistence | Clear baseline: if pain grows, promote to a decision doc with researched options |

### Recommendations

**Minimum (do this first):**
Add a row to the Decisions & Alternatives table in `job-queue-design.md`:

| Decision | Chosen | Rationale |
|---|---|---|
| Queue persistence | In-memory only; accepted jobs lost on restart; members resubmit | Simplicity for v1: no schema migrations, no disk corruption risk, mini-PC restarts are rare (unattended OS updates ~monthly). Cost accepted: members re-upload evening jobs after restart. Revisit when restart frequency or member complaints exceed threshold. |

**If you want to go further (v2 planning):**
- Add a *condition trigger* in the rationale: "Revisit when restarts > 1/week or member complaints > 2/month"
- Consider a lightweight decision doc if the trade-off space grows (Redis vs SQLite vs embedded KV vs file-based queue with fsync)

**Related findings this connects to:**
- **F1** (dispatch failure recovery) — if you later add persistence, "mark suspect" and retry logic must survive restarts too
- **F6** (specs marked `[x]` without tests) — QUEUE-004 ("rebuild farm state by polling") should have a test that verifies *only* currently-printing jobs survive, not queued jobs

### Quick Win

Edit `job-queue-design.md` Decisions table to add the row above. Takes ~30 seconds. The LLD then passes the cold-read test for this decision.