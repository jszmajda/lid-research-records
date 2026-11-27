**Phase 1 — HLD check: done.** Selecting the local embedded SQLite index closes the one item the HLD left open. The revised Architecture section of `docs/high-level-design.md`:

```markdown
## Architecture

- Registry: `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`. Owns snapshot validation and lookup. Its private lookup backend is a local embedded SQLite index built from the active snapshot on the kiosk.
- Certificates: `docs/intent/certificates/certificates-design.md`, with `docs/intent/certificates/certificates-specs.md`. Uses the fixed registry result type and writes PDFs to a user-selected local directory.
```

Change: "Its private lookup backend remains open." → "Its private lookup backend is a local embedded SQLite index built from the active snapshot on the kiosk." Tenets, goals, and non-goals already fit this choice (file-only lookups, no runtime network), so nothing else in the HLD moves. No new tenet seems needed — the existing no-network tenet already settles backend questions of this kind; say if you'd lean a different way on anything the choice opens up.

Next, Phase 2 revises the registry LLD: bake the backend into its Architecture/Lookup sections, add a Decisions & Alternatives row for the selection (the two network-backed candidates lose to the no-network tenet, so a row — not a decision doc), and run the LLD-level edge-case probe against the finished design.

Approve to proceed to Phase 2, or give numbered feedback on the HLD edit.