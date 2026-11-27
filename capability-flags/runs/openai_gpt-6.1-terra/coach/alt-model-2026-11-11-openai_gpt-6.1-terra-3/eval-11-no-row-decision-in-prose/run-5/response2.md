**F1 — The restart behavior conflicts with the project’s promise.** The HLD says a submitted job is a promise and sets a goal of unattended overnight printing. But `docs/intent/job-queue/job-queue-design.md:14` says accepted, undispatched jobs disappear on restart—even though the design anticipates unattended updates and power blips. Keeping the G-code on disk makes resubmission cheaper, but it does not preserve the accepted job or its queue position. Under *tenet cascade*—downstream design should honor the project’s stated preferences—this tradeoff needs a deliberate decision.

**F2 — The tradeoff is not captured.** The queue design’s Decisions & Alternatives table does not explain why in-memory storage was chosen over durable accepted jobs, or why losing those jobs is acceptable. Under *docs carry current intent*—a future reader should understand consequential choices without the original conversation—that rationale matters because an implementer cannot tell whether the loss is intentional or an oversight.

You have three routes to consider:

1. **Change the design:** persist accepted jobs and restore the queue after restart. Define when an upload counts as accepted and how recovery handles jobs that were being dispatched.
2. **Keep the design and record the exception:** add a Decisions row naming the submitted-job promise and overnight goal being traded against, the reason, and the accepted loss. This also closes the decision-capture finding.
3. **Revise the HLD:** change the promise or goal if reliable survival across restarts is not actually intended.

Once you choose, walk that intent through the affected design and EARS specs, then tests and code. Which route reflects what you want members to be able to expect?