**F1 (high). The queue lives only in process memory, which works against the HLD's first tenet.**

The job-queue LLD's Architecture section says accepted jobs are "held entirely in process memory" and that, after a restart, jobs "accepted but not yet dispatched… are gone, and members resubmit them." QUEUE-004 specifies the rebuild-by-polling behavior, so the loss is encoded in the specs as well.

The same LLD's Context says the service runs on a mini-PC that "takes unattended OS updates and the occasional power blip." Those are exactly the overnight conditions the HLD's goal describes ("evening upload, overnight print, morning pickup — with no member present"). The HLD's first tenet is "a submitted job is a promise: members should be able to upload and walk away."

Under *tenets capture forward-looking preference* (a tenet is a tie-breaker that should steer leaf designs), the two don't conflict in wording, but they do under the operating condition the LLD describes. A member uploads at 9pm and goes home. The box reboots for an update at 3am, and the job is silently gone by morning with nobody present to resubmit. The tenet is defeated in the exact scenario the goal is built around.

The remedy is the user's choice, and I'd lay out the three options without picking for you:

1. **Change the design.** Persist accepted jobs so they survive a restart. The registry already uses a single SQLite file, and G-code files already sit on disk under a content hash, so the project has a natural place to keep them. QUEUE-004 would then rebuild from stored jobs plus printer polling, and you would add a spec such as "when the service restarts, the system SHALL retain every accepted, undispatched job."
2. **Record the exception.** If volatility is deliberate, add a Decisions row naming the tenet traded against (the promise tenet, in favor of "the service stays small") and why. For example, restarts might be rare enough, or resubmission cheap enough, given content-hash dedup. A cold reader should then be able to see that it was a choice and what it costs.
3. **Revise the tenet.** If the real intent is "best effort until restart," the tenet should say so, and the "no member present" goal should be softened to match.

**F2 (high). The same choice has no Decisions row at all.**

The LLD records smaller choices (slug format, 64 MB limit) with rejected alternatives and accepted costs, but not the choice to hold the queue in memory. Judged forward from the landed design, a cold reader would question this choice and be tempted to reverse it, so the reasoning needs to be on the page. That is the *docs carry current intent* test: what a fresh author would write, including rationale, belongs in the table.

A fuller row is the right size here. A decision doc isn't warranted, because nothing indicates a researched debate on the record.

**What I'd recommend**

These two findings are best resolved together, in the leaf LLD (`docs/intent/job-queue/job-queue-design.md`).

- Decide between options 1 and 3 above, or option 2 if you want to keep the design as is. Option 2 closes F2 on its own, since the row is the exception record.
- Whichever you pick, add a Decisions row. For the persistence option, it could read: *Queue storage — Persisted … | In-memory rejected: loses accepted jobs on unattended reboots, defeating "upload and walk away"; accepted cost: …*
- If the design changes, cascade within the segment: the LLD Architecture text, QUEUE-004 and a new retention spec, then tests.

If you tell me which direction you lean, I can help you work through the wording of the row, the spec, or the tenet.