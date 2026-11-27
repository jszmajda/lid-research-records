**F1 — High. Accepted jobs exist only in process memory, which works against the "job is a promise" tenet.**

`job-queue-design.md` (Architecture) says the queue is "held entirely in process memory" and that on restart "jobs that were accepted but not yet dispatched… are gone, and members resubmit them." QUEUE-004 specifies only rebuilding farm state by polling printers, so nothing restores the queue itself. The HLD's first tenet is "a submitted job is a promise: members should be able to upload and walk away," and its first goal is "evening upload, overnight print, morning pickup — with no member present." The design's own Context section says the mini-PC "takes unattended OS updates and the occasional power blip."

Under those conditions a member uploads at 9pm, the box restarts at 3am, and the 8am pickup finds no job and no explanation. The tenet and the mechanism share no wording, which is why this is easy to miss. This is *tenet cascade*: each design node should lean the way the HLD's tenets say to lean. It's worth fixing because the failure is silent and lands precisely on the people the service was built for. They are away, so they can't notice and resubmit.

The remedies are yours to choose, and I'm not picking one for you:

- **Change the design.** Persist accepted jobs. The registry already uses a single SQLite file, so a jobs table in the same store would be consistent with the "service stays small" tenet. Rebuild the queue on startup alongside the printer polling. This would also mean revising QUEUE-004 and adding a spec for queue restoration.
- **Record the exception.** Keep the in-memory queue and add a Decisions row naming the tenet you are trading against and why (for example, "accepted a lost-on-restart queue to keep the service stateless"). You would then probably want to say how members learn their job was lost (that is F7).
- **Revise the tenet.** If a best-effort queue is what you want, soften "promise" to match. That is a real product decision, because it changes what members can count on.

**F2 — High. The in-memory choice has no Decisions & Alternatives row.**

The choice, and its cost ("members resubmit"), shows up only in architecture prose and in QUEUE-004. The Decisions table covers scheduling order, job IDs, and the upload limit, which are smaller calls, but not this one. A cold reader would question the choice, since it sits next to a SQLite-backed registry, and might try to reverse it. They couldn't tell what was given up or whether the cost was weighed. This is *docs carry current intent*: rationale and alternatives that a fresh author would write belong in the Decisions table. Because F1 suggests the choice may be wrong, both findings stand, and the F2 finding is stronger for it.

Whichever remedy you choose for F1, a Decisions row closes F2:

| Decision | Chosen | Rationale |
|---|---|---|
| Queue durability | *(persisted in SQLite, or in-memory)* | *(rejected alternative and accepted cost, naming the tenet it touches)* |

A row is the right size. This is not a choice that needs a full decision doc.

**What I'd recommend.** I'd lean toward persisting the queue. Overnight, unattended restarts are a condition the docs themselves describe, and the "walk away" tenet is the product's whole point. The registry already has the persistence mechanism, so the added surface is small. Then add a Decisions row, update QUEUE-004 or add a restoration spec, and tell members what happens to a job that was mid-dispatch at restart. If you decide the other way, the exception row plus a member-visible "your job was lost" path is the minimum honest version.

The edits are yours to make. If you want to change the design, `/linked-intent-dev` can walk the change through the LLD, specs, and tests. Do you want to pick a remedy and work through the wording together?