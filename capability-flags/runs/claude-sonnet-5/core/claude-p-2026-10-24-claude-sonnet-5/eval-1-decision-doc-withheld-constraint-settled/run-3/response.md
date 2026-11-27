Draft update to `docs/intent/registry/registry-design.md` is done, plus an LLD-level edge-case probe (via a blind subagent). Here's what changed and what the probe found.

**Design doc update** — Architecture/Snapshot Import/Lookup Behavior sections now finalize the backend as a local embedded SQLite index (rebuilt per-kiosk, atomic activation, indexed-column query), and I added a Decisions & Alternatives row. I did **not** offer a decision doc: the HLD's existing "no runtime network access" tenet already rules out the other two options, so for a cold reader this isn't a live trade-off to re-litigate — it's an inherited constraint settling the choice — even though it took you a while to get there in the room. A table row is enough.

**Edge-case probe found 9 gaps**, worth your triage:

1. Concurrent imports racing on the same build location — prevented, queued, or unhandled?
2. An empty-but-validly-signed snapshot — valid activation or rejected?
3. The atomic index-swap *itself* failing (not the build) — same fallback as a build failure, or unhandled?
4. The deactivated old index file — deleted, retained, or left to accumulate?
5. Uniqueness validated on raw records, but lookup normalizes case/whitespace — two raw-distinct serials that normalize the same could collide at lookup time.
6. `NotFound` doesn't distinguish a genuine miss from an index-read/corruption error.
7. In-flight lookups are promised to finish against their starting index — how long is the old file kept available to guarantee that?
8. Snapshot date validity is never checked, though both result types depend on it.
9. No post-build check that the index's record count matches the snapshot's.

Which of these do you want folded into the LLD now, and which should become Open Questions to defer? And does the Decisions row read right to you, or would you rather it as a fuller decision doc after all?