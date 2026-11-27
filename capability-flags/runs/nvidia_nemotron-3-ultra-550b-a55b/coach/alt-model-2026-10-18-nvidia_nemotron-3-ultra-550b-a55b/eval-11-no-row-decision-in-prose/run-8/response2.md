This is a great design tension to explore. Let me walk through what I see.

**The tension:** HLD Tenet 1 states *"A submitted job is a promise: members should be able to upload and walk away."* But the job-queue LLD (Architecture section) explicitly says: *"jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them."* The service restarts for OS updates (per Context), so this isn't theoretical.

**Where the decision lives:** It's in Architecture prose, not the Decisions & Alternatives table. A cold reader sees the behavior but not the *choice* — what was considered, what was traded off, why memory-only was acceptable.

**Tenet cascade check (dimension 19):** Under the described condition (unattended OS update restart), the mechanism (in-memory queue) defeats Tenet 1. No Decisions row records this exception naming the tenet traded against.

**What I'd recommend:**

1. **Promote to Decisions table** — add a row:
   | Decision | Chosen | Rationale |
   |---|---|---|
   | Queue persistence | In-memory only; jobs lost on restart | Mini-PC takes unattended OS updates; persisting adds SQLite schema & recovery complexity. Accepted cost: members resubmit queued-but-undispatched jobs after restarts (mitigated: uploads are cheap via content-hash dedup). |

2. **Explicitly name the tenet trade-off** in that row: *"Trades Tenet 1 (promise) for operational simplicity on modest hardware; restarts are infrequent and resubmit is zero-effort for members."*

3. **Consider whether the tenet needs narrowing** — e.g., *"A submitted job is a promise *between restarts*"* — or whether a lightweight persist (append-only log, or the existing content-hash file store) is worth the complexity to honor the tenet fully.

The LLD already has the right structure (Decisions table exists); this decision just hasn't been captured there yet. Moving it makes the trade-off visible to future sessions and lets the arrow-maintenance overlay (if you add it) flag cascade drift if the tenet or mechanism changes independently.

Want me to show what the updated Decisions table would look like, or explore the lightweight-persist alternative?