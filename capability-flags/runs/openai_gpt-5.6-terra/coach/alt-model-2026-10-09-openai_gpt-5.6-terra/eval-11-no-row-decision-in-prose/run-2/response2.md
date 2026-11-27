`docs/intent/job-queue/job-queue-design.md:14` makes the queue deliberately ephemeral: accepted jobs live only in process memory, so a restart retains only whatever the printers report as currently running. Any accepted but undispatched job disappears, and the member must resubmit it.

That is a legitimate simplicity tradeoff for a small mini-PC, but it conflicts with the HLD's explicit intent. `docs/high-level-design.md:20` calls a submitted job “a promise,” and its primary goal is unattended evening upload and overnight printing. A routine OS update or power blip is specifically named in the queue context (`job-queue-design.md:10`), so loss during restart is a normal operating condition rather than an exceptional edge case. For a member, “upload and walk away” becomes “upload, then check whether the service restarted.”

This is a *tenet cascade* concern: leaf design should carry out the HLD's stated preferences unless the project consciously accepts an exception. It is also under-captured as a decision: the design states the consequence, but the Decisions & Alternatives table does not say why volatile queue state is worth trading against the submission promise, what alternative was rejected, or what operating cost the project accepts.

I would not choose the remedy for you. There are three coherent directions:

1. **Change the queue design.** Persist accepted jobs and their ordering in the same SQLite file already used by the registry, with the on-disk G-code content addressed by its existing hash. On restart, recover queued jobs, reconcile dispatched jobs against printer status, and avoid redispatching a job already known to be running. This best fulfills the promise tenet, at the cost of recovery-state design and transactional boundaries.

2. **Keep in-memory jobs, but record the exception.** Add a Decisions & Alternatives row that explicitly names the traded tenet or goal, explains why a persistent queue was rejected, and states the accepted member impact. This also resolves the decision-capture gap, but it should be a deliberate product/service policy rather than an accidental limitation.

3. **Revise the HLD tenet.** If “upload and walk away” was intended only while the service remains up, narrow the promise accordingly. This is clearest only if that weaker reliability expectation is truly acceptable to members.

If you choose persistence, the next LID change should begin with `/linked-intent-dev` and carry the decision through the queue LLD, recovery and durability EARS requirements, recovery tests, and implementation.