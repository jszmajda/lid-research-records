The memory-only queue is described in `docs/intent/job-queue/job-queue-design.md:14-15`:

> The queue is a per-printer-class list of accepted jobs held entirely in process memory. On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them.

That paragraph carries three things that the coach flags:

* **Tenet cascade tension — *tenets capture forward-looking preference* — a tenet is a tie-breaker for decisions with two defensible answers.**  
  HLD Tenets says: “A submitted job is a promise: members should be able to upload and walk away.”  
  A process-memory queue makes that promise conditional on no restart between upload and dispatch. The design acknowledges the breakage — “jobs … are gone, and members resubmit them” — but the tenet and the mechanism are never reconciled in the docs. A cold reader holding the tenet and the architecture together would still question the choice, and under a power-blip condition the mechanism works against the tenet with no Decisions row naming the trade.

* **Decision capture — *docs carry current intent, written to be read cold* — a doc carries current intent as if authored fresh today.**  
  The volatility is stated in Architecture prose, not in the Decisions & Alternatives table. The table records scheduling order, job identifiers, and upload size limit, but no row for persistence vs volatility. The fact is present intent, yet it lives as an incidental aside in body prose. A fresh author choosing the current design would record it in the Decisions table with the alternative considered and the cost accepted. Right now the rationale for accepting data loss is only implied by “the service stays small” and by “resubmitting the same file is cheap”.

* **LLD sufficiency / spec alignment — *LLDs close enough of the solution space* — a good LLD is specific enough that two reasonable agents would land on compatible implementations.**  
  QUEUE-004 covers restart: “When the service starts, the system SHALL rebuild farm state by polling each registered printer for its current job.” That spec captures the rebuild of *running* jobs, but it does not state the fate of accepted-undispatched jobs. The LLD says they are lost; the spec is silent. That leaves the edge open: an agent implementing from the spec alone would not know whether to persist the queue, replay uploads, or prompt the member.

What I’d recommend, in order:

1. Make the volatility an explicit decision. Add a row to the Decisions & Alternatives table in the job-queue design, e.g.:

   Decision: Queue durability  
   Chosen: In-memory only; jobs accepted but not dispatched are lost on restart  
   Rationale: Mini-PC constraints and cheap resubmission via content-hash stored G-code; accepted cost: members must resubmit after a restart before dispatch.

   That makes the trade visible and lets a cold reader decide if they still question it.

2. Decide if the tenet is actually met. If “upload and walk away” must hold across restarts, the decision above is a tenet exception that needs to be named: which tenet is traded, why, and under what condition. If the promise is intentionally scoped to “once dispatched”, tighten the tenet wording in the HLD so the design and the tenet agree.

3. Close the spec gap. Either add an EARS spec that formalises the loss, e.g.:

   - `[ ]` **QUEUE-006**: When the service restarts, the system SHALL discard accepted but undispatched jobs and require members to resubmit them.

   or change the design to persist the queue and add a spec that guarantees durability. Either way the spec becomes the source of truth and the code can be tested against it.

4. Tests-first for the restart path. Write a test citing the new spec before changing code, so the promise/loss behaviour is exercised and stays visible.

The in-memory choice can be perfectly valid for a modest mini-PC, but right now it is implicit context that lives only in a paragraph. Making it an explicit, named decision with a spec and a tenet check is what turns the current “it works, unless it restarts” into intent you can walk the arrow on.