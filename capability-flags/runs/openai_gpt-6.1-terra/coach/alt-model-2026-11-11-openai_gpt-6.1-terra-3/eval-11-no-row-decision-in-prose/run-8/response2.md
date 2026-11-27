**F1 — Accepted jobs can disappear on restart.** The HLD promises members can upload and walk away, and its goal is unattended overnight printing. But `docs/intent/job-queue/job-queue-design.md` says accepted jobs waiting in memory are lost on restart—even though it anticipates unattended updates and power blips. The files remain on disk, but the design says members must resubmit. This is a *tenet cascade* concern: the component’s behavior under an expected condition works against the project’s stated promise.

**F4 — The tradeoff isn’t captured.** The queue design does not explain why an in-memory queue was chosen over durable storage, or why losing accepted jobs is an acceptable cost. Under *decision capture*, a future reader should be able to understand a consequential choice and what was given up. A short Decisions & Alternatives row would usually be enough; it could record the chosen approach, the alternative, and the accepted cost.

I’d suggest choosing which promise the project wants to make:

1. **Change the design:** persist accepted jobs and their queue order, then restore them after restart. Specify how recovery distinguishes waiting jobs from jobs that may already be printing.
2. **Keep the in-memory design and record an exception:** explain in the queue’s Decisions table why simplicity outweighs the upload-and-walk-away promise, and make the loss and resubmission behavior explicit. This also closes F4.
3. **Revise the HLD promise or goal:** make clear that members may need to resubmit after a restart, then align the queue design and specs with that narrower intent.

Once you choose, the LID workflow can carry that decision through the design, EARS requirements, tests, and implementation. Which direction best matches what you want members to be able to rely on?