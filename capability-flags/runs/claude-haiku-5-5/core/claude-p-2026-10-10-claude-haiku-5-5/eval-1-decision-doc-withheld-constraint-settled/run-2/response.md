**Phase 1 (HLD check) is done. Stopping here for your review.**

The HLD already covers the registry, and choosing SQLite doesn't change the architecture. The backend is private to the registry node, so the detail belongs in the registry LLD, not the HLD. I made one HLD edit: the registry bullet said its backend "remains open," which is no longer true. It now reads "Its lookup backend is private to the node." (`docs/high-level-design.md`, Architecture)

**Tenet conflict to check:** Options 2 and 3 don't fit the current HLD. The tenets say "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted," and "Kiosks have no network route during normal operation." An on-site HTTPS directory and a managed search service both need runtime network access. So SQLite is the only option that fits the HLD as written. If you still want one of the network options, the HLD tenets would need to change first. That's your decision, and I haven't changed anything for it.

**Recording the choice:** The SQLite decision goes in a row of the registry LLD's Decisions & Alternatives table, with the rejected options and why. Because the HLD tenets already rule out the other two, I don't think this earns a decision doc, so I won't offer one.

**Next, Phase 2 (registry LLD):** I'll rewrite `docs/intent/registry/registry-design.md` as a standalone document. That means removing the "backend not selected yet" and "remains open pending your choice" wording, describing the SQLite index, and specifying the import path: build the new index in a separate file, validate it, then switch atomically so the previous snapshot stays active on failure. I'll also add the Decisions row and run the LLD edge-case probe.

Do you approve the HLD edit, and do you want me to go ahead with Phase 2?