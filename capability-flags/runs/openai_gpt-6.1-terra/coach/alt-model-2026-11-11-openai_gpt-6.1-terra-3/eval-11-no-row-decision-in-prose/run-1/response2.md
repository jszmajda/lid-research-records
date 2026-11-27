**The conflict.** The HLD says a submitted job is a promise: members should be able to upload and walk away. But `docs/intent/job-queue/job-queue-design.md` says accepted, undispatched jobs disappear on restart and members must resubmit them. The same design anticipates unattended OS updates and power blips. Under *tenet cascade*—downstream design should honor the project’s stated preferences—that means an evening upload can be lost precisely when no member is present to notice. The team should decide explicitly what acceptance promises across a restart.

**The missing rationale.** The queue design has no Decisions & Alternatives row explaining why it keeps accepted jobs only in memory or what cost that choice accepts. Under *decision capture*—preserve the reasoning behind choices a future reader might reasonably question—that leaves the durability trade-off to be rediscovered. A concise row naming the alternative and accepted cost would capture the decision; if you choose to retain the current behavior as an exception, the row should also name the tenet or goal being traded away.

There are three reasonable directions to consider:

- **Change the design:** persist accepted jobs and their queue order, then define recovery and dispatch behavior after restart. SQLite is one possible fit alongside the registry’s existing store; recovery would still need to address jobs whose dispatch outcome was uncertain at shutdown.
- **Keep the current design as an exception:** record why simplicity outweighs losing queued jobs, and make that limitation clear to members.
- **Revise the promise:** change the HLD tenet or goal if reliable unattended submission is not actually required.

Once you choose, I’d use `/linked-intent-dev` to carry that decision through the affected design, specs, tests, and implementation, with review at the workflow’s phase stops. Which promise do you want acceptance to make?