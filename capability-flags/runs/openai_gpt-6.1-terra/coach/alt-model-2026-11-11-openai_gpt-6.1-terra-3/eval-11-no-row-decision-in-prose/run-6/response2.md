**The durability conflict (F1).** The HLD says a submitted job is a promise: members should be able to upload and walk away. But `docs/intent/job-queue/job-queue-design.md` says accepted, undispatched jobs live only in memory and disappear on restart; keeping G-code files on disk doesn’t preserve the queue or its ordering. A routine overnight update could therefore leave a member expecting a morning print that was never dispatched. Under *tenet cascade*—design should follow the project’s stated priorities—this tradeoff needs an explicit decision.

**The missing rationale (F2).** The queue design doesn’t explain why restart loss is acceptable or what was traded away to get an in-memory queue. Under *decision capture*—record the reasoning behind choices a future reader might reasonably challenge—a short Decisions & Alternatives row would help future sessions understand the choice rather than rediscover it.

I recommend resolving the promise first, then walking the chosen change through `/linked-intent-dev`:

1. **Preserve accepted jobs across restarts:** persist their metadata and queue order, and define when an upload is considered accepted. This supports the current promise but adds storage and recovery work, including handling dispatches interrupted by a restart.
2. **Keep the in-memory design as an explicit exception:** retain the tenet but document the restart-loss tradeoff and why it is acceptable in the queue’s Decisions table. That also resolves the missing-rationale finding.
3. **Revise the tenet:** change the promise if resubmission after a restart is an intended part of the member experience, and capture the queue choice and its cost in the Decisions table.

Which of those best matches what you want members to be able to rely on?