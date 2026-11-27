Good catch — this deserves a closer look, because it's actually a **decision-capture issue I should have flagged more clearly**.

Here's what the design says:

From the QUEUE LLD Architecture section:
> "The queue is a per-printer-class list of accepted jobs held entirely in process memory... jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them."

And the tenet from the HLD:
> "A submitted job is a promise: members should be able to upload and walk away."

**The tension:**

Those two statements are in direct conflict. A "promise" suggests durability — once accepted, the job is safe. But the design loses jobs on restart, which breaks that promise if the mini-PC crashes or updates overnight.

**Why this matters:**

The design resolves this tension implicitly by accepting job loss as a cost of keeping the service small (in-memory, no database). But that resolution isn't recorded anywhere. A cold reader (or you in 6 months) would see "jobs in memory only" and wonder: "Is this a deliberate trade-off, or an oversight? Should we persist to SQLite?"

**What's missing:**

The QUEUE Decisions & Alternatives table should have a row like:

| Decision | Chosen | Rationale |
|---|---|---|
| Job persistence | In-memory only | Keeps service small on modest hardware; accepted cost is job loss on restart (members resubmit). Alternative: persist to SQLite, but adds complexity and disk I/O to the critical path. |

**My recommendation:**

Add that row to the Decisions table *before* implementation. Right now the decision lives in architecture prose, which is fragile — it's easy to miss, and easier to contradict. Once it's in the Decisions table with rationale, the first implementer and every future reader will see it clearly.

This is a solid design choice (the trade-off is defensible given the hardware constraints), but the choice itself needs to be made *visible*, not just implied. That's when it stops being a drift risk.