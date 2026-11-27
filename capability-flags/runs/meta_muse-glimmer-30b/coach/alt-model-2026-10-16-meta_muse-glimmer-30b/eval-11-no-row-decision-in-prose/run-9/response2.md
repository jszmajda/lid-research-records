The in-memory queue is the part of `docs/intent/job-queue/job-queue-design.md:14` that reads:

> The queue is a per-printer-class list of accepted jobs held entirely in process memory. On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them. Uploaded G-code files are kept on disk under a content hash, so resubmitting the same file is cheap.

That is a load-bearing design choice, and it shows up in three places at once:

* **Docs carry current intent, written to be read cold — *mutation, not accumulation*.**  
The line is present intent, not residue. A cold reader can see the system is intentionally volatile. What is missing is a single authoritative place for it. It lives only in the Architecture prose, not in the Decisions & Alternatives table and not in EARS.

* **Effective intent-tree alignment.**  
The spec file `docs/intent/job-queue/job-queue-specs.md` covers upload size, dispatch on idle, dispatch failure, startup rebuild, and visible reordering. None of the five specs `QUEUE-001`…`QUEUE-005` names the loss of undelivered jobs on restart.

That creates a walkability gap. An agent grepping the arrow will find no spec for a behavior the LLD explicitly describes. If the loss is intentional, the arrow is under-specified; if it is an implementation detail, the LLD is over-specifying.

* **Tenet cascade — *tenets capture forward-looking preference*.**  
The HLD tenets include `docs/high-level-design.md:20`:
> A submitted job is a promise: members should be able to upload and walk away.

In-process memory with loss on power blip / unattended OS update directly works against that lean. The design notes the mini-PC “takes unattended OS updates and the occasional power blip” in `docs/intent/job-queue/job-queue-design.md:10`, so the condition where the tenet is defeated is explicitly described in the same doc. There is no Decisions row naming the tenet traded against and why, and no exception recorded.

What I’d recommend:

1. **Make the choice explicit.** Decide if volatile queue is the real intent.
   * If yes, promote it to a Decisions & Alternatives row with the trade-off named: durability vs mini-PC simplicity, and the cost accepted — members must resubmit after a restart. Record the tenet it trades against and why the trade is acceptable now.
   * If no, change the architecture to persist the accepted-but-undispatched list. The tenet “upload and walk away” then holds.

2. **Put the behavior where the arrow can find it.**  
   *If it stays volatile:* add an EARS spec that makes the loss testable, e.g. “When the service restarts, the system SHALL not retain jobs that were accepted but not yet dispatched.” That gives you a test target and makes the intent grep-anchored.
   *If you want durability:* remove the loss statement from the LLD and replace it with a persistence mechanism and a spec that guarantees recovery after restart.

3. **Close the tenet gap.** Either revise the tenet to reflect the real promise the system makes — e.g., “upload and walk away between dispatches, resubmit after a restart” — or fix the design so the tenet holds under the OS-update/power-blip condition described in Context.

Right now the design is honest but not walkable: a future session will read the tenet, read the Architecture, and have to reconcile a conflict that isn’t recorded anywhere the arrow can surface it. Making the decision explicit in the Decisions table and giving it a spec is the way to keep the arrow coherent.