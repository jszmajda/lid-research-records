The memory-only queue is the most load-bearing tension in the job-queue LLD.

What is working first: the LLD is specific about the implementation shape. `docs/intent/job-queue/job-queue-design.md:14` states the queue is a per-printer-class list held entirely in process memory, that on startup the service rebuilds its farm picture by polling printers, and that *jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them*. Uploaded G-code is kept on disk under a content hash so resubmission is cheap. That is a clear description of current intent and it is consistent with `QUEUE-004` in `docs/intent/job-queue/job-queue-specs.md`: *When the service starts, the system SHALL rebuild farm state by polling each registered printer for its current job.*

Where it drifts:

*Tenet cascade — do the design nodes lean the way the HLD’s tenets say to lean?*  
The HLD tenet `docs/high-level-design.md:20` is *“A submitted job is a promise: members should be able to upload and walk away.”* The context in the LLD itself notes the mini-PC *takes unattended OS updates and the occasional power blip*. `docs/intent/job-queue/job-queue-design.md:10`  
Under that operating condition, a memory-only queue means a restart wipes pending jobs and members must resubmit. The mechanism works against the tenet under a condition the docs explicitly describe. No Decisions & Alternatives row records the exception, names the tenet traded against, or explains why the trade is acceptable.

*Decision capture — docs carry current intent.*  
The persistence behaviour is described in prose in Architecture, but it is not recorded as a decision. The Decisions & Alternatives table covers scheduling order, job identifiers and upload size limit, `docs/intent/job-queue/job-queue-design.md:29-33`. A cold reader holding the LLD and the HLD tenets would still question the choice and be tempted to reverse it — *would a fresh author put “jobs vanish on restart” on the page without recording the alternative and the cost accepted?*  
The keep-side of *docs carry current intent* says a decision that stays live once landed should be explicit where a future reader can see what was given up. Here the cost — member rework after power blips / OS updates — is named in the prose but not captured as a deliberate trade.

*LLDs close enough of the solution space.*  
The LLD is specific enough to implement, but the edge is left open for who owns the exception. The tenet says “upload and walk away”; the design says “walk away, but if we restart you come back”. That gap is exactly the kind of intent drift that enters the system session after session when the decision is only implicit.

What I’d recommend doing, advisory:

Consider making the persistence choice explicit and testable.

* Record the persistence decision in the Decisions & Alternatives table with a chosen alternative and the cost accepted. Example framing: *Persistence for pending jobs* — Chosen: in-memory only with G-code on disk; Rejected: write-ahead log / SQLite queue; Rationale: mini-PC modest hardware, resubmit is cheap because G-code is hashed on disk; Accepted cost: jobs accepted but not yet dispatched are lost on restart, which conflicts with the “upload and walk away” tenet under power blips / OS updates.
If the team wants to keep the in-memory choice, name the tenet exception explicitly in the LLD and ensure the HLD tenet is not silently undermined. If the team wants the tenet to hold, the design should move toward durable pending state — even a simple append-only log of accepted jobs rebuilt on startup — and that becomes a new decision row.

Add intent coverage for the edge the docs already acknowledge. A spec for restart behaviour, e.g., *When the service restarts, the system SHALL…* makes the promise testable, and a test-first implementation will force the interface to be honest about what survives a restart. That is also the natural place to start the tests-before-code phase for the queue component.

In short: the memory-only queue is documented, but the trade with the “submitted job is a promise” tenet is not captured. Make the trade explicit, decide whether the tenet or the design wins, and close the gap with a spec and test before code is written.