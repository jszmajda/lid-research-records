The lookup-backend choice is the kind of decision that a Decisions & Alternatives table row is built for.

With the HLD tenets in place — *All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted* and *Kiosks have no network route during normal operation* — a cold reader will see why local embedded SQLite is the natural fit, and why an on-site HTTPS directory and a managed search service were rejected. The rationale you already have — predictable lookups with no service to run, each kiosk validates/rebuilds its own index, all registry concerns stay inside the component, satisfies the no-network tenet — settles the “why this?” question in one line.

That’s the earns-its-place test for a decision doc: *would a cold reader of the result find the choice non-obvious and be tempted to re-litigate it without the competing options and criteria?* Here the tenets make the reverse of the tenet absurd rather than a defensible alternative, and the trade-offs are captured in the row:

* Lookup backend — Chosen: Local embedded SQLite index. Alternatives: On-site HTTPS directory; Managed search service. Rationale: predictable lookups with no service to run; each kiosk validates and rebuilds its own index on snapshot arrival. Keeps all registry concerns inside the registry component and satisfies the no-network tenet.

A full decision doc is warranted only when the choice stays genuinely live — e.g., you expect future revisiting of cost/complexity vs richer search, or the decision is project-level and will size multiple nodes. The registry LLD already records the rejected alternatives and why, and the choice is scoped to one leaf.

So: table row is sufficient now. If you want a decision doc to preserve the full option sketch, downstream consequences, and the back-and-forth you described, I can create `docs/intent/registry/decisions/lookup-backend-choice.md` and link it from the Decisions row. Do you want the doc, or keep it as the table row?
