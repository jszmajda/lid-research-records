Overkill — the `Decisions & Alternatives` row in `registry-design.md` is the right fit.

Looking at the landed design rather than how close the debate felt:
- **Inherited HLD constraints settle it.** The HLD mandates offline lookups with no runtime network access and excludes remote/cloud services, which eliminates both the on-site HTTPS directory and the managed search service. A cold reader won't find the choice genuinely live to re-litigate.
- **It is private to one node.** `certificates` only sees `findBySerial(serial)`, so no other design node is being sized around SQLite.

A standalone decision doc is best reserved for choices that stay genuinely live for a future reader and shape other nodes. If you still want one anyway, I can write it under `docs/intent/registry/decisions/`; otherwise we can keep the table row and proceed with your feedback and triage on Phase 2.