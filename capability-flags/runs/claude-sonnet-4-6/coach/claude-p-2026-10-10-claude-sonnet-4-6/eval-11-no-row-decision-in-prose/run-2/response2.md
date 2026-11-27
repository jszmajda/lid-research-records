Here's the detailed walkthrough of F1 and F2. They're two facets of the same underlying choice, so it helps to see them together.

---

**F1 — High. The job-queue LLD records no decision for in-memory queue storage.**

The Architecture section of `docs/intent/job-queue/job-queue-design.md` states that queued-but-not-dispatched jobs are lost on restart and that members must resubmit them. It's described as a fact about how the system works, not as a deliberate choice with a rationale. What makes this conspicuous to a cold reader is the contrast sitting right next to it: the printer-registry explicitly notes it uses a SQLite file for persistence, with "nothing else needs concurrent writers" as the justification. A reader sees one half of the system carefully persisted and the other explicitly not — and has no record of why. Under *decision capture* — docs carry current intent, and a deliberate choice that a cold reader would question needs a Decisions row — this is a gap. The consequence of leaving it is that every future session touching job-queue has to either rediscover the reasoning from context or, more likely, make a plausible assumption and proceed: "probably ephemeral because it's a simple queue" or "probably should be persisted like the registry." Both readings are plausible, and neither is grounded in anything on the page. The recommended fix is a Decisions row in the job-queue LLD's Decisions & Alternatives table — naming in-memory storage as the chosen approach, SQLite persistence as the rejected alternative, and the accepted cost (members resubmit after restarts).

---

**F2 — High. "A submitted job is a promise" sits in tension with the behavior F1 describes.**

The first HLD tenet reads: "A submitted job is a promise: members should be able to upload and walk away." The job-queue LLD explicitly acknowledges that the mini-PC "takes unattended OS updates and the occasional power blip" — restarts are not edge cases, they're expected operating conditions. Under those conditions, a queued job silently disappears. A member who uploaded at 9pm and walked away returns the next morning to find their job never ran and is no longer in the queue. The LLD even notes that G-code files are kept on disk under a content hash — so the *file* survives a restart, but the job (the promise) does not. Under *tenet cascade* — a design that works against a tenet under an operating condition the docs themselves describe needs either to honor it or record the accepted exception — there's nothing here. No row says "we trade the promise tenet against simplicity in this scenario."

You have three clean paths to resolve this, and none is inherently the right one:

1. **Change the design** — persist the job queue to SQLite (the same mechanism the registry already uses), so queued jobs survive a restart. The tenet becomes true.
2. **Record the exception** — add a Decisions row naming the tenet traded against and explaining why the accepted cost is worth it (e.g., simplicity on the mini-PC, short queue lengths mean resubmission is fast, staff can reorder). This closes F1 at the same time.
3. **Revise the tenet** — if "upload and walk away" was aspirational but the in-memory tradeoff is permanent, narrow the tenet to reflect what the system actually promises (e.g., "a dispatched job is a promise").

If the in-memory choice is deliberate and the exception is accepted, option 2 is usually the lightest move: one Decisions row closes both findings in one edit to `job-queue-design.md`. If you genuinely want the tenet to hold, option 1 is the right investment — and the machinery already exists in the registry.