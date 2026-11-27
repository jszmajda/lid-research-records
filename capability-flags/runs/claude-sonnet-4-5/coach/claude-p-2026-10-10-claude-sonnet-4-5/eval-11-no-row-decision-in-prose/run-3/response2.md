**F1 — High. The job-queue design contradicts tenet 1 without recording the trade.**

Your HLD says "A submitted job is a promise: members should be able to upload and walk away," but `docs/intent/job-queue/job-queue-design.md` says the queue is "held entirely in process memory" and "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them." The Context section notes the mini-PC "takes unattended OS updates and the occasional power blip" — so restarts happen, and when they do, the promise breaks. This violates *tenet cascade* — the principle that designs should lean the way the HLD's tenets say to lean, and when they can't, the exception must be recorded.

Why this matters: a future session reading the tenet and the design sees a contradiction, not a deliberate choice. The agent can't tell whether the in-memory queue is a bug (forgot about the tenet), an accident (didn't realize restarts would break promises), or a considered trade (chose simplicity over durability). That ambiguity costs tokens every session — the agent has to ask, or worse, guess wrong and "fix" something that was already decided. Your design does mitigate (files persist by content hash, so resubmit is cheap), but that mitigation reads like a performance optimization, not the load-bearing piece that makes the broken promise tolerable.

You have three remedies, your choice:

1. **Change the design.** Persist the queue to disk (append-only log, SQLite, whatever fits the mini-PC) so accepted jobs survive restarts. The tenet is satisfied, the trade disappears. Cost: more complexity, and you're explicitly trying to keep the service small (tenet 3).

2. **Record the exception.** Add a row to the job-queue Decisions & Alternatives table: "Queue durability" / "Ephemeral (in-memory only)" / "Rejected persistent queue for simplicity (tenet 3); accepted cost: job lost on restart, member resubmits; mitigated by content-hash dedup making resubmit cheap. Tenet 1 (promise) is weakened to 'promise unless restart.'" The design stays as-is; the record shows it's a choice, not an oversight.

3. **Revise the tenet.** Weaken tenet 1 to say "A submitted job is a promise *the service keeps while running*" or similar, acknowledging that restarts are out of scope. The tenet now matches what the design delivers. Cost: the tenet becomes less ambitious, and you lose the forcing function that might have pushed you toward a more durable design.

Option 2 (record the exception) is usually the fastest close when the design is otherwise working and you're not ready to commit implementation time. The Decisions row takes 30 seconds to write and makes the choice legible forever. If you pick that, the row would live in `docs/intent/job-queue/job-queue-design.md` in the existing Decisions & Alternatives table, probably as the first row since it's the most foundational trade in the component.

Which direction feels right for your project?