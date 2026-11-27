**Overkill — no decision doc.** I applied the earns-its-place test when you settled the choice and deliberately did not offer one. Three reasons, all from the landed state rather than the deliberation:

- **A cold reader finds it native, not non-obvious.** The finished design is offline kiosks with a local embedded index. Nothing would tempt a reader to reverse it to a network-dependent option, because the HLD forbids that. "I went back and forth / they looked pretty close" is a *symptom*, not the test — the skill is explicit that a long debate can still land as a single table row, "however long the debate ran."
- **An inherited constraint settles it.** The HLD tenets ("no runtime network access," "no network route," USB-only snapshots) and the "cloud/remote services" non-goal eliminate the on-site HTTPS directory and managed search service. One viable option remained — the case the heuristic names as "an inherited constraint eliminated the rest."
- **It affects only its own node.** All three options kept `findBySerial` and the certificate interface unchanged, so no other design node is sized around the result. Both "Do not offer one for…" clauses apply.

A full doc here would be the residue *docs carry current intent* strips — recording a settled-and-obvious choice — and would memorialize deliberation ("we weighed A vs B vs C") that a fresh author of the landed system wouldn't write. A directory full of decision docs is a smell; people offered a doc tend to say yes whether or not they need it.

The right level is the **Decisions & Alternatives row** already in `docs/intent/registry/registry-design.md`: named alternatives, filled rationale, one line settling "why this?". That's the middle of the three-outcome test — not "record nothing," because two alternatives were genuinely in the sketch.

If you want a doc anyway, it's your call (user is always right, with warning): I'd flag it as redundant documentation, write it cold, and link it from the row. I'm not recommending it.

I'm still holding at the **Phase 2 stop** — the two rulings from my last message remain open: (1) numbered triage of edge gaps 1–11 (fix in the LLD vs. defer), and (2) approval of the finalized LLD + HLD fix to proceed to Phase 3 (EARS). No tests or code have been written.