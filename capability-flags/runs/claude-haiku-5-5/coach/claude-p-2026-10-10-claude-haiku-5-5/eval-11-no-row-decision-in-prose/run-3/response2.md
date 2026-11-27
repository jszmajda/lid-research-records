The job-queue design keeps accepted jobs only in process memory. On restart, any job that was accepted but not yet dispatched is gone, and members have to resubmit it. The design states this in its Architecture paragraph, so the loss isn't hidden. The problem is that nothing else in the docs accounts for it.

**What the docs say**

- The HLD tenet reads: "A submitted job is a promise: members should be able to upload and walk away." The goal reads: "Evening upload, overnight print, morning pickup, with no member present."
- The queue's own Context says the mini-PC "takes unattended OS updates and the occasional power blip," and that jobs dispatch overnight.
- So the failure case is described in the design itself. A restart during the evening-to-morning window drops jobs that members expect to collect, with nobody there to notice.
- The Decisions table has no row for the in-memory choice. The registry, in the same project, uses a single SQLite file, and its rationale is "Fits the mini-PC." A cold reader would immediately ask why the queue doesn't use the same store.
- No spec covers the loss either way. QUEUE-004 only covers rebuilding farm state from printers. So nothing would catch a regression in either direction.

**Findings this maps to**

- **F3 (high), tenet conflict:** The in-memory design works against the promise tenet and the overnight goal under a condition the design itself describes. The tenet has no recorded exception.
- **F4 (medium), decision capture:** The choice is live, since a reader would question it, but it has no row recording the alternative, the rationale, or the cost accepted.
- **F5 (high), spec gap:** Accepting jobs and keeping them is unspecified, so the intent exists only in prose.

**What I'd recommend**

1. **Decide which way the tenet goes.** This is the real choice, and it's yours to make. There are two honest options:
   - **Persist accepted jobs** (my recommendation). Store them in a SQLite table next to the registry's file. That keeps the promise tenet and the overnight goal intact. The cost is a write path and a recovery step on startup. It also cuts against the "service stays small" tenet, but the registry already brings SQLite into the stack, so the added weight is modest.
   - **Keep the queue in memory** and rewrite the promise. The tenet would have to say what is not promised, for example that a restart can drop jobs and members are told when that happens. The queue view could surface lost jobs on startup. This is cheaper, but the "walk away" promise no longer holds as written.
2. **Record the decision in the Decisions table.** Whichever option you choose, add a row naming the alternative, the rationale, and the accepted cost. If the in-memory option is kept, name the tenet it trades against, so the exception is on the record.
3. **Add a spec that matches the decision.** For example, if you persist: "When the service restarts, the system SHALL retain every accepted job not yet dispatched." If you keep memory: "When the service restarts, the system SHALL notify staff of any jobs lost." Either way, a test can then cite it.
4. **If you persist, check the slug rule.** Job slugs recycle after 90 days. Persisted jobs survive restarts, so a recycled slug could collide with a job that is still waiting. Worth deciding how identity works before writing the schema.

I haven't changed any files. The coach is advisory, so these are for you to apply. If you tell me which option you prefer, I can draft the Decisions row and the spec for you to review.