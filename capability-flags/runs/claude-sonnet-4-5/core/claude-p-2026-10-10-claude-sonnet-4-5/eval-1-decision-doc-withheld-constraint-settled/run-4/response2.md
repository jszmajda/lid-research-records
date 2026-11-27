Table row is sufficient.

Applying the test from the landed state: a cold reader would see the HLD tenet "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted" and recognize that it rules out the HTTPS directory and managed search options. The choice reads as constrained rather than live once they know that tenet.

The table row captures the key rationale (predictable lookups, no network, aligns with tenet, acceptable downside) and names the alternatives considered. That's enough for a reader to reconstruct why SQLite was chosen without re-litigating the decision.

A full decision doc is for choices that stay genuinely live even after reading the design—where a reader would be tempted to reverse it without seeing the full competing-options breakdown. Here, the inherited constraint (HLD tenet) settles it decisively enough that the row does the job.

The deliberation was hard because the options were close *before* weighing them against the tenet, but once landed, the choice reads clearly.