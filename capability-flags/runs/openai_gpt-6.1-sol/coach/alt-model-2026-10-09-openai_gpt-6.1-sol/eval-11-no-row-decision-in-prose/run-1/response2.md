The concern is **what “accepted” promises a member**. Your HLD says they should be able to upload and walk away; the queue design requires them to resubmit after a restart. Those differ under conditions the project explicitly expects.

### F1 — The design conflicts with the submission promise

In `docs/intent/job-queue/job-queue-design.md:10–14`, the mini-PC takes unattended OS updates and occasional power blips, while accepted jobs remain entirely in memory. Imagine a member uploads at 9 p.m., the service restarts before their printer becomes free, and they return in the morning: their queued job has disappeared. Keeping the G-code on disk makes resubmission cheaper, but does not preserve the job’s place, ownership, or dispatch intent. Under *tenet cascade*—downstream designs should uphold the HLD’s stated preferences—this mechanism works against “upload and walk away” and overnight pickup. I’d recommend explicitly resolving that promise before developing the queue further.

### F2 — The tradeoff needs a recorded rationale

The queue’s Decisions & Alternatives table explains scheduling and identifiers, but not why accepted jobs are disposable. Under *docs carry current intent*—a cold reader should understand consequential choices without the original conversation—a future implementer cannot tell whether this is an intentional simplicity tradeoff or an oversight. The registry already uses SQLite, so that reader has a credible reason to question the choice. Record the resolution in a queue Decisions row, naming the alternative and accepted cost; a standalone decision document seems unnecessary here.

### What I’d recommend doing next

Choose which of these reflects your intended service:

- **Change the design to preserve the promise.** Make accepted jobs durable before acknowledging acceptance. SQLite is a candidate given your existing registry design. The cost is transaction and recovery logic, including reconciling persisted jobs with printers after restart.
- **Keep the design and record an explicit exception.** State why simplicity outweighs restart survival, name the “upload and walk away” tenet being traded against, and make that limitation visible to members. This would also close F2’s missing-rationale finding, though the reliability compromise remains.
- **Revise the HLD promise.** If this is intentionally a best-effort queue, say so in the tenet and goals, then align acceptance messages and recovery behavior with that narrower promise.

If you choose durability, the next design discussion should cover two distinct situations: a job still waiting when the service restarts, and a job sent to a printer whose acknowledgement was lost. Preserving the waiting queue solves the first; blindly retrying an uncertain dispatch could print the second twice. Then use `/linked-intent-dev` to carry the reviewed design through EARS, restart/recovery tests, and implementation.

**Which promise do you want acceptance to mean: the service retains the job across restarts, or members may need to resubmit?**