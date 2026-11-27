I need to correct something — I actually *missed* a significant finding in my initial review. Let me walk through what I should have caught.

## The in-memory queue contradicts the promise tenet

**The mechanism:** The job-queue design holds accepted jobs entirely in process memory. On restart, those jobs are gone. The design acknowledges this: "jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them."

**The tenet it contradicts:** Your HLD's first tenet says "A submitted job is a promise: members should be able to upload and walk away."

**The operating condition where they clash:** The job-queue context explicitly mentions "the workshop mini-PC, which takes unattended OS updates and the occasional power blip." So restarts aren't edge cases — they're described operating conditions.

**The scenario:** Member uploads a job at 10pm Tuesday, heads home expecting to pick up their part Wednesday morning. At 3am the mini-PC takes an OS update and restarts. The service comes back up, but the accepted job is gone. The G-code file is still on disk (kept by content hash), but the queue position and the fact that this member submitted it are lost. Wednesday morning the member arrives to find nothing printed. They have to notice what happened, resubmit, and wait another cycle.

That's not "upload and walk away" — it's "upload and hope there's no restart, or watch for restarts and resubmit."

**Why this matters beyond this one choice:** This is a *tenet cascade* issue. Tenets exist to guide exactly these choices — the decisions specs don't pre-settle. When a design mechanism works against a tenet under described operating conditions, and the Decisions & Alternatives table doesn't record the exception (naming the tenet, explaining why it was traded, what was gained), future sessions can't tell whether:
- The contradiction is intentional and accepted (you chose simplicity over the promise), or  
- It's unintentional drift (the design didn't notice the clash)

Either one is a valid choice, but only the first one is *documented intent*. Undocumented trades compound over time — each new design decision has to re-derive whether this tenet still holds or was quietly set aside.

## What I'd recommend

You have three paths, and which one fits depends on what you actually want the system to promise:

**Option 1: Honor the tenet — persist accepted jobs**

Persist the queue alongside the uploaded G-code. Could be as simple as a second SQLite table (you're already running SQLite for the registry), or append-only log of queue mutations. On restart, rebuild the queue from disk rather than discarding it.

*When this fits:* If "upload and walk away" is the user experience you want to deliver — the promise tenet was chosen deliberately and the system should live up to it even across restarts.

*Cost:* More complexity (persistence logic, replay-on-restart), slightly slower queue mutations if you're doing synchronous writes. The mini-PC context ("modest hardware; the service stays small") might push back on this, but a second SQLite table is still pretty small.

*What to document:* Add a Decisions row: "Queue persistence → SQLite table → honors promise tenet across restarts; in-memory-only rejected because restart would lose accepted jobs and force resubmission (contradicts 'upload and walk away')."

**Option 2: Weaken the tenet — make the promise conditional**

Revise the tenet to match what the in-memory design actually delivers. Something like: "A submitted job is a promise *once dispatched*: members should be able to walk away after dispatch begins."

*When this fits:* If the real promise is "once your job is on a printer, we'll see it through," and you're okay with pre-dispatch jobs being lost on restart. The upload-from-home-at-night scenario becomes "upload, check the queue in the morning to confirm it's still there or dispatched, then walk away."

*Cost:* Changes the user contract. Members can't fully walk away at upload time — they have to check back. In practice, given "unattended OS updates" can happen overnight, this might mean jobs uploaded in the evening need a morning confirmation.

*What to document:* Revise the HLD tenet, and add a Decisions row in the job-queue LLD: "Queue persistence → in-memory only → simpler implementation; accepted cost: jobs lost on restart before dispatch (members resubmit), which narrows the promise tenet to post-dispatch."

**Option 3: Keep the tenet, accept the gap, document the trade**

Keep the tenet as-is (aspirational), keep the in-memory design, but explicitly document that the current implementation doesn't fully honor the tenet yet, and why you're deferring persistence.

*When this fits:* Early implementation when you want to get the core dispatch loop working first, with persistence as a near-term follow-up. Or if restarts are rare enough in practice that the gap is tolerable for an MVP.

*Cost:* The system doesn't deliver what the tenet promises. Fine for a bootstrap phase, but needs to be visible so it doesn't accidentally become permanent.

*What to document:* Add a Decisions row: "Queue persistence → deferred (in-memory only for MVP) → accepted gap: restart loses accepted jobs, contradicts promise tenet; persistence tracked as follow-up work."

## My recommendation

If I had to choose for you, I'd go with **Option 1** — persist the queue. Here's why:

- Your tenet is specific and user-facing ("upload and walk away"). That specificity suggests it was chosen deliberately, not as a platitude.
- Your context explicitly mentions restarts as normal (OS updates, power blips), so the contradiction isn't theoretical.
- You're already running SQLite for the registry. A second table for queue state is not a big leap in complexity, and it's well within "modest hardware."
- The G-code is already on disk by content hash, so you've already accepted some persistence complexity. Adding queue state keeps the persistence model consistent.

But you know your constraints better than I do. If the modest-hardware tenet actually dominates, or if you're bootstrapping and need the simplest possible dispatch loop first, Option 2 or 3 might fit better.

Whichever you choose, the key is: **put the choice in the Decisions & Alternatives table**, naming the tenet and the tradeoff. That's what makes it navigable in six months when someone (maybe you, maybe an agent) is trying to understand why the queue works this way.