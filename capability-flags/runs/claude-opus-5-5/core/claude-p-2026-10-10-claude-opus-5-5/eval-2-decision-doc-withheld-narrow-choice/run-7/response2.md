I'd skip it: the row already in the previews design is the right size for this decision.

- **The length of the argument isn't the test.** What matters is whether someone reading the finished design cold would reopen the choice without the full tradeoffs laid out. The row already gives them the three candidates, what each costs, and why protecting comparison sheets won.
- **Nothing else leans on it.** The policy is private to the preview worker. The interface, the render queue, the 12 GiB budget and the review API are identical under all three options, so no other part of the design is sized around 2Q.
- **It's cheap to reverse.** If the pilot shows 2Q is wrong, swapping it changes one section of one design and nothing outside the worker.
- **A decision doc wouldn't hold the thread anyway.** It records options and criteria in the present tense, not who argued what across three meetings. It would be the same content as the row at about five times the length.

The real risk is that someone restarts the argument in six months. If the row feels too thin to prevent that, I'd strengthen its rationale with the specific evidence that settled it, such as how large the screenings are and how often comparison sheets were being lost. That's a one-line edit if you can give me the numbers.

It's your call, though. If you still want the full doc, say so and I'll write it at `docs/intent/previews/decisions/eviction-policy.md` and link it from the row.

The earlier questions are still open before I move to specs: the promotion rule and the four gaps.