**F2 — Medium. Tenet cascade conflict around in-memory queue loss on restart.**

The job-queue LLD says the queue is *“a per-printer-class list of accepted jobs held entirely in process memory. On startup the service rebuilds its picture of the farm by polling each registered printer for the job it is currently running; jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them.”* `docs/intent/job-queue/job-queue-design.md:14-15`. The HLD tenet is *“A submitted job is a promise: members should be able to upload and walk away.”* `docs/high-level-design.md:20`.

Under *tenets capture forward-looking preference* — a one-line tie-breaker for decisions with two defensible answers — and *tenet cascade* — design nodes should lean the way HLD tenets and goals say to lean, or record an exception — this is a direct conflict. The tenet promises unattended upload-and-walk-away; the in-memory design makes that promise conditional on the mini-PC staying up between upload and dispatch. Under the operating condition the docs themselves name — “the service runs on the workshop mini-PC, which takes unattended OS updates and the occasional power blip” `docs/intent/job-queue/job-queue-design.md:10` — a restart leaves members with a lost job they have to discover and resubmit, which is the opposite of “upload and walk away.”

That matters because the tenet is a forward-looking preference meant to constrain exactly these edge choices. If the design quietly violates it, future sessions will keep filling the edge in the same way — e.g., adding retry UI, resubmit prompts, or “it’s fine” rationales — and the promise to members erodes session by session. The cost also compounds in the makerspace: a member uploads in the evening, the PC reboots overnight, the job disappears, and the part never prints. The system looks reliable until the one time it isn’t.

**What you can do**

This is a tenet-or-goal conflict, so the remedy is a user choice, not a prescription:

* Change the design to honor the tenet — persist accepted-but-undispatched jobs to durable storage on the mini-PC, so a restart rebuilds the queue, not just the running jobs. That closes the gap and keeps the tenet intact.
* Keep the in-memory design and record the exception explicitly. Add a Decisions & Alternatives row in `docs/intent/job-queue/job-queue-design.md` naming the tenet traded against, the condition under which it is traded, and why the cost is accepted today — e.g., “mini-PC storage constraints, acceptable member re-submit rate, etc.” Recording the exception also fixes the under-captured decision noted in F3.
* Revise the tenet if unattended durability is intentionally out of scope. If the makerspace accepts that jobs are best-effort until dispatched, the tenet should say so, and the HLD non-goal list can be updated accordingly.

If you record the exception, the row should name the tenet, the accepted cost, and the condition that triggers it, so a cold reader in six months can see why the design intentionally leaves the promise conditional. I can walk you through drafting that row, or through a persistence sketch if you want to move toward honoring the tenet instead.
