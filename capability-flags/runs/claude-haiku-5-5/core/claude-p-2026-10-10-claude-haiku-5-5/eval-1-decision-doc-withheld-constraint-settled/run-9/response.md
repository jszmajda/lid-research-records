Phase 1 (HLD check) is done. I'm stopping here for your review before the registry LLD draft.

**HLD check**

The HLD already covers this change. Choosing the local SQLite index is a registry-internal decision, so it doesn't change the architecture and doesn't need a new Key Design Decision in the HLD.

I made one edit to `docs/high-level-design.md`. The registry bullet said the lookup backend "remains open," which is no longer true:

- Before: `Owns snapshot validation and lookup. Its private lookup backend remains open.`
- After: `Owns snapshot validation and lookup. Its lookup backend is private to the node.`

**Why the other two options are out**

The existing tenets already rule out the on-site HTTPS directory and the managed search service:

- "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted."
- "Kiosks have no network route during normal operation."

Because of those tenets, I'm not offering a decision doc for this choice. It affects only the registry node, and one option is excluded outright. I'll record it as a row in the registry LLD's Decisions & Alternatives table instead. That row will name the two rejected options and the tenets that excluded them.

**Next: Phase 2 (registry LLD)**

Unless you want changes to the HLD edit above, the next step is a draft of `docs/intent/registry/registry-design.md`. It will:

- Describe the embedded SQLite index: how a snapshot is validated, prepared, and activated, and how the index is rebuilt on each kiosk when a snapshot arrives.
- Replace the current "backend not selected yet" wording with the chosen design.
- Add the Decisions & Alternatives table with the SQLite row.
- Run an LLD-level edge-case probe on the draft.

Do you approve the HLD edit, and should I proceed to the Phase 2 LLD draft?