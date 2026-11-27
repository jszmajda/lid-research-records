Looking at F2 in depth:

**The conflict:** Your Tenet 1 says *"A submitted job is a promise: members should be able to upload and walk away."* That reads to me like a commitment — members upload, the system accepts, and the job is held safely. But your job-queue design holds accepted jobs entirely in process memory. If the service crashes before dispatch, those jobs vanish and members have to resubmit.

**Why this matters:** This isn't a small gap. The tenet is about *trust* — members should feel confident uploading from home. The design creates a silent failure mode: they upload successfully, walk away, and the job silently disappears if there's a restart. They won't know until they check tomorrow morning. That's not a promise.

**How to resolve it — three real options:**

1. **Clarify the tenet.** Maybe the promise is narrower than it sounds: *"A submitted job is a promise within a session"* or *"Members can upload and walk away, but jobs may be lost if the service restarts — resubmission is quick."* This is honest, but changes what the system guarantees. Your makerspace members might accept this (it's still better than chat-based claiming), or it might feel inadequate once you're trying to replace the old workflow.

2. **Persist jobs to disk.** Write accepted jobs to a durable store (a file, a database row) before confirming upload. On restart, rebuild the queue from disk, not just from live printers. This makes the promise real but costs some complexity — you need crash-safe writes and recovery logic.

3. **Add a spec that documents restart behavior.** Keep the in-memory queue, but explicitly spec: *"When the service restarts, the system SHALL discard jobs accepted but not yet dispatched, and members SHALL resubmit them."* Make the tradeoff explicit in the code and tests, so future implementers understand why. This is valid if you decide the tenet's *real* intent is "smooth upload experience" not "durable job storage."

**My recommendation:** Before you implement, decide what you *actually* want members to feel when they upload. If it's "I can trust this will print tonight," you need option 2. If it's "This is better than Slack but might require a resubmit if something breaks," option 3 (with a clearer tenet) works.

Option 2 isn't prohibitive — a SQLite table for pending jobs (id, printer_class, g_code_hash, created_at) is simple and matches the storage you're already doing for G-code files. Recovery on startup is just a SELECT.

Which of these feels right for your project?