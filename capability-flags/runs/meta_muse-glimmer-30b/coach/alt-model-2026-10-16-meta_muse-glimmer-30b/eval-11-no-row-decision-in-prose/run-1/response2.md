The job-queue LLD is where the in-memory choice shows up, and it’s the clearest place where intent is ambiguous to a cold reader.

**What the docs say**

`docs/intent/job-queue/job-queue-design.md:14-15`

> The queue is a per-printer-class list of accepted jobs held entirely in process memory. On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them.

The Decisions & Alternatives table in the same LLD covers scheduling order, job identifiers and upload size limit. It does **not** record a decision about persistence or about accepting data loss on restart.

The HLD tenets are:

`docs/high-level-design.md:20-22`

- *A submitted job is a promise: members should be able to upload and walk away.*
- *Staff override members, but the queue explains itself — no silent reordering.*
- *The mini-PC is modest hardware; the service stays small.*

**Why this matters**

*docs carry current intent, written to be read cold* — a doc must stand on its own without the conversation that produced it. A cold reader sees “jobs accepted but not yet dispatched are gone” stated as architecture fact, with no marker that this is a temporary limitation or a deliberate trade-off. The reader cannot tell whether the loss is *intent* or *implementation residue*.

*tenets capture forward-looking preference* — a tenet is a tie-breaker for decisions the specs don’t cover. The tenet “A submitted job is a promise: members should be able to upload and walk away” is directly contradicted by a mechanism that loses accepted jobs on an OS update or power blip. That is a *tenet cascade* signal: under a described operating condition — the mini-PC taking an unattended OS update and the occasional power blip, noted in the LLD context `docs/intent/job-queue/job-queue-design.md:10` — the design works against a tenet, with no Decisions row or decision doc recording the exception.

The principle *intent leads; code is compiled output* also applies: if the loss is implementation reality rather than declared intent, the LLD is describing code after the fact instead of driving it. The gap compounds because future agents will treat “jobs are gone” as a requirement and build around it.

**What I’d recommend you consider**

First, decide the intent and make it explicit.

* If data loss on restart is deliberate — e.g., you accept the cost for simplicity on modest hardware — promote it to a named design choice. Add a row to the Decisions & Alternatives table with the chosen option, the rejected alternative — e.g., on-disk queue / SQLite / append-only log — and the accepted cost. Link it to the tenet and make the trade-off readable. If you keep the loss, you may also want a tenet or goal that codifies the acceptable failure mode, because the current tenet promises durability.

* If data loss is *not* deliberate, the LLD is under-specifying and drifting from the tenet. In that case the intent should be captured as a spec and an LLD refinement. A minimal EARS capture would be something like: *When the service restarts, the system SHALL …* — either restore accepted but undispached jobs, or explicitly reject new uploads until the farm is quiescent. The choice then cascades to the LLD architecture: “held entirely in process memory” would need to change, and the restart rebuild logic would be updated.

Second, tighten the cold-read surface. Remove narration that reads like history or apology. State the current policy in present tense and put the rationale in the Decisions table, not in the architecture prose. If the loss is temporary, do not document it as current intent — document the target state and mark the gap explicitly.

That clarification will either make the tenet–mechanism tension an intentional, recorded trade-off, or it will surface a real intent gap you can close with a spec and a small design change before code follows.