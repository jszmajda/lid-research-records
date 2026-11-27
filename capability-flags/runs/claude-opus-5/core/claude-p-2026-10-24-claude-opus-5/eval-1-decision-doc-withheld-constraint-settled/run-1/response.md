Registry design finished and the Phase 2 stop is below.

## What changed

**`docs/intent/registry/registry-design.md`** — rewritten around the embedded SQLite index:

- **Architecture** — lookup is served by a SQLite file on the kiosk, opened read-only in the kiosk process. No service, no daemon, no socket in the lookup path. Each kiosk builds its own index from the snapshot it imports.
- **Index Structure** (new) — one database file per snapshot generation, self-describing. `equipment` keyed on the normalized serial, declared `WITHOUT ROWID` so a lookup is a single primary-key probe, with the raw serial kept alongside for display; `snapshot_meta` holds schema version, snapshot date, record count, and the manifest fingerprint. Notes that at 90,000 records the working set stays in page cache, so the 250 ms goal has headroom.
- **Snapshot Import** — now an ordered five-step sequence (verify signature → reject schema version → stream and index into staging → reject duplicates/count mismatch → activate), with uniqueness enforced on the *normalized* key, since that is what lookup probes.
- **Activation and Rollback** (new) — pointer file swapped by write-temp-then-rename, one generation retained for rollback, startup integrity check with fallback to the retained generation.
- **Lookup Behavior** — trimming and ASCII uppercasing, punctuation significant, `serial_display` returned from the record.
- **Decisions & Alternatives** — four rows, including the backend choice with both rejected alternatives and the cost accepted (each kiosk rebuilds its own index).

**`docs/high-level-design.md`** — one line: "Its private lookup backend remains open" → "Its lookup backend is private to the node." That line was the only HLD text this choice made stale.

**Certificates** — no cascade. Its LLD already says backend configuration, query syntax, and storage paths are invisible to it, and that is still true.

On recording the choice: I put it in the Decisions table rather than offering a decision doc. You went back and forth, but as it lands a cold reader hits your HLD tenet — no runtime network access — and the other two options are already ruled out before they weigh them; that reads as settled, not live. Say the word if you'd rather have the full doc.

## Edge-case probe

A blind subagent probed the drafted LLD and returned 17 gaps. Five need your call:

1. **What does `findBySerial` return when no generation opens, or on a kiosk's first boot before any import?** Architecture fixes the result to `Found` or `NotFound`, but Activation says unavailable lookup must not return `NotFound` — so the interface needs a third case, or an error. Which?
2. **When does a running kiosk start serving a snapshot that was just imported?** Re-read the pointer per lookup, or only on restart? Restart is simpler; per-lookup means the technician who inserted the USB stick sees the new data without being told to reboot.
3. **A malformed record — bad JSON line, missing description, unparseable date.** Reject the whole import, or skip the record and import the rest? I'd reject the whole thing (it keeps "the inventory team owns corrections" true), but that makes one bad row block all six kiosks.
4. **May a kiosk import a snapshot older than the one it's running?** Nothing currently stops it, and it would silently move every lookup result backwards.
5. **How exact is normalization?** ASCII uppercasing and surrounding-whitespace trimming are specified, but non-ASCII characters, non-breaking spaces, and internal whitespace aren't — and import dedup and the lookup probe have to use byte-identical rules or the uniqueness guarantee breaks.

The other twelve are ones I'd fold into the LLD as drafted decisions unless you want them to go differently: duplicate detection reported as an insert-time step-3 failure; a typed import-outcome shape instead of prose errors; what the pointer says after a fallback; empty-string serial key; staging cleanup after power loss; peak disk footprint and `ENOSPC`; integrity-check cost and whether lookup is blocked during it; the retained generation's schema version after a kiosk software upgrade; import serialization; whether the manifest fingerprint is ever re-checked; whether the record count is signed data; and whether the signature covers the record bytes as well as the manifest.

Nothing has gone to EARS yet — `REG-003` and `REG-004` will both need revision in Phase 3, since import ordering and rollback now have real substance. Reply with numbered feedback, or approve to move to Phase 3.