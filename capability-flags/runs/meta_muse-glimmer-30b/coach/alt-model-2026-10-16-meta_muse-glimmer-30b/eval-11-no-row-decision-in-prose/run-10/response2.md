The tension is between the HLD tenet and the job-queue design as it stands today.

**What the docs say**

* Tenet, `docs/high-level-design.md:20`
  > A submitted job is a promise: members should be able to upload and walk away.

* Design, `docs/intent/job-queue/job-queue-design.md:14-15`
  > The queue is a per-printer-class list of accepted jobs held entirely in process memory. On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them.

* Architecture note, same file `docs/intent/job-queue/job-queue-design.md:14`
  > Uploaded G-code files are kept on disk under a content hash, so resubmitting the same file is cheap.

The tenet is a forward-looking tie-breaker: when a decision has two defensible answers, lean toward “members can upload and walk away.” The design choice to keep the accepted-but-undispatched queue only in process memory makes that tenet unachievable under any restart, power blip, or OS update — exactly the operating conditions the design calls out in Context:

`docs/intent/job-queue/job-queue-design.md:10`
> The service runs on the workshop mini-PC, which takes unattended OS updates and the occasional power blip.

A cold reader holding the tenet and the design together would still question the choice and be tempted to reverse it. That is the *tenet cascade* signal: under a described condition the mechanism works against a tenet or goal, and no Decisions & Alternatives row records the exception naming the tenet traded against and why.

The Decisions & Alternatives table in the LLD does not cover durability:

`docs/intent/job-queue/job-queue-design.md:29-33`
Scheduling order, Job identifiers, Upload size limit are recorded. Persistence / restart loss is not.

**Why it matters**

*Intent leads; code is compiled output.* If the spec layer is later written to match the lossy implementation, the spec becomes a description of code after the fact rather than intent driving code. The gap compounds session over session and the project loses the ability to reason about its own behavior at the spec level.

*Docs carry current intent, written to be read cold.* The design currently encodes two contradictory intents: “upload and walk away” at HLD level, and “jobs disappear on restart” at LLD level. Future sessions will have to sort live intent from residue before they can act, and the tax compounds every session.

**What I’d recommend considering**

You have two coherent ways to close the gap, and LID wants the choice made explicitly in the design node that dominates it:

1. **Keep the tenet, make the design durable.**
   * Promote durability to an explicit design decision and cascade it.
   * Persist the accepted-but-undispatched queue to the mini-PC’s disk — e.g., a small append-only journal or SQLite table keyed by the same content hash used for G-code storage. On startup, replay the journal to rebuild the in-memory queue.
   * Add EARS specs that make the promise testable, e.g.:
     * `QUEUE-??: When the service restarts, the system SHALL retain all previously accepted but undispatched jobs and resume dispatch in original order.`
     * Scope the durability requirement to the tenet and record the trade-off in Decisions & Alternatives: chosen persistence mechanism, accepted cost in mini-PC I/O and complexity, alternative of in-memory only rejected because it violates the tenet.
   * This keeps the arrow coherent: Tenet → LLD decision → spec → test → code.

2. **Keep the in-memory design, revise the tenet/goal.**
   * If durability is intentionally out of scope for the mini-PC, make that an explicit, load-bearing choice.
   * Update the HLD tenet or add a Key Design Decision that narrows the promise: e.g., “A submitted job is a promise *while the service is running*” or “Members may need to resubmit after an unattended restart.”
   * Record the exception in the LLD Decisions & Alternatives table, naming the tenet traded against and why — hardware constraints, acceptable resubmission cost because G-code is stored by hash, etc.
   * Then EARS should reflect the actual behavior: a spec that the system SHALL discard undispatched jobs on restart and notify members, and tests that assert that.

The first option aligns with the current HLD intent and is the more durable long-term posture for a shared makerspace. The second option is valid if you deliberately choose to trade reliability for simplicity — but it must be made explicit, otherwise you have a silent tenet violation that will reappear every time someone reads the docs cold.

Do you want to explore a concrete persistence sketch for option 1, or work through the wording for an explicit tenet exception under option 2?
