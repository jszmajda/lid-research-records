The registry LLD is drafted around your selection, the HLD's now-stale "backend remains open" line is updated, and the Phase 2 edge-case probe is complete. This is the Phase 2 stop — please review before I move on to EARS.

**One thing worth naming:** recorded in the Decisions table, the two network options (HTTPS directory, managed search service) both conflict with the HLD's existing tenet — "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted." So while the options looked close, the offline tenet settles the choice; I recorded it as a Decisions & Alternatives row rather than a full decision doc. If you'd like the fuller record anyway, say so.

The certificates node needs no change — `findBySerial` and the result types are untouched, so no cross-segment cascade.

---

## Drafted LLD: `docs/intent/registry/registry-design.md`

> ---
> parent: high-level-design
> prefix: REG
> ---
>
> # Registry Design
>
> ## Context
>
> Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. The kiosk has no runtime network route; the snapshot delivered on approved USB media is the only registry data source.
>
> ## Architecture
>
> Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of storage. The certificates node uses only this interface.
>
> The lookup backend is an embedded SQLite database owned entirely by this node. Each validated snapshot is parsed and loaded into a newly built SQLite file, and lookups read that kiosk-local file only. No service, network route, or external process participates in validation, build, or lookup.
>
> ## Snapshot Import
>
> Import runs in three ordered stages. A failure at any stage leaves the previous snapshot active and reports a stage-specific error.
>
> 1. **Validate** — verify the signature manifest against the bundled public key, reject unsupported schema versions, and check every record's serial number for uniqueness, comparing normalized forms.
> 2. **Build** — parse the newline-delimited JSON and load it into a new SQLite file in the registry data directory: a `records` table keyed by normalized serial, plus a `metadata` table holding the snapshot date and schema version. The build writes to a generation-specific filename and never touches the active file.
> 3. **Activate** — atomically swap the active pointer (a `current` symlink) so subsequent lookups resolve to the new generation. A failed or interrupted import leaves the pointer untouched.
>
> The previous generation is retained until the next successful import completes, so the last valid snapshot survives a failed or interrupted import. Generation files from failed builds are discarded before the next import begins.
>
> ## Lookup Behavior
>
> Normalize surrounding whitespace and uppercase ASCII letters before lookup; serial-number punctuation remains significant. The normalized serial is the lookup key, resolved as a single indexed equality probe against the active generation. The snapshot date comes from the active generation's `metadata` table and is returned in the result, including on NotFound.
>
> ## Decisions & Alternatives
>
> | Decision | Chosen | Alternatives Considered | Rationale |
> |---|---|---|---|
> | Lookup backend | Embedded SQLite index built per kiosk from each validated snapshot | On-site HTTPS directory; managed search service | Lookup-time network access conflicts with the HLD's no-runtime-network tenet, which eliminates both network options; SQLite also keeps validation, rebuild, and lookup inside this node with predictable local performance and no service to operate. |
> | Activation mechanism | Generation files plus an atomically swapped `current` pointer | In-place table swap inside one database | File-level swap makes activation a single atomic operation and keeps the previous generation intact as an instant fallback. |
> | Lookup key | Normalized serial stored as the table key | Raw serial with query-time normalization | Normalization is deterministic, so storing the normalized form makes each lookup a single index probe. |
>
> ## References
>
> - HLD: `docs/high-level-design.md` (tenets: offline lookup, failed imports must leave the last valid snapshot active)
> - Consumer: `docs/intent/certificates/certificates-design.md` — depends only on `findBySerial` and the fixed result types.

**HLD change** (one line): the registry architecture entry now reads "Owns snapshot validation and lookup, served from a kiosk-local SQLite index rebuilt from each validated snapshot (decision recorded in the registry LLD)."

---

## Edge-case probe — gaps for your triage

The probe found 12 gaps. For each: fix in the LLD now, or defer (they'd land in Open Questions)? My suggested triage is marked.

1. **No active snapshot** (first boot / wiped storage) — what does `findBySerial` return, and what does "retain the active snapshot" mean when there is none? *(suggest: fix — REG-002 is undefined here)*
2. **Crash mid-build or mid-activate, then restart** — how is a partial generation file distinguished from a complete one; is a dangling `current` symlink detected? *(suggest: fix)*
3. **Lookup in flight across the symlink swap** — must a record and its snapshot date come from the same generation? *(suggest: fix — one line)*
4. **Well-signed but malformed records** — missing fields, wrong types, serial that normalizes to empty. No stage owns record-level schema validation. *(suggest: fix — decide reject-at-import vs. trust-the-signer)*
5. **What the signature binds** — full payload, per-record, or metadata alone? *(suggest: fix — one line)*
6. **Disk exhaustion mid-build; is the 150 MB NDJSON parse streamed or in memory?** *(suggest: fix — streaming, on a 4 GB kiosk with ~3 concurrent files)*
7. **Error shape of "stage-specific error"** — no taxonomy defined. *(suggest: defer to implementation, spec the stage + message, not the types)*
8. **What "supported schema version" means** — allowlist vs. upper bound, and whether version constrains record layout. *(suggest: fix — one line; suggest allowlist)*
9. **Failure of the activate step itself** (rename fails, `current` missing). *(suggest: fix — failure = import fails, old generation continues)*
10. **Cleanup failure** (discarding failed-build files, deleting superseded generation). *(suggest: defer — best-effort, doesn't affect correctness)*
11. **Validly signed snapshot with zero records** — activatable or rejected? *(suggest: fix — one line)*
12. **Empty normalized key at lookup, or corrupt SQLite file** — no input-error or corruption behavior specified. *(suggest: split — empty key: fix; corruption detection: defer)*

Please give numbered feedback on the LLD, and triage the gaps (or say "take your suggestions"). After your approval I'll fold in the triaged fixes and move to Phase 3 (EARS update for the registry segment).