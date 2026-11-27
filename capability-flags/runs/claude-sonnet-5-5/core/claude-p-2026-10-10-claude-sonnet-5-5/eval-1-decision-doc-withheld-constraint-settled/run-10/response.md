**Phase 1 (HLD check) is done. Please review before I move to the registry LLD.**

**One thing about the options.** The HLD already settles this choice, so the three weren't as close as the sketch made them look. Two of them break standing constraints:

- **On-site HTTPS directory:** lookups would depend on the lab network. That violates the tenets "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted" and "Kiosks have no network route during normal operation."
- **Managed search service:** this breaks the same tenets and also the Non-Goal of "cloud services during kiosk operation."
- **Local SQLite index:** this is the only option that fits the existing tenets. Your choice is consistent with the HLD, and no HLD tenet needs to change.

Because the HLD constraints rule out the other two, I'll record the decision as a row in the registry LLD's Decisions & Alternatives table rather than a standalone decision doc. The two eliminated options and the tenets that exclude them go in that row.

**HLD edit.** The Registry bullet under Architecture said the backend "remains open." I changed it in `docs/high-level-design.md` to:

> Owns snapshot validation and lookup. Lookups are served from a local embedded SQLite index that the kiosk builds from each validated snapshot; the index is private to the registry.

Nothing else in the HLD changes. The certificates segment is untouched, since it only sees `findBySerial`.

**Next phase.** If you approve, I'll update `registry-design.md` to:

- name SQLite as the backend, replacing the "candidates / remains open" language
- describe how a new index is built beside the active one and activated only after validation
- add the Decisions & Alternatives row
- run the LLD edge-case probe, covering things like a failed index build, a crash mid-activation, and the 250 ms / 150 MB goals

Does the HLD wording look right, or do you want changes?