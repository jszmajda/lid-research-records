The registry design is finished around the SQLite choice — here's the Phase 2 review.

**Backend decision (recorded as a Decisions row, no separate decision doc):** the local embedded SQLite index wins on an inherited constraint — the HLD tenet *no runtime network access* disqualifies both alternatives outright, so I recorded it as a table row rather than offering a decision doc. Rationale and the two rejections are written into `docs/intent/registry/registry-design.md`.

**What the finalized LLD now says:**
- **Architecture** — SQLite index embedded in the kiosk app process; per-kiosk rebuild per snapshot accepted (USB cadence, not continuous).
- **Snapshot Import** — a build-and-swap: validate → build a fresh index file in staging → atomic rename to activate. Any failure discards staging, keeps the last snapshot active, and reports the failed stage and reason. Lookups never block during an import.
- **Lookup Behavior** — normalized serial column with a unique index, so a lookup is one indexed equality query within the 250 ms goal; snapshot date returned on Found and NotFound.

**Edge-case probe findings** (delegated blind reader; 15 gaps). The build-and-swap design resolves several — mid-import lookups (3, 12) and partial activation (4) — but these need your triage on whether to fix in the LLD now or defer:

1. Truncated/malformed JSON record — reject whole import or skip the record?
2. Older snapshot than the active one — reject, warn, or allow? *(listed under Open Questions)*
3. Snapshot date missing/malformed — I added it to validation; confirm.
4. Error presentation to the technician — taxonomy or single message? *(Open Questions)*
5. Empty snapshot (zero records) — valid activation or rejection? *(Open Questions)*
6. Serial uniqueness — raw or normalized? I wrote "unique after normalization"; confirm.
7. Cold start with no/corrupt active index — what does `findBySerial` return when nothing is active? `NotFound(snapshotDate)` currently assumes a snapshot always exists.
8. Bad input to `findBySerial` (empty string, control characters) — no result shape defined.
9. Key rotation for the bundled public key; multiple snapshots on one USB stick.

**One flag to check yourself:** the model behind me is on the capability-flags list as untested, so treat every flag as applying — please personally check the import state machine and the cold-start story (gaps 7–8) against the HLD tenet *a failed import must leave the last valid snapshot available*; that's the kind of contradiction I'm known to miss.

**Next after your review:** Phase 3 — draft the EARS spec updates covering the import stages, swap, and lookup semantics, with a consistency report. How would you like gaps 1–9 handled: fix them into the LLD now, defer some as Open Questions, or proceed to Phase 3 as written?