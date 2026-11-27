**The Core Conflict**

`docs/intent/job-queue/job-queue-design.md:14` says accepted but undispatched jobs live only in memory and disappear after a restart. That is especially consequential because the same LLD says the mini-PC experiences unattended updates and power interruptions (`job-queue-design.md:10`).

This works against two declarations in the HLD:

- “A submitted job is a promise: members should be able to upload and walk away.”
- “Evening upload, overnight print, morning pickup, with no member present.”

A member can receive acceptance, walk away, and return to discover that the service silently forgot the job. Keeping the G-code file by content hash does not preserve the promise because the queue metadata connecting that file to its owner, target class, priority, and position has disappeared.

Under *tenet cascade* — downstream mechanisms should lean with the HLD’s preferences and goals — this is a direct conflict rather than merely a reliability improvement opportunity.

**Why The Decision Needs Attention**

The Decisions & Alternatives table explains scheduling, identifiers, and upload limits, but not the more consequential durability choice. A cold reader will naturally question why a system designed for unattended overnight work knowingly loses accepted jobs during an expected operating event.

Under *docs carry current intent* — important reversible choices retain enough reasoning for future readers — the current design leaves that decision under-captured. If volatility is intentional, the accepted cost and the tenet being traded away need to be explicit. A full decision document would be excessive; one well-developed Decisions & Alternatives row should ordinarily be enough.

`QUEUE-004` also says startup “rebuild[s] farm state,” which sounds more complete than the LLD’s actual behavior. It rebuilds currently running printer state, but not the accepted queue. That ambiguity could easily lead a test or implementation author to assume stronger recovery than intended.

**Available Directions**

LID leaves the product decision with you. There are three coherent ways forward:

1. **Change the design to preserve accepted jobs.** Persist the queue metadata alongside the already-persisted G-code, and consider a submission accepted only after both are durable. On startup, restore queued jobs and reconcile them with each printer’s reported current job. This keeps the existing tenet and overnight-printing goal intact.

2. **Keep the volatile queue and record an explicit exception.** Add a Decisions & Alternatives row explaining why simplicity outweighs the submitted-job promise, naming restarts as the accepted loss condition. The UI and acceptance response should then make that limitation visible rather than presenting submission as durable. This closes the decision-capture gap, but intentionally retains the tenet conflict.

3. **Revise the HLD intent.** If submissions are genuinely best-effort until dispatch, rewrite the promise and overnight goal accordingly. The LLD would then align with the HLD, but this materially changes the product members were told to expect.

Recording an exception also resolves the missing decision rationale, but it does not make the behavior durable. Revising only `QUEUE-004` would clarify recovery but would not resolve the higher-level conflict.

**Recommended Workflow**

Before implementation, use `/linked-intent-dev` to walk the chosen direction through the arrow:

1. Decide whether “accepted” means durably queued, explicitly best-effort, or something else.
2. Update the HLD only if the promise or goal changes.
3. Update `job-queue-design.md`, including a Decisions & Alternatives row that names the rejected option and accepted cost.
4. Tighten `QUEUE-004` so “farm state” clearly distinguishes running jobs from queued jobs.
5. Add specs for acceptance durability and restart recovery.
6. Edge-audit interrupted persistence and dispatch, especially the risk of losing or dispatching the same job twice.
7. Write tests before implementing storage and recovery.

Which direction reflects your intent: preserve every accepted job, retain volatility as an explicit exception, or weaken the submitted-job promise?