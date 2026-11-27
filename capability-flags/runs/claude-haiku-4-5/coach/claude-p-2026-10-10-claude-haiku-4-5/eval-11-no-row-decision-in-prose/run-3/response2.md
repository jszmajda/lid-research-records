Looking at the job-queue design, the in-memory queue with job loss on restart is clearly intentional—it's driven by the tenet "The mini-PC is modest hardware; the service stays small." The LLD explains the trade-off in the Architecture section and QUEUE-004 captures the startup behavior as a spec.

**What I see working:** A cold reader can reconstruct why the choice was made. The tenet explains the constraint; the architecture explains the consequence (jobs resubmitted); the caching-by-hash detail shows the cost is mitigated.

**The decision-capture question:** The in-memory vs. persistent queue decision isn't explicitly in the Decisions & Alternatives table. It's woven into the architecture narrative instead. A cold reader *would* pause and think "that's a trade-off"—and can they reconstruct what was given up? Mostly yes (durability for simplicity), but not with the clarity a Decisions row would give.

**My recommendation:** Consider adding a Decisions table row before code begins:

| Decision | Chosen | Rationale |
|---|---|---|
| Queue persistence | In-memory only; rebuild from printers on startup | Persistent queue (SQLite, file) rejected: adds complexity and storage I/O to modest hardware; accepted cost: jobs in flight at restart are lost (members resubmit); file cache by hash mitigates resubmission friction |

That row isn't necessary if you're confident the implicit reasoning in the architecture is clear enough—but it buys you explicit trade-off capture at the moment it's fresh, which pays off later when someone asks "why not just add SQLite like the registry does?" You'll have the recorded answer.

This is the kind of lightweight decision doc (just a fuller table row, not a separate file) that LID's decision-capture principle (dimension 18) is designed for.