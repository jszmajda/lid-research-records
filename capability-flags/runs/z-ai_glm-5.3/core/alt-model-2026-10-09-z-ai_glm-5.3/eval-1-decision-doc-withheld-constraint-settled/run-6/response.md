Phase 2 (LLD revision) is complete. Here's what changed and what needs your ruling.

**Registry LLD — updated** (`docs/intent/registry/registry-design.md`): The open "backend not selected" section is replaced with the local embedded SQLite index as the chosen backend — each kiosk validates and rebuilds its own index on snapshot arrival, with a staging database built beside the active one and activated by atomic rename only after full validation and build; any failure discards staging and leaves the previous snapshot active. Lookups run as a single indexed equality query on a normalized serial column, with the snapshot date stored as database metadata. A Decisions & Alternatives row records the selection (including why the HTTPS directory and managed service lost: only the local index satisfies the offline-lookup tenet with no runtime network or service dependency). The stale "backend remains open" note in the HLD was updated to match. The certificate interface and existing REG-001…004 specs are untouched — EARS updates for the SQLite-specific behaviors come at Phase 3, after you approve this LLD.

**Edge-case probe — 10 gaps found.** Please triage which to fix in the LLD now vs. defer as open questions:

1. **First run, no snapshot ever imported** — `Found`/`NotFound` both carry a snapshot date; what does a lookup return before any snapshot exists — a distinct error, or an overloaded `NotFound`?
2. **Power loss mid-rebuild** — no crash-recovery rule stated: are orphaned staging databases detected and discarded on next boot; is rename atomicity guaranteed on the kiosk's filesystem?
3. **Corrupt or deleted active index file** — no detection/recovery path; does lookup error, or silently return `NotFound` that was never checked against a valid snapshot?
4. **Disk exhaustion during staging build** — no pre-flight free-space check or error classification for I/O failures (150 MB snapshots; resulting index size unstated).
5. **Lookup during an in-progress import** — presumably served from the active database, but locking/visibility rules between lookup and staging→activation are unstated.
6. **Two snapshots imported in quick succession** — staging-database naming/serialization unspecified; must last-finished or last-started import win?
7. **Malformed individual records inside an otherwise valid snapshot** — only signature, schema version, and uniqueness are validated; is a bad JSON line or missing field a whole-snapshot rejection?
8. **Normalization ambiguity** — "uppercase ASCII letters" leaves non-ASCII serials and non-ASCII whitespace (NBSP, tabs, control characters) undefined; which codepoints count as "punctuation" is unstated.
9. **Snapshot monotonicity** — may an older-dated snapshot replace a newer active one, and how are snapshot dates compared (format/timezone) given callers treat the date as authoritative?
10. **"Reports a useful error"** — the import failure channel and error shape are unspecified; no distinction between caller-recoverable errors and kiosk-operator-alertable failures (bad USB media vs. corrupt index).

**One offer:** this backend choice cleared the bar for a full decision doc — the three options traded against multiple criteria and you found them genuinely close, so a cold reader might be tempted to reverse it. I've recorded it as a Decisions row in the LLD for now; want me to upgrade it to a standalone decision doc under `docs/intent/registry/decisions/` instead?

To proceed I need: (a) your triage of the 10 gaps — fix in LLD vs. defer, (b) yes/no on the decision doc, then approval of the revised LLD so I can move to Phase 3 (EARS updates).