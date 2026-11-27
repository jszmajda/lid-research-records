Looking at the job-queue design more carefully, there's a noteworthy design choice worth examining closely.

The design states:

> "The queue is a per-printer-class list of accepted jobs held entirely in process memory... jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them."

And the HLD's first tenet is:

> "A submitted job is a promise: members should be able to upload and walk away."

**The tension:** On a cold read, "A submitted job is a promise" sounds like durability — the system will reliably honor the submission. But the queue design explicitly loses accepted-but-not-yet-dispatched jobs when the mini-PC restarts. The design acknowledges this and accepts the cost ("members resubmit them"), but the decision itself isn't recorded in the Decisions & Alternatives table.

**What I'd recommend:** This is a real design choice that will shape future decisions (e.g., if someone later asks "why don't we persist the queue?" or "should we recover jobs on restart?"). Right now it lives only as stated fact in the architecture section, but it should have a home in the Decisions table.

**Two paths forward:**

1. **Clarify the tenet** — If "a promise" is intentionally lighter than full durability (meaning "we'll run your job unless the infrastructure fails catastrophically"), consider rephrasing the tenet to make that scope explicit. E.g., *"Members trust the service with their jobs; we run what we accept unless hardware fails, then they resubmit."* This removes the ambiguity a future session might feel.

2. **Record the decision** — Add a row to job-queue's Decisions & Alternatives table:
   - **Decision:** Job queue persistence
   - **Chosen:** In-memory only; rebuild from printer state on startup
   - **Rationale:** Keeps the service small and stateless on the mini-PC; files are preserved for cheap resubmit; members rarely experience restart (rare OS updates)
   - **Alternative(s) rejected:** (e.g., persistent queue in SQLite — costs complexity and disk I/O; durable queue with recovery — costs state management)

Either way, the choice is sound — there's a clear trade-off between durability and simplicity that fits the "modest hardware" tenet. The issue is just making sure a future session reads it and understands the constraint, rather than seeing "a promise" and trying to retrofit durability later.

Which direction feels right to you — does the tenet need sharpening, or would a Decisions table entry make the design clearer?