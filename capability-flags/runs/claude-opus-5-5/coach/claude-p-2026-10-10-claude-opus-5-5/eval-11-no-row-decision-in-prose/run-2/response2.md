**F1 — High. The job-queue design drops accepted jobs under a condition its own Context section says will happen.** `job-queue-design.md:14` holds the queue "entirely in process memory" and says that jobs accepted but not yet dispatched before a restart "are gone, and members resubmit them". Four lines earlier (`:10`), the same doc says the mini-PC "takes unattended OS updates and the occasional power blip", and that members upload "mostly in the evening" for overnight dispatch. So the window when the queue is fullest is also the window when a restart is most likely and nobody is around to resubmit. That runs against the HLD's first tenet, "a submitted job is a promise: members should be able to upload and walk away", and its first goal, "evening upload, overnight print, morning pickup — with no member present". This falls under *tenet cascade*: leaf designs should lean the way the HLD's tenets say to lean, or record the exception. A future session implementing QUEUE-004 will build exactly what the LLD says and the tenet will not hold. A session that notices the tension has nothing telling it which side wins, so it will guess. The design may well be defensible: "the service stays small" is also a tenet, and a member whose job vanished can re-upload cheaply because of the content-hash store. But the docs don't say that this is the trade.

**F2 — High. The choice has no Decisions & Alternatives row.** The table in `job-queue-design.md:29-33` carefully records the alternative and accepted cost for scheduling order, job identifiers and upload size. The in-memory queue appears only as Architecture prose. This is *decision capture*: a choice that a cold reader would still question needs what was given up, and why, on the page. A reader will question this one quickly, because `printer-registry-design.md:14` already persists to a SQLite file on the same machine, and its row says "nothing else needs concurrent writers". The obvious question is why the queue doesn't sit in that file too. Without a row, the next person either "fixes" it against your wishes or leaves it alone without knowing whether it was deliberate.

**What to do — three options, and the choice is yours.** The reason not to pick for you is that the question is which of your two tenets wins, and that is your intent to state.

- **Change the design.** Persist accepted jobs so they survive a restart, and rebuild the queue on startup alongside the printer poll. This cascades to:
  - the Architecture section;
  - QUEUE-004, which today only covers polling printers;
  - a new Decisions row for the store that was chosen.
- **Record the exception.** Keep the in-memory queue and add a Decisions row naming:
  - the rejected alternative (a persisted queue, e.g. in the registry's SQLite file);
  - the tenet traded against ("a submitted job is a promise");
  - the accepted cost (overnight restarts lose queued jobs; members resubmit).

  This also closes F2. It would be worth adding a spec for what a member sees afterwards, since "members resubmit" currently has no spec (part of F4) and nothing tells them their job is gone.
- **Revise the tenet.** If the real promise is weaker — say, "a dispatched job is a promise" or best-effort overnight — change the tenet and the first goal in the HLD so the leaf no longer contradicts them. The Decisions row is still worth adding.

**One related item (F7).** Whichever you choose, consider ordering the HLD's tenets. "A submitted job is a promise" and "the service stays small" collide on exactly this question, and an ordered list would have answered it before the LLD was written. It will also answer the next collision.

The coach doesn't edit files. To apply any of these, run `/linked-intent-dev` with the option you've chosen and it will walk the change from the HLD or LLD down through the specs. Which way are you leaning?