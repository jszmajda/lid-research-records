**F1 — High. The in-memory queue works against the HLD's first tenet and its goal.**

`docs/intent/job-queue/job-queue-design.md` (Architecture) holds the queue "entirely in process memory". It says jobs accepted but not yet dispatched before a restart "are gone, and members resubmit them". The same doc's Context says the mini-PC "takes unattended OS updates and the occasional power blip".

Set that against the HLD: the first tenet says "A submitted job is a promise: members should be able to upload and walk away". The first goal is "Evening upload, overnight print, morning pickup — with no member present".

The two don't share wording, so the conflict is easy to miss. Under conditions the docs themselves describe, though, the mechanism defeats both. A member uploads at 9pm and leaves. An unattended update reboots the box at 2am. The queue is empty by morning and there is no part to collect. The member has no way of knowing until they come back, and the resubmit requirement assumes they are present.

This is the *tenet cascade* lens: do the design nodes lean the way the HLD's tenets say to lean? When they don't, and nothing records the exception, the next session reads the leaf design and treats the loss as intended.

There is a point in the design's favor. The third tenet, "the service stays small", plausibly motivated the in-memory choice. That is a tension inside the HLD, which only works if someone chose it knowingly. Nothing on the page says so.

**F2 — Medium. The choice has no Decisions & Alternatives row.**

The table covers scheduling order, job identifiers and upload size, but not queue durability. A cold reader would likely question or try to reverse this choice, because the registry two docs over persists its state to SQLite. They would have no way to reconstruct what was given up or why.

Under *docs carry current intent* (a decision that stays live should be on the page), this is a capture gap. It is also a separate entry from F1, because F1 is about the design itself. Even if the in-memory design is right, it needs a row.

### What you could do

These are your choices, and I'd rather not pick one for you. Each is a legitimate answer.

1. **Change the design.** Persist accepted jobs, for example in the same SQLite file the registry already uses, and rebuild the queue from it on startup. This honors the tenet and the goal. It costs a small amount of service surface, so it sits against "stays small", though SQLite is already in the stack. QUEUE-004 would likely grow a sibling spec for restoring queued jobs. The "members resubmit them" sentence would go away.
2. **Record the exception.** Keep in-memory and add a Decisions row. It should name the tenet and goal being traded against, the alternative you rejected (durable queue), and the accepted cost (overnight restarts lose queued jobs). It might also mention any mitigation, such as pinning OS update windows to daytime. That is a real position, but "walk away" then needs a qualifier somewhere, since today the tenet reads as unconditional.
3. **Revise the tenet.** If the promise really only holds while the service stays up, say so in the HLD. For example: "a submitted job is a promise, except across restarts". Then the design and the tenet agree.

Whichever you choose, the exception row or the new persistence row also closes F2. If you go with option 2, that row is the whole fix for both findings. A decision doc would be overkill here.

If it helps you choose, I'd start with a quick question: how often does the mini-PC actually reboot overnight? If it's roughly never, option 2 is cheap and honest. If it's weekly, option 1 pays for itself the first time a member's part disappears.

I haven't edited anything. If you go with option 1 or 3 and want to work the change through the arrow (LLD, specs, then tests and code), `/linked-intent-dev` is the right entry point.