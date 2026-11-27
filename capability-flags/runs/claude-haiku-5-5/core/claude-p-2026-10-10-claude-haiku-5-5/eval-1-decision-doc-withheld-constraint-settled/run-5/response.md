**Phase 1 (HLD check) is done. Stopping here for your review before the registry LLD.**

I chose the local SQLite index as you asked. The HLD tenets already rule out the other two options: "All serial-number lookup SHALL complete using files on the kiosk," and "Kiosks have no network route during normal operation." An on-site HTTPS directory or a managed search service would both need runtime network access, so I haven't offered a decision doc for this choice. The only thing that goes in the registry LLD is a Decisions row recording the alternatives and why they were dropped.

**The one HLD change** (uncommitted, in `docs/high-level-design.md`): the Registry architecture line said "Its private lookup backend remains open." It now reads:

> Registry: … Owns snapshot validation, the kiosk-local lookup index built from each accepted snapshot, and lookup. The index is an embedded SQLite database; no other component reads it.

The HLD had gone stale on the backend, so I updated it. Nothing else in the HLD changed, and the tenets are consistent with the SQLite choice. The one thing the tenets don't settle is that the index must be built and validated before activation, so a failed index build keeps the last valid snapshot. That needs to be in the registry specs.

**Next, once you approve (Phase 2, then Phase 3):**
- Rewrite `registry-design.md` to describe the SQLite index as the design. The candidate list and the "remains open" wording go, since they describe the decision process rather than the design. Add a Decisions & Alternatives table with the two rejected options and their rationale.
- Add EARS specs for the index build and atomic activation, and for lookups that use only local files. The 250 ms lookup goal from the HLD has no spec yet, so I'd like to decide whether it becomes one.

Should I go ahead with Phase 2 on the HLD change as written?