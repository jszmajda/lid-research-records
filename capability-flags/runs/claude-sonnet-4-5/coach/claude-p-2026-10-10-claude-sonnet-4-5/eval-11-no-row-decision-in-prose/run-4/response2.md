I'll walk through the tension between your tenet and the current architecture, why it matters, and the tradeoff space.

## The Contradiction

Your HLD declares: **"A submitted job is a promise: members should be able to upload and walk away."**

Your job-queue LLD says: **"On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them."**

These directly conflict. The tenet says the system owns the job once accepted; the architecture says it doesn't survive a restart.

## Why This Matters

This isn't just documentation drift — it's a **decision-ambiguity trap** for future implementation sessions.

When an agent reads the HLD and reaches the tenet, it learns: *once we accept an upload, the member is done — we owe them the print.* That's a strong contract. It shapes downstream choices: error handling (retry until success), user messaging (confirmation means "we've got it"), and operational expectations (members check the pickup shelf, not the queue status).

But when that same agent reads the LLD's architecture, it learns: *accepted jobs live in process memory and vanish on restart.* That's a **different contract** — closer to "best effort given our constraints."

The problem compounds in two ways:

1. **Inconsistent agent behavior across sessions.** One session leans on the tenet and adds retry logic to satisfy the promise; another session reads the LLD's restart behavior and assumes members already expect resubmission. The codebase drifts depending on which doc was loaded first.

2. **User-experience confusion.** If the UI tells members "your job is queued" (satisfying the tenet), but a power blip makes them resubmit (obeying the LLD), members lose trust in the system. The tenet created an expectation the architecture can't meet.

The HLD's tenets are meant to be the **tie-breaker** when a future decision has two defensible answers. But a tenet that contradicts the architecture isn't a tie-breaker — it's noise. Worse, it's **actively misleading** noise, because an agent trying to respect it will design things the rest of the system doesn't support.

## The Tradeoff Space

You have three directions, each with a different cost:

### Option 1: Persist Accepted Jobs

Make the architecture satisfy the tenet — write accepted jobs to disk (alongside their G-code files, which you're already storing by content hash) so restarts don't lose them.

**What this looks like:**
- Add a lightweight append-log (could be as simple as newline-delimited JSON) recording `(job_id, printer_class, member_id, gcode_hash, timestamp)` for each accepted job
- On startup, replay the log to rebuild the in-memory queues (you're already polling printers to see what's running; cross those off during replay)
- The G-code files are already persistent, so this just adds the queue state

**Cost:** A bit more complexity — you now have two persistent things (G-code files + queue log), and you need replay logic. But the complexity is **bounded**: append-only writes, sequential replay, no concurrent access (the service is single-process). This fits your tenet 3 ("the mini-PC is modest hardware; the service stays small") without much strain.

**Benefit:** The tenet becomes **true**. Members upload and genuinely walk away. The overnight-print workflow (your HLD Goal: "Evening upload, overnight print, morning pickup") survives a 2am OS update or power blip. The system's contract with members is the one the tenet declared.

### Option 2: Revise the Tenet to Own the Limitation

Weaken the tenet to match what the architecture actually delivers.

**What this looks like:**
- Change the tenet from *"A submitted job is a promise"* to something like *"A submitted job is accepted promptly, but members check status after unplanned restarts"* or *"The service accepts jobs as a best-effort queue given single-service constraints."*

**Cost:** You lose the clarity of the original tenet. "Best effort" is a hedge, not a decision lens. When a future session is designing error handling or user messaging and asks *"how reliable should this feel to members?"*, the weakened tenet doesn't answer — it just reflects the ambiguity back.

**Benefit:** The docs are now **internally coherent**. An agent reading them won't encounter contradiction. But coherence without a strong tenet means the tenet stops doing the work tenets are supposed to do — **pre-narrowing future decisions** toward a declared preference.

### Option 3: Drop the Tenet Entirely

If resubmission after restarts is actually fine for your members, the tenet might be aspirational rather than load-bearing. Delete it.

**What this looks like:**
- Remove the tenet from the HLD
- Possibly add context in the job-queue LLD explaining the resubmission expectation (e.g., "Members are expected to monitor the queue web UI; accepted jobs lost to service restarts require resubmission")

**Cost:** You lose a **design anchor**. The tenet wasn't decorative — it was trying to say something about the user experience you wanted ("upload and walk away" is a specific, member-friendly posture). Dropping it entirely leaves a gap: what *is* the service's reliability contract with members? If you don't state it, future sessions guess.

**Benefit:** No contradiction, no added complexity. The architecture is what it is, and you're not pretending otherwise.

## My Recommendation

**Go with Option 1: persist accepted jobs.**

Here's why:

1. **The tenet is doing real work.** "Upload and walk away" is a meaningful user-experience goal that differentiates this system from "members babysit the queue." It's not a platitude — it's a choice about what kind of service the makerspace runs.

2. **The complexity cost is modest.** You're already persisting G-code by content hash. Adding a newline-delimited log of accepted jobs is ~20 lines of append + replay logic — well within "the service stays small" (tenet 3).

3. **The architecture otherwise leans toward reliability.** You're already handling dispatch retries (QUEUE-003: failed dispatch returns job to head of queue), marking suspect printers, and rebuilding farm state on startup. Losing accepted jobs on restart is the **one gap** in an otherwise careful design. Closing it makes the whole arrow coherent.

4. **Your HLD Goal depends on it.** "Evening upload, overnight print, morning pickup — with no member present" assumes the job survives overnight. If the mini-PC takes an OS update at 3am and drops the queue, members arrive to find nothing printed and no way to know their job was lost. Persistence makes the goal real.

The revision would be small — add one line to the job-queue LLD's §Architecture:

> "Accepted jobs are persisted to a newline-delimited log on disk; on startup the service replays this log to rebuild the in-memory queues, then polls printers to remove jobs already running."

Then add a spec (something like **QUEUE-006**: "When the service starts, the system SHALL replay the accepted-job log to restore queued jobs not yet dispatched"). The tenet stays as-is, and the architecture now supports it.

---

Does this tradeoff framing make sense? Want to talk through any of the other options, or should we look at a different finding?