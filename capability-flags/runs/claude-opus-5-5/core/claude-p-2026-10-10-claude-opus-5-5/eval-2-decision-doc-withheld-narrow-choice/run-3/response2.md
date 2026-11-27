I'd skip it: the Decisions row already in the previews design does the job.

The length of the argument isn't what a decision doc is for. It earns its place when someone reading the finished design cold would want to re-litigate the choice and couldn't without the full options and criteria laid out. This one doesn't clear that bar:

- **It only touches the preview worker.** The HTTP interface, render queue and 12 GiB budget are identical under all three policies, and the review API is explicitly barred from depending on eviction behaviour. Nothing else is sized around 2Q.
- **It's cheap to reverse.** Swapping the policy later means changing private bookkeeping in one component, with no migration and no interface change.
- **The reasoning fits in the row.** It names LRU and aged frequency, says what each costs, and says why screening-versus-comparison traffic favours 2Q. That is what a future reader needs to reconstruct the call.

A decision doc would also be written cold, in the present tense, with no account of the three meetings or the thread. So it wouldn't preserve the arguing; it would restate the row at greater length.

If the real worry is someone reopening this in a month, I can strengthen the row instead, for example by adding the specific condition that should prompt a rethink (say, reused-queue evictions during screenings staying high after tuning the split).

It's your call, though. If you still want the doc, say so and I'll write it at `docs/intent/previews/decisions/eviction-policy.md` and link it from the row.