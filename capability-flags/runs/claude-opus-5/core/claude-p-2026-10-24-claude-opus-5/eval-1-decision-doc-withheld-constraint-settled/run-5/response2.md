Overkill, in my read — and the reason is worth a sentence because it's not "the debate was short."

The test is how the choice reads once it's landed, not how long it took to settle. Landed, a cold reader opens the HLD, sees *"no runtime network access is permitted"* and *"kiosks have no network route during normal operation,"* then opens the registry LLD and finds a kiosk-local SQLite index. They don't ask "why not a managed search service?" — the tenet already answered. A decision doc exists for choices that stay live, where a reader would re-litigate without the competing options in front of them. This one was settled by an inherited constraint before the options were sketched, so the doc would be preserving your deliberation rather than a live question — and that's the residue the *docs carry current intent* rule strips. A directory with one decision doc in it, recording the choice the HLD already forced, also sets a bad precedent for the next three.

I'd also skip a Decisions row for "why SQLite" specifically, for the same reason. The rows I did add are the sub-decisions SQLite forces and the HLD doesn't settle — build-then-swap activation, normalized-serial storage, metadata inside the index file, uniqueness via the index constraint. Those are the ones a cold reader could reasonably question.

Two cases would change my answer:

- You want the network-backed options genuinely open — then the live decision is at HLD level (relax the no-network tenet or don't), and a project-level doc in `docs/decisions/` could carry it.
- The deliberation surfaced a criterion the docs don't record anywhere — e.g. you weighed per-kiosk index rebuild time against something and it mattered. Tell me what it was and I'll find it the right home; that's usually a row or a goal, not a doc.

Otherwise my earlier questions still stand: which of the eight edge-probe gaps to fold into the LLD versus defer, and whether to drop the stale "lookup backend remains open" sentence at `docs/high-level-design.md:13`.