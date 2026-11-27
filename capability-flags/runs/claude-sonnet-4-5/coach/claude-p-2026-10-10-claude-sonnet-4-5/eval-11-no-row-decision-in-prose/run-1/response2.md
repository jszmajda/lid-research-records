Good catch — I should have flagged this in the initial review. Let me walk through what I'm seeing.

**The in-memory queue contradicts the first tenet.** The HLD says "a submitted job is a promise: members should be able to upload and walk away." But the job-queue LLD holds accepted jobs entirely in process memory and explicitly states that "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them." Under the operating condition the docs themselves describe — the mini-PC takes "unattended OS updates and the occasional power blip" — a member who uploads in the evening and walks away may find their job lost by morning, with no notification. That breaks the promise.

This relates to **tenet cascade** — the principle that design nodes should lean the way the HLD's tenets say to lean. When a mechanism works against a stated tenet under conditions the design acknowledges, and there's no Decisions row or decision doc recording the exception (naming the tenet traded against, and why), that's drift: the project declared one preference but implemented another, silently.

**Why this matters:** Future sessions reading the HLD will expect jobs to survive restarts — the tenet says so — and may add features (notifications, retry logic, SLAs) assuming that promise holds. When they discover the queue is volatile, they'll either (a) question whether the tenet is real, (b) assume the design is wrong and rewrite it, or (c) propagate the contradiction downstream. The ambiguity compounds because there's no record of the tradeoff, so every agent re-discovers it and guesses which one to trust.

**What to do:** You have three options, and which one fits depends on what you actually want:

1. **Change the design** — persist accepted jobs so they survive restarts. The LLD already stores G-code on disk by content hash; adding a thin job-metadata store (SQLite, like the registry uses) would close the gap. Members upload, walk away, and the job survives a blip.

2. **Record the exception** — add a Decisions & Alternatives row in the job-queue LLD that names the in-memory choice, acknowledges it trades against the "job is a promise" tenet, explains what you get in return (simplicity, no DB writes on every enqueue), and states the accepted cost (jobs lost on restart; members resubmit). This makes the tradeoff visible and intentional rather than silent drift.

3. **Revise the tenet** — if "upload and walk away" was aspirational but the real constraint is "keep the service small," soften the tenet to match what you're willing to deliver: "members should usually be able to upload and walk away; rare restarts may lose queued jobs."

Option 2 is the lightest fix if the tradeoff is deliberate — one table row closes the gap. If the contradiction wasn't intentional, option 1 makes the design match the tenet. Option 3 is rare (tenets are load-bearing) but valid if the tenet overstated the commitment.

Does one of those fit what you had in mind, or is the in-memory choice itself still up for debate?