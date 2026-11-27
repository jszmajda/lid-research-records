Done — the registry design is finished for your SQLite choice. Here's what changed, for your review:

**HLD** (`docs/high-level-design.md`): the registry's "backend open" line now names the local embedded SQLite index; everything else untouched.

**Registry LLD** (`docs/intent/registry/registry-design.md`) — key points:
- **Backend**: each validated snapshot is rebuilt into a fresh SQLite file, activated by a single atomic rename. Lookups query the active file directly; no service, no network, no credentials — consistent with the HLD's kiosk-files tenet.
- **Schema**: `instruments(serial TEXT PRIMARY KEY, …)` + a `meta` table holding schema version and snapshot date, so the certificate-visible snapshot date always comes from the index that answered.
- **Normalization**: done in registry code before the query; serials stored canonical, so SQLite matching stays an exact primary-key lookup (well inside the 250 ms goal at 90k records).
- **Decisions & Alternatives**: rows for the backend choice (HTTPS directory fails the offline tenet; managed search adds cost/credentials/connectivity), full-rebuild-per-snapshot vs incremental patching, and where normalization lives.
- **Deferred**: startup integrity check beyond open-failure; journal/WAL settings.

**Specs** (`docs/intent/registry/registry-specs.md`): added **REG-005** (fresh build + atomic rename per import) and **REG-006** (missing/unopenable index → lookup error, never records from another source). REG-001–004 unchanged; the certificates segment needed no cascade.

**Consistency check**: coverage — all LLD behaviors now map to REG-001–006; no contradictions (REG-004/005 compose cleanly); REG-006 states its scope explicitly; no conversation-dependent wording remains.

**LLD probe — what happens when...** (triage: fix in the LLD now, or defer):
1. ...a lookup arrives while a snapshot rebuild is in progress — is kiosk use single-transaction, or should lookups keep serving the old index until the rename?
2. ...the rename target already exists on a filesystem where rename-over isn't atomic — do we pin the deployment OS behavior in the LLD?
3. ...a snapshot record's date fields don't parse — is field-format validation part of import rejection (REG-003), or out of scope?

Please review the LLD and specs above and tell me how you'd like to proceed on the three probe questions. Once you approve, I'll run the Phase 4 intent-narrowing edge audit on the specs, then tests-first.