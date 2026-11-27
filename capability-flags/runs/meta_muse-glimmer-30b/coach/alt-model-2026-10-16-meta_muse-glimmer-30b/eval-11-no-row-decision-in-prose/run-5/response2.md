The in-memory queue is the clearest tension in the job-queue LLD.

**What the docs say**

* HLD Tenet: *“A submitted job is a promise: members should be able to upload and walk away.”*
* HLD Goals: *“Evening upload, overnight print, morning pickup — with no member present.”*
* job-queue Context: *“The service runs on the workshop mini-PC, which takes unattended OS updates and the occasional power blip.”*
* job-queue Architecture: *“The queue is a per-printer-class list of accepted jobs held entirely in process memory. On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them.”*

**Why it matters**

*Tenets capture forward-looking preference* — a tenet is a one-line tie-breaker for decisions a spec doesn’t cover.  
*Tenet cascade* — hold each tenet/goal in mind while reading a leaf design and ask whether a mechanism works against it under the operating conditions the docs describe.

Under the conditions the LLD itself describes — unattended OS updates and power blips on the mini-PC overnight — an in-memory queue means an accepted, not-yet-dispatched job is lost on restart and the member must resubmit. That directly defeats *“upload and walk away”* and the *evening-upload / morning-pickup with no member present* goal.

The mechanism and the condition are both on the page, but the tenet/goal conflict is not named. There is no Decisions & Alternatives row for persistence, and no spec that restores accepted jobs after restart. The cost is described in prose — *“members resubmit them”* — but it isn’t recorded as a deliberate trade against a stated tenet.

*Decision capture* — docs carry current intent. A cold reader holding the LLD and the HLD above it would still question this choice and be tempted to reverse it. The landed choice is technically wrong relative to the tenet, which makes the capture finding stronger: the decision is live, and the reasoning for accepting the cost is not in the Decisions table where a future session would expect it.

**What I’d recommend considering**

1. Make the trade explicit. Add a Decisions & Alternatives row for *Queue persistence*:
   * Chosen: in-process memory, jobs lost on restart
   * Rejected: durable queue on disk/SQLite
   * Rationale: mini-PC constraints / simplicity, with the named cost — tenet *A submitted job is a promise* is traded for lower operational complexity; members must resubmit after an unattended restart.
   If you keep the trade, also add a spec that makes the loss explicit, e.g. *When the service restarts, the system SHALL not restore accepted but undelivered jobs*.

2. Or align the design with the tenet. Persist the accepted-but-undelivered queue — e.g., SQLite next to the printer-registry store — so the tenet holds through OS updates and power blips. That would require a new decision row, a spec for restart restoration, and a test citing it.

Right now the design documents the loss but doesn’t record it as a tenet-trade. Making the trade visible lets you decide whether the tenet or the simplicity wins, and prevents a future session from re-deriving the conflict from prose.