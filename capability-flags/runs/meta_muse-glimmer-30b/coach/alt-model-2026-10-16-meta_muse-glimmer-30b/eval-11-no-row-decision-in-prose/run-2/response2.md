The observation is in `docs/intent/job-queue/job-queue-design.md:14-15`:

> The queue is a per-printer-class list of accepted jobs held entirely in process memory. On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them.

Two principles are speaking here.

**Tenet cascade — *tenets capture forward-looking preference* — do the design nodes lean the way the HLD’s tenets and goals say to lean?**

HLD `docs/high-level-design.md:20-21` states the tenet:

> A submitted job is a promise: members should be able to upload and walk away.

The context in the same LLD, `job-queue-design.md:10`, notes the service runs on the workshop mini-PC, which “takes unattended OS updates and the occasional power blip.”

Under that operating condition the current design makes the promise false: an accepted but not-yet-dispatched job disappears on restart and the member must resubmit. That is a mechanism that works against the tenet when the condition described in the doc itself occurs. No Decisions & Alternatives row records the exception, and the tenet is not qualified.

If the loss is intentional, the decision is live but under-captured. A cold reader holding the HLD tenet and the LLD would still question the choice or be tempted to reverse it.

**LLDs close enough of the solution space — a good LLD is specific enough that two reasonable agents would land on compatible implementations, and not so specific it reproduces code.**

“held entirely in process memory” and the restart-loss behavior are implementation mechanisms, not just intent. The LLD is doing two things at once:

* stating an intent-level durability property — “accepted jobs survive restarts” or “accepted jobs do not survive restarts” — and
* picking a mechanism to achieve it — in-process list, rebuild by polling printers, G-code kept on disk under a content hash.

The mechanism is load-bearing here because the tenet is in play. The decision is therefore design-level, but it is written as a descriptive fact rather than as a chosen trade-off with its cost made explicit.

What I’d recommend, advisory only:

* Make the durability intent explicit and decide it at design time. If the promise tenet stands, the LLD should state that accepted jobs are durable across restarts and the implementation must persist the queue. The printer-registry already uses a single SQLite file for this hardware; reusing that pattern for the queue would keep the mini-PC constraint and the tenet aligned.

* If the team deliberately accepts loss on restart — e.g., to keep the service small per the HLD tenet “The mini-PC is modest hardware; the service stays small” — record it as a Decisions & Alternatives row with the tenet traded against, the condition, and the accepted cost. That makes the tenet cascade visible: you are choosing to relax “upload and walk away” in exchange for simplicity, and the cost is members resubmitting after an OS update/power blip.

* Defer the exact in-process data structure to code. Keep the LLD at the level “accepted jobs are durable / volatile” and the rationale for the choice, not “held entirely in process memory.” That preserves the *LLDs close enough* sweet spot — enough specificity to prevent drift, not so much that the doc rots with every implementation tweak.

Right now the design encodes a lossy durability policy that conflicts with the stated tenet, and the conflict is implicit. Making the choice explicit — either by persisting the queue or by documenting the deliberate trade-off and, if needed, qualifying the tenet — restores coherence along the arrow and gives future sessions a clear, cold-readable record of why the queue behaves the way it does.