**F1 — Accepted jobs can disappear.** The HLD promises that members can upload and walk away, aiming for an overnight print. But `docs/intent/job-queue/job-queue-design.md:14` says that jobs waiting in memory are lost on restart and members must resubmit them. The same document anticipates unattended OS updates and power blips, so a member could reasonably return in the morning to find that an accepted job never printed. This is a *tenet cascade* issue: downstream design should honor the priorities set in the HLD, or make the tradeoff explicit.

**F2 — The tradeoff isn’t captured.** The queue design states the in-memory choice but doesn’t explain why losing accepted jobs is preferable to a durable queue. Under *decision capture*—recording the reasoning behind choices a future reader might question—a reader needs to understand the alternative and accepted cost before relying on or revisiting it. A concise Decisions & Alternatives row would usually be enough; if you retain the current design, it should also name the upload-and-walk-away promise being traded against.

**F5 — The recovery behavior isn’t specified.** The queue specs cover polling printers at startup, but they don’t say what happens to accepted jobs that were still waiting. Under *coherence is adjacency*, the design and its testable requirements should agree; otherwise, startup tests could pass while missing the loss of queued work.

There are three ways to resolve the conflict, depending on your intent:

1. **Change the design:** Persist accepted jobs and their queue order so waiting jobs survive restarts. The existing SQLite approach is one possible starting point; recovery and interrupted dispatch would need explicit design and specs.
2. **Keep the in-memory queue:** Record the exception and its rationale, then specify the loss and any member-facing recovery behavior.
3. **Revise the HLD promise:** If resubmission after a restart is acceptable, adjust the tenet and goal to reflect that expectation, and specify the resulting behavior.

Which direction matches what you want members to be able to rely on?