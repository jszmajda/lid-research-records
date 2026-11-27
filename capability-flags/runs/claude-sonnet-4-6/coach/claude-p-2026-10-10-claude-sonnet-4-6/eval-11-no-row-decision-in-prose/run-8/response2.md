These two findings are cousins — F1 is the tenet-cascade tension, F3 is the missing record of the tradeoff that tension produces. They're worth walking together because the remedy for F1 also closes F3.

---

**F1 — High. The in-memory queue design works against Tenet 1 under operating conditions the LLD itself names.**

The job-queue LLD (`docs/intent/job-queue/job-queue-design.md`) describes the queue as "held entirely in process memory" and explicitly notes that the mini-PC "takes unattended OS updates and the occasional power blip." It goes on to say: "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them." Now hold that against Tenet 1 in the HLD: *"A submitted job is a promise: members should be able to upload and walk away."* Those two things are in direct tension. Under the described conditions — an OS update fires at 2 AM while a member's overnight job sits accepted but unstarted — the job silently disappears and the member comes in the next morning to find their print never ran. The tenet says the upload is the promise; the design says it's actually a conditional promise that quietly expires on restart. Under *tenet cascade — designs that work against a stated tenet under a described operating condition* — this is the pattern LID surfaces: not a worst-case scenario the team overlooked, but a condition the docs themselves already name as normal. Leaving it unaddressed means every future session working on the job-queue reads the LLD, sees "in-memory," and may tighten or extend the design in ways that make the gap deeper — without any signal that the choice was live. You have three remedies, and this is your call to make:

1. **Change the design** — persist accepted-but-unstarted jobs so restarts don't lose them. Possibly a lightweight queue file or the same SQLite the printer-registry already uses. This fully honors the tenet.
2. **Record the exception** — add a Decisions row to the job-queue LLD explicitly naming the tradeoff: the accepted cost is that a restart before dispatch drops the job; the reason might be mini-PC simplicity (Tenet 3) or deliberate scope-trimming. This doesn't fix the tension, but it makes it visible and intentional — future sessions read the table and know it was a considered call, not an oversight.
3. **Revise the tenet** — if the team's actual intent is "uploaded jobs are *usually* safe" rather than an absolute promise, the HLD tenet could reflect that. Worth considering whether the current wording sets an expectation you can't honor without persistent storage.

---

**F3 — Medium. The architecture prose describes the consequence of the in-memory choice, but the Decisions table doesn't capture it.**

This is the record-keeping counterpart to F1. The job-queue LLD's Architecture section states the restart-loss behavior matter-of-factly, as if it's just the shape of the thing, but the Decisions table (`## Decisions & Alternatives`) has three rows — scheduling order, job identifiers, upload size — and none of them address why the queue lives only in memory. Under *decision capture — docs carry current intent written to be read cold* — a cold reader holding this LLD would notice the restart-loss sentence, notice the "upload and walk away" promise in the HLD's tenets, and not be able to find the reasoning that reconciled them. The cost of leaving it out is that future sessions building on the job-queue have no purchase for the reasoning: they might "helpfully" add a persistence layer without realizing it was weighed; or they might leave it as-is assuming it was just never thought about. Either path treats the landed choice as an accident. Regardless of which remedy you pick for F1, a Decisions row should close this gap — if you keep the in-memory design, the row names the cost accepted and what it traded against (probably Tenet 3 and the constraint of mini-PC simplicity); if you add persistence, the row records the earlier choice and why the design moved. Recording the exception for F1 also writes this row, so the two findings close together.

---

If you want to add a Decisions row right now, the tightest form would be something like:

| Decision | Chosen | Rationale |
|---|---|---|
| Queue durability | In-memory only; accepted-but-unstarted jobs lost on restart | Keeps the service small (Tenet 3); accepted cost: a restart before dispatch breaks the Tenet-1 upload-and-walk-away promise — members must resubmit |

That row doesn't need to resolve the tension — it just makes it legible. You can edit `docs/intent/job-queue/job-queue-design.md` directly, or if you want to explore changing the design first, `/linked-intent-dev` with a description of what you want (e.g., "persist the job queue so restarts don't lose accepted jobs") is the right place to work that through.