**F1 — High. The queue keeps accepted jobs only in memory, which works against the HLD's central tenet.**

`job-queue-design.md` (Architecture) says accepted jobs are "held entirely in process memory." After a restart, "jobs that were accepted but not yet dispatched… are gone, and members resubmit them." QUEUE-004 specifies only rebuilding what each printer is currently running, so the spec doesn't cover queued jobs either. The same doc's Context says the mini-PC "takes unattended OS updates and the occasional power blip."

Compare that with what the HLD promises:
- The first tenet reads "a submitted job is a promise: members should be able to upload and walk away."
- The first goal reads "Evening upload, overnight print, morning pickup — with no member present."

The two don't share wording, but under the conditions the LLD itself describes they collide. An overnight restart quietly drops queued jobs, and the member who uploaded at 8pm finds nothing printed at 8am and has to resubmit. This is the *tenet cascade* lens (do the leaf designs lean the way the HLD's tenets say?). It matters because the member-facing promise is the whole reason the service exists, and the loss happens at exactly the hour nobody is watching.

Two things soften the picture:
- The uploaded files are already kept on disk under a content hash.
- The design is candid about the cost.

So the fix may be small. Also, the third tenet ("modest hardware; the service stays small") is a legitimate pull the other way, and that is probably why in-memory was chosen.

**F2 — High. The in-memory choice has no Decisions & Alternatives row.**

The table records scheduling order, job IDs and upload size, each with its rejected alternative and accepted cost. The persistence choice, which is the one that touches the tenet, appears only as a sentence of architecture prose. This is the *docs carry current intent* principle, in its keep-side: a live decision belongs in the table, with what was given up. A cold reader will question this choice and can't tell from the page whether it was deliberate, what was traded, or whether "members resubmit" was weighed against the promise tenet. Left alone, the next session either "fixes" it by adding persistence without knowing about the tenet pull toward small, or relies on it without knowing it conflicts with the tenet.

**What I'd recommend**

These are your calls; I'm not picking one for you. There are three honest remedies for F1:

1. **Change the design.** Persist the accepted-job list, which is small metadata referencing the hashed files already on disk. The registry already uses a single SQLite file, so one more table there or a sibling file adds little. QUEUE-004 would then rebuild queued state as well as running state, and you'd likely add a spec such as "when the service starts, the system SHALL restore all accepted, undispatched jobs in their prior order." This honors the promise tenet and the overnight goal, at a modest cost against "stays small."
2. **Keep in-memory and record the exception.** Add a Decisions row naming the tenet traded against, for example: *Queue durability | In-memory, lost on restart | Persisting rejected to keep the service small; accepted cost: restarts drop undispatched jobs and members must resubmit, which breaks "upload and walk away" on restart nights.* If you go this way, consider whether the restart window can be made rare or visible, for instance by deferring updates until the queue is empty or notifying members of dropped jobs. That's a design question for you, not something I'd write into the docs for you.
3. **Revise the tenet.** If "walk away" was really meant as "walk away unless the box restarts," soften the tenet and the goal so they say what the system delivers.

Whichever you pick, **recording it as a Decisions row also closes F2**, so that row is worth writing in every case. I'd lean toward option 1 on the merits. It looks cheap here, and it is the only option that keeps the tenet and goal true as written. But option 2 is entirely defensible if small-service wins.

The row is enough; this doesn't warrant a standalone decision doc. If you do change the design (option 1), that's a change to the LLD and specs, which is best done through `/linked-intent-dev` so the cascade (HLD → LLD → specs → tests) stays coherent. I don't edit files in a coach session.

Want to talk through which way you'd lean, or move on to F3 and F4?