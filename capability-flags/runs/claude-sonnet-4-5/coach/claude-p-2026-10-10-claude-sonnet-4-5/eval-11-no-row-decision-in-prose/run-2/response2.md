**F1 (high) — Tenet cascade. The job-queue architecture defeats the HLD's "a submitted job is a promise" tenet under restart conditions.**

The HLD's first tenet says "A submitted job is a promise: members should be able to upload and walk away." But `job-queue-design.md` §Architecture says: "On startup the service rebuilds its picture of the farm by polling each registered printer... jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them." The Context section notes the mini-PC "takes unattended OS updates and the occasional power blip" — so restarts happen in normal operation, not just catastrophic failure. Under those operating conditions, the in-memory queue architecture works *against* the promise-keeping tenet. A member who uploads Tuesday evening and walks away per the tenet may find their job gone Wednesday morning if the mini-PC updated overnight.

This matters because **tenet cascade** — *designs lean the way tenets say to lean* — is how LID keeps the high-level intent from drifting out of sync with what gets built. When a design choice defeats a tenet under described conditions and that conflict isn't recorded, future sessions reading the tenet will expect one kind of system (promise-keeping) while the LLD guides them toward another (best-effort). The gap compounds: each new feature that touches job lifecycle inherits the confusion about whether promises matter or not.

**F2 (high) — Decision capture. The in-memory queue choice trades tenet #1 (promises) against the implicit constraint of simplicity, but that trade isn't in the Decisions & Alternatives table.**

A cold reader looking at the job-queue LLD would question: "Why not persist accepted jobs to disk, so they survive restarts?" The answer seems to be simplicity — keeping "the service stays small" (HLD tenet #3, though that one reads more like a constraint). Disk-backed persistence would add complexity (SQLite writes on every job state change, recovery logic, schema migrations down the road). That's a legitimate trade — trading robustness for simplicity — but it's exactly the kind of choice future sessions will re-debate if it's not captured. The Decisions table has three rows (scheduling, identifiers, upload limits) but not this one.

Why this matters: **decision capture** — *docs carry current intent, written to be read cold* — ensures the reasoning behind non-obvious choices lives in the docs where future sessions find it, not just in the conversation that produced the design. Without a row explaining "we chose in-memory (simple, jobs lost on restart) over disk-backed (robust, more complexity)", the next agent working on job reliability will grep for persistence, find nothing, and either ask you to re-explain the decision or just add disk persistence without realizing it contradicts the simplicity constraint. The explanation cost is permanent and per-session.

---

## What I'd recommend

You have three options, and they compose with each other:

**1. Record the exception in the Decisions table.** Add a row to `job-queue-design.md` Decisions & Alternatives:

| Decision | Chosen | Rationale |
|---|---|---|
| Job persistence | In-memory (jobs lost on restart) | Disk-backed queue rejected: adds SQLite write overhead, recovery logic, and schema burden; accepted cost: members resubmit jobs after unplanned restarts, trading tenet #1 (promise-keeping) for tenet #3 (stays small) |

This closes both F1 and F2. It names the tenet traded against, captures the decision for future sessions, and documents that the trade-off was intentional. The row says "yes, we know this violates the promise tenet under restart conditions, and here's why we accepted that."

**2. Revise the tenet to match what you're actually building.** If the real intent is "A submitted job is a *best-effort* promise..." or "Members can upload and walk away *as long as the service stays up*", update the HLD tenet to say that. Then the design and tenet are coherent again, and F1 disappears (though F2 remains — you'd still want to capture *why* you chose best-effort).

**3. Change the design to honor the tenet.** Add disk-backed job persistence so accepted jobs survive restarts. This would mean using SQLite (like the printer-registry already does) to persist the queue, accepting the added complexity in exchange for keeping the promise. You'd update the LLD Architecture section and add a Decisions row explaining the choice. This also resolves both findings.

---

**My read:** Option 1 (record the exception) is the lightest-weight fix and makes the current design coherent. It doesn't change anything you've built; it just documents the trade you implicitly made. Options 2 and 3 are real alternatives if, on reflection, you want the tenet and design to align rather than recording the conflict. If you go with option 1, a single Decisions row closes both findings in one shot.

Want to talk through which option fits your project, or should I draft the specific wording for the Decisions row if you want option 1?