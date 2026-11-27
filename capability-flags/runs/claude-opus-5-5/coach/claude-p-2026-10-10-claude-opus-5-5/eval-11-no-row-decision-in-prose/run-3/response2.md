Two findings from the report bear directly on this (F1 and F2), and two more touch it (F4 and F7).

**F1 — High. The in-memory queue works against your lead tenet under conditions the same doc describes.** `job-queue-design.md` says the queue is "held entirely in process memory" and that after a restart, accepted-but-undispatched jobs "are gone, and members resubmit them". Its own Context section says the mini-PC "takes unattended OS updates and the occasional power blip". Put those together with the HLD: a member uploads at 9pm, the box reboots for an update at 2am, and the job silently disappears. That defeats the tenet "a submitted job is a promise: members should be able to upload and walk away" and the goal "evening upload, overnight print, morning pickup — with no member present". This falls under *tenet cascade*: leaf designs should lean the way the HLD's tenets say to lean, or record the exception. If it sits, a future session reading only the job-queue LLD will faithfully build the job loss in, and one reading only the HLD will assume durability.

**F2 — High. The choice has no Decisions & Alternatives row.** The table records scheduling order, job identifiers and the upload limit, but not the in-memory queue. A cold reader will question this one, especially since printer-registry already persists to a SQLite file on the same box. They cannot tell whether persistence was weighed and rejected, or what cost was knowingly accepted. This is *decision capture*: a choice a reader would want to reverse needs its trade-off on the page. Without it, the choice looks like an oversight and invites a well-meaning "fix" or a silent contradiction.

**Related.** The job loss on restart has no EARS spec: `QUEUE-004` covers rebuilding from printers only (F4). The tenets are also unordered (F7), and this is exactly where "a submitted job is a promise" meets "the service stays small".

## What to do

There are three ways to resolve F1. Which one is right depends on what you intend, so I'm not picking one for you.

1. **Change the design.** Persist accepted jobs so they survive a restart, and say what `QUEUE-004` does with them on startup. The cost is a little more surface on the mini-PC, though the registry's SQLite file is already there.
2. **Record the exception.** Keep the in-memory queue and add a Decisions row naming the tenet traded against, the alternative rejected and the accepted cost. This also closes F2. You'd likely also want a spec for what members see when a job is lost, since the tenet "the queue explains itself" suggests it shouldn't vanish silently.
3. **Revise the tenet.** If "promise" was meant to be softer (best-effort, resubmission is cheap), reword the tenet and the no-member-present goal to say so.

Whichever you choose, two small follow-ons apply:

- **Order the tenets**, so the next promise-versus-small collision has a tie-breaker.
- **Add the missing spec** for restart behaviour under the `QUEUE` prefix, with a new ID rather than a renumbering.

If you choose option 1 without recording why, F2 still wants a short row for whichever store you pick.

The coach doesn't edit files. To apply any of this, run `/linked-intent-dev` with the change you've chosen and it will cascade it through HLD, LLD and specs.

Which of the three matches what you meant by "promise"?