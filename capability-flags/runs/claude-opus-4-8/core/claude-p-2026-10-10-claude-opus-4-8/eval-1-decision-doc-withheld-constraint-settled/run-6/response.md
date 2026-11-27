Draft is in place and the probe is back. Here's where the registry LLD stands — **Phase 2 stop, for your review before I touch the specs.**

## What I changed in `registry-design.md`

- **Backend selected: local embedded SQLite index** on kiosk storage. The USB snapshot still carries the signed newline-delimited records; each kiosk builds its own index from them on import (no index is transported between machines).
- **Snapshot Import** now spells out the flow: validate (signature → schema → uniqueness) *before* any build, build into a **staging** location, then **atomically replace** the active index. A build/activation failure leaves the previous index active.
- **Lookup Behavior** now names the query path: normalize the serial, query the indexed column, read the snapshot date from index metadata on both `Found` and `NotFound`.
- Dropped the "backend not selected yet / candidates are…" prose — that was the open question, now answered, so it'd be stale narration.

## How I recorded the decision

A **Decisions & Alternatives row**, not a full decision doc. Even though you went back and forth, the choice isn't *live* for a cold reader: the HLD's offline tenets ("no runtime network access," "no network route during normal operation") rule out both networked options at lookup time, so SQLite is the only candidate that clears the gate. The row records that reasoning and two narrower sub-choices (build-per-kiosk vs. shipping a prebuilt index; staged-swap vs. in-place writes). If you'd rather I write a standalone decision doc anyway, say so.

## Edge-case gaps to triage (fix in the LLD now, or defer as open questions?)

1. **Uniqueness vs. normalization mismatch.** Uniqueness is checked on *raw* serials, but lookup normalizes (whitespace + uppercase ASCII). So `ab-1` and `AB-1` pass the uniqueness check yet collide at query time — and `findBySerial` returns a single record. Should uniqueness be enforced on the *normalized* form (making this an import rejection, REG-003 territory)? This is the one I'd most want settled before specs.
2. **Cold start / empty registry.** Before any successful import there's no active index and no snapshot-date metadata. What does `findBySerial` return, and what date (if any) does a `NotFound` carry?
3. **Import ↔ lookup concurrency.** "Atomic replacement" is stated, but can a lookup be served *during* a build, and are two imports serialized? Kiosks are single-user, so this may be a non-issue worth one sentence rather than real machinery.
4. **Error shape on import failure.** The LLD says import "reports a useful error" but never defines that surface — and it's deliberately *not* the `Found`/`NotFound` type. Worth pinning the error's shape now?
5. **Degenerate serial input.** Normalization covers surrounding whitespace and ASCII case only. What about empty-after-normalize, or non-ASCII / control characters in the entered serial?
6. **Crash between build and activation.** A crash could leave a populated staging index. Startup handling of an orphaned staging index is unstated (general cleanup is already deferred in Open Questions, but the correctness-on-restart invariant isn't).

Tell me which of these to fold into the LLD and which to leave as deferred open questions, plus any correction to the draft itself. Once the LLD is settled I'll cascade to the REG specs (Phase 3) — I expect #1 and possibly #2/#4 to change or add spec lines there.