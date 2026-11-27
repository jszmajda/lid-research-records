**F1 — The restart behavior conflicts with the project’s promise.** The HLD says a submitted job is a promise that members can upload and walk away; it also sets a goal of overnight printing. But `docs/intent/job-queue/job-queue-design.md` says accepted, undispatched jobs disappear on restart and members must resubmit them. That matters because the same design expects unattended OS updates and power blips: a member could wake up to a job that was accepted but never printed. Under *tenet cascade*—downstream designs should honor stated project preferences—this tradeoff needs an explicit choice.

**F2 — The tradeoff is not recorded.** The queue design explains the in-memory behavior but its Decisions & Alternatives table does not say why losing accepted jobs is preferable to persisting them. Under *decision capture*—record the reasoning behind choices a future reader might question—a short table row would make the accepted cost and rejected alternative clear. It would also help a future maintainer distinguish deliberate intent from an omission.

You have three reasonable directions:

1. **Change the design** so accepted waiting jobs survive restarts. This supports the current promise, but needs a defined recovery and dispatch approach.
2. **Keep the in-memory queue and record an exception** in the queue’s Decisions table, naming the promise or goal traded against and why. This also resolves the decision-capture finding.
3. **Revise the HLD promise or goal** if resubmission after a restart is acceptable for this service, then align the downstream design and specs with that choice.

Which direction reflects what you want an accepted job to mean? Once you choose, we can walk the change through the relevant design, specs, and tests.