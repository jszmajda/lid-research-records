The in-memory queue shows up in `docs/intent/job-queue/job-queue-design.md:14-15`:

*“The queue is a per-printer-class list of accepted jobs held entirely in process memory. On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them.”*

Context on the same page says the mini-PC “takes unattended OS updates and the occasional power blip” `job-queue-design.md:10`.

### What I’m seeing

* **Tenet cascade — *tenets capture forward-looking preference* and *keep the arrow coherent*.**  
  HLD tenets are:
  - *A submitted job is a promise: members should be able to upload and walk away.* `docs/high-level-design.md:20`
  - *The mini-PC is modest hardware; the service stays small.* `docs/high-level-design.md:22`

  Under the operating condition the LLD itself names — an unattended OS update or power blip — the in-memory queue makes the promise fail. A member uploads in the evening, walks away, the PC reboots overnight, and the accepted but not yet dispatched job disappears. The member has to resubmit. The design mitigates that with “Uploaded G-code files are kept on disk under a content hash, so resubmitting the same file is cheap.” `job-queue-design.md:14`

  That is a real tenet tension: *promise* vs *stay small*. The mechanism — in-memory only — works against the *promise* tenet under a restart condition, and no Decisions row or decision doc records the exception, names the tenet traded against, and why.

* **Decision capture — *docs carry current intent* and *docs carry current intent — the keep-side and its ceiling*.**  
  The loss-on-restart behavior is load-bearing intent. It is described in Architecture prose, but it is not in the Decisions & Alternatives table `job-queue-design.md:27-33`. The table records scheduling order, job identifiers and upload size limit, but not the persistence choice for the accepted queue.

  A cold reader holding the LLD and the HLD tenets would still question the choice: *why is it acceptable for a submitted job to vanish on restart?* The rationale — cheap resubmit because G-code is hashed on disk, and staying small on modest hardware — lives only as an aside in prose. That is the kind of implicit context the cold-read pass is meant to surface: it would resolve for someone who was in the chat that produced the doc, but it isn’t written down as a decision with the cost accepted.

* **Mutation vs accumulation.**  
  The statement is present tense and not change narration, so it passes the residue test. The problem is not residue, it is under-capture: the decision is live once landed, and a future session could reverse it without seeing the trade-off that led to it.

Spec linkage is consistent with the current design. `QUEUE-004` says *When the service starts, the system SHALL rebuild farm state by polling each registered printer for its current job.* `docs/intent/job-queue/job-queue-specs.md:4` That spec codifies the restart behavior, but it does not make the tenet trade explicit.

### What I’d recommend

Consider making the trade-off explicit and deciding whether the tenet is really being honoured.

* Record the persistence choice in Decisions & Alternatives. A row such as *Queue durability* — Chosen: in-process memory, lost on restart; Rejected: durable queue on disk — with the rationale naming the two tenets in play and the accepted cost: members must resubmit after a restart, which is deemed acceptable because G-code is hashed and resubmission is cheap, and because the mini-PC constraint is prioritised over durability.

* If you want to keep the in-memory design, document the tenet exception where the tenet applies. Name the tenet traded against, the condition — unattended OS updates / power blips — and why the cost is acceptable. That turns an implicit aside into present intent a cold reader can follow.

* Alternatively, if the promise tenet is non-negotiable, explore the cheapest durability that still respects *stay small*: e.g., persist the accepted queue as a tiny append-only log on disk, rebuilt on start, so the promise holds through restarts without growing the service. That would be a design change that needs a spec and a test-first update.

The arrow is otherwise coherent here; the issue is not linkage, it’s that a decision that a cold reader would still question lives only in prose and is in tension with an HLD tenet. Capturing it as a named decision with the tenet trade made explicit is the fastest way to make the intent walkable and prevent a future session from re-deriving the cost.