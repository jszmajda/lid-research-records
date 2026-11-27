Good catch — that in-memory storage is actually a perfect example of **decision capture** (dimension 18 of the coach's principles). Let me walk you through what I'm seeing and why it matters.

## What's happening

In the job-queue design doc, you state cleanly: *"The queue is a per-printer-class list of accepted jobs held entirely in process memory."* You go on to say that on restart, undipatched jobs are lost and members resubmit them.

This is a real architectural choice — in-memory storage vs. persisting the queue to disk — and it has consequences. But right now it lives only in the architectural prose of the LLD. It's not in your Decisions & Alternatives table, and there's no spec binding the implementation to this behavior.

## Why this matters

Here's the tension: your HLD has a tenet that says *"A submitted job is a promise: members should be able to upload and walk away."* The in-memory queue design undercuts that promise — if the service crashes before dispatch, the job vanishes. Members get a surprise resubmit requirement.

That's not necessarily wrong. Accepting loss on restart might be a deliberate trade-off: simpler code, lower memory footprint, acceptable for a modest mini-PC with unattended OS updates. But if that's the choice, it needs to be *recorded* so a future session (or someone reviewing the code) can tell whether losing jobs on restart is:

- A foundational constraint you've accepted ("this is how it works"),
- A temporary shortcut until persistence is added later, or  
- An accident that happened because nobody wrote down the intent.

Right now, it reads like the third — architectural prose that slipped out of the decision flow.

## What I'd recommend

**Short term:** Add a row to the Decisions & Alternatives table in job-queue-design.md. Something like:

| Decision | Chosen | Rationale |
|---|---|---|
| Queue persistence | In-memory only; resubmit on restart | Simpler code and smaller footprint for modest hardware; acceptable loss window because uploads are quick and staff can requeue priority jobs |

Or if you want to be more explicit about the tenet trade-off:

| Decision | Chosen | Rationale |
|---|---|---|
| Queue persistence on crash | Accepted loss; members resubmit | Trades against "job is a promise" tenet in favor of code simplicity and mini-PC resource constraints; restart window is rare (unattended updates); cost is resubmission, which is fast |

This grounds the choice. It also surfaces the tenet tension for anyone reading it later — they see that you made a deliberate call, not an accidental omission.

**Longer term:** Once you're implementing, consider adding a spec to cover restart recovery. Something like:

- **QUEUE-XXX**: When the service restarts, it SHALL rebuild its queue picture by polling each registered printer for the job currently running, and members SHALL resubmit jobs accepted but not yet dispatched.

This binds the behavior to a testable spec, so the implementation doesn't accidentally drift to persistence without updating the decision.

**Also consider:** Does the loss of undipatched jobs create any security or safety issues? (For example, a member uploads, power failure before dispatch — the job is gone. They reupload. Now there's a second identical G-code on disk. Your design handles this with the content hash, which is good. But it's worth noting that restart recovery is a spec-level concern, not just an implementation detail.)

Does this framing help? Would you like to dig into any of the other findings, or shall we talk about how these pieces fit together?