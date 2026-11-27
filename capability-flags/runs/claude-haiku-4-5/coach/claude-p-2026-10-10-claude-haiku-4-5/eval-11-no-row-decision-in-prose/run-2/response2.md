Let me walk through the in-memory storage issue and why it matters for your design coherence.

## The Tension

Your first tenet says: **"A submitted job is a promise: members should be able to upload and walk away."**

Your job-queue design says: **"The queue is a per-printer-class list of accepted jobs held entirely in process memory... jobs that were accepted but not yet dispatched before a restart are gone, and members resubmit them."**

On the surface these coexist fine — one is philosophy, one is mechanism — but they're in tension. A "promise" usually implies a commitment that survives the normal lifecycle of the system. Your design fulfills the "upload and walk away" part (members don't need to stay connected) but *not* the "promise" part when the system restarts.

## Why This Matters for You

**The cost of leaving this unrecorded:** Tenets exist specifically to guide the decisions *specs don't cover*. When a tenet and a design choice conflict without being captured as a deliberate trade-off:

1. **Future agents won't see the decision context.** When someone reads the in-memory storage line, they see it as "an implementation detail" rather than "a deliberate choice we made because promise durability was less critical than simplicity on a mini-PC." Six months in, someone asks "why aren't jobs persisted?" and has to reverse-engineer the reasoning instead of finding it written down.

2. **Production surprise.** The first time a restart (or power blip, or OS update) causes a member to lose a queued job, your team might think "oh, that's a bug we should fix" rather than "that's an accepted cost of this design." Then you spend effort adding persistence — which might have been worth doing, but the decision gets made twice without realizing it.

3. **Tenet drift.** Your other two tenets ("staff override, but the queue explains itself" and "the mini-PC is modest hardware; the service stays small") are constraints that your design *respects* throughout. The first tenet doesn't get that respect, and that asymmetry is invisible.

## What I'd Recommend

You have four clean paths forward. Pick one and record it:

**Option A: Reword the tenet to be explicit about scope.**
Change it to: *"A submitted job is accepted and queued; members should be able to upload and walk away without staying connected. (Restart durability is sacrificed to keep the system small.)"*

This makes the tenet honest about what it promises and grounds it in the "modest hardware" tenet. Future readers see exactly what's being traded off and why.

**Option B: Record the trade-off in Decisions & Alternatives.**
Add a row to your job-queue D&A table:
| Decision | Chosen | Rationale |
| Job durability | In-memory queue, lost on restart | Simplifies architecture on modest hardware; accepted cost is member resubmission after rare restarts. |

This preserves the tenet as-is and records the decision alongside the upload limit and scheduling choices where it logically belongs.

**Option C: Persist jobs to disk.**
If the "promise" tenet is really non-negotiable, write jobs to disk as they're accepted. You can keep the in-memory queue for dispatch efficiency and load the disk queue on startup. This costs a bit more of your mini-PC's I/O budget but keeps the tenet whole.

**Option D: Acknowledge it's a post-MVP conversation.**
If you want to ship a bootstrap version without this resolved, write a note in the LLD context: *"Future: decide whether job acceptance should survive restarts; if so, add disk persistence and update the tenet."* This at least signals that the tension is known and deferred, not overlooked.

## My Take

**Option B** (record it as a Decision) is the lightest and most coherent. It keeps your tenet honest about members not needing to stay connected, records the restart behavior as an intentional choice you've evaluated, and gives future teammates the context they need. It's three lines in a table, and it prevents the re-decision tax later.

Which of these resonates with your design intent, or is there a different angle you're thinking about?