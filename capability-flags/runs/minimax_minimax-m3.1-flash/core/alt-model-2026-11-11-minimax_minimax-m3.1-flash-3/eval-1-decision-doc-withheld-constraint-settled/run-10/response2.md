Overkill — a Decisions row is the right level, and the registry LLD already has it (`registry-design.md`, "Lookup backend").

Two reasons: the choice no longer reads as live to a cold reader, because the HLD tenet (lookups complete from kiosk files, no runtime network) already settles it — the HTTPS directory and managed service would violate a tenet, so a reader won't re-litigate the choice. And the decision's substance lives entirely inside the registry node; the certificate interface is unchanged, so there's no sibling segment that would need the reasoning.

What would change that answer: if the no-network tenet were ever relaxed (making a shared index plausible again), the choice becomes genuinely live and a decision doc under `docs/intent/registry/decisions/` would earn its place. I'd also rather not memorialize the back-and-forth itself — that's session residue, not current intent.

Still waiting on your answers to the five questions above before I write the EARS specs.