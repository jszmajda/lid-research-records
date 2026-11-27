These are F2 and F3 from the report, which are really two faces of the same gap — so I'll walk them together, then give you the recommended actions.

---

**F2 & F3 — High. The in-memory queue discards accepted jobs on restart, trading against tenet 1 with no record of the trade.**

The `job-queue-design.md` Architecture section says, matter-of-factly: "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them." That's a real architectural choice — keeping the queue in process memory rather than persisting it — and it's defensible given tenet 3 ("the service stays small"). But it runs directly against tenet 1: "a submitted job is a promise: members should be able to upload and walk away." An OS update at 2 a.m. drops every queued job. Members who uploaded in the evening and went to bed come back to nothing — exactly the workflow the tenet names as the promise being made.

This matters for two reasons. First, under *tenet cascade* — design nodes should lean the way the HLD's tenets say to lean — a conflict between a mechanism and a tenet is supposed to be visible, so a future agent reading the design knows the exception was deliberate and not a bug to fix. Right now, nothing in the design signals "this was a trade, and here's why." A future session touching the queue will re-encounter the same tension and might "fix" it without knowing the choice was already made. Second, under *decision capture* — a decision a cold reader would question should have a Decisions row — this gap means the reasoning lives only in whoever wrote the docs. Once that context is gone, the choice looks accidental.

The three remedies, and you'd pick one:

1. **Record the exception.** Add a Decisions row to `job-queue-design.md` naming tenet 1 as the tenet traded against and saying why the trade was accepted — probably something like "in-memory queue accepted cost: jobs lost on mini-PC restart; mitigated by cheap resubmit (files on disk under content hash) and restart frequency being low; SQLite persistence rejected to keep the service small per tenet 3." This closes both F2 and F3 in one row.

2. **Change the design.** If the trade doesn't sit right — if the promise feels load-bearing and the in-memory shortcut was more convenience than deliberate choice — consider persisting the queue (a small SQLite table alongside the registry would keep it consistent with tenet 3). Then the tenet conflict disappears and the decision row just records the storage choice.

3. **Revise the tenet.** If the service intentionally doesn't promise restart durability, consider narrowing tenet 1 — something like "a submitted job will run unattended *once dispatched*" — so it accurately describes the intent without implying a guarantee the architecture can't make.

Most projects in this position go with option 1: the in-memory choice is usually deliberate and reasonable for a small makerspace service, and a Decisions row is a five-minute edit that permanently closes the ambiguity. But if you're not sure the trade was really intentional, that's a signal option 2 is worth a second look before committing the exception to record.

To apply whichever you choose, edit `job-queue-design.md` directly — no special command needed. If revising tenet 1 feels right, that's an edit to `docs/high-level-design.md`.