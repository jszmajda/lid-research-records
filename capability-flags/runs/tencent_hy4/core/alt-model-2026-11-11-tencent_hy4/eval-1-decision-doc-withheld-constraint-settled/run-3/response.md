I've made the file changes. Now I'll compose the Phase 2 stop response (coherence pre-flight report, the phase output in full, the probe gap list, and the decisions I must not settle myself).

---

Resumption coherence pre-flight — the HLD, both LLDs, and the REG/CERT specs were mutually coherent, but three spots carried now-stale "open" language: the HLD's *"Its private lookup backend remains open,"* the registry LLD's *"The lookup backend is not selected yet. Candidates are…"*, and its *"The concrete index and query path remain open pending the user's choice."* I cleared all three and drafted the registry LLD around the local SQLite index. `REG-001`–`REG-004` are backend-agnostic and still hold; no tests or code exist yet (all specs are `[ ]` active gaps, consistent with a design-stage segment). No cross-segment cascade: all three options kept the `findBySerial` result type and certificate interface unchanged, so the certificates segment is untouched. I did no EARS, test, or code work.

**Phase 2 output — finished `docs/intent/registry/registry-design.md`** (fresh-authored; rejected alternatives live in the Decisions table, not the prose):

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Snapshots arrive on approved USB media; kiosks have no network route during normal operation.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed. The certificates node uses only this interface and has no visibility into how lookup is implemented.

Lookup is served by a local embedded SQLite index built from the active signed snapshot. The index is a derived artifact: each kiosk builds and validates its own index when a snapshot arrives. Snapshot validation, index preparation, and lookup all belong to this node; nothing outside it reads the index or the snapshot files directly.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. After validation succeeds, build a new SQLite index from every record in the snapshot into a staging location. Keep the active index queryable throughout the build. Activate the new index atomically only after the build and validation both succeed, so no partially imported snapshot is ever exposed. On any failure, discard the staging index and retain the active one, reporting a useful error.

The snapshot date carried in results comes from the snapshot metadata, not from the time the index was built.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup; serial-number punctuation remains significant. Apply the same normalization to stored index keys at build time and to the query at lookup time. Query the active index and return the snapshot date even when no matching record exists. Lookups read only local files and require no runtime network access.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index, built and validated per kiosk from each signed snapshot | On-site HTTPS directory; managed search service | Kiosks have no network route during normal operation, so a runtime dependency on a lab directory service or an external search service is unavailable. A local index gives predictable lookup latency with no service to operate and keeps validation, rebuild, and query inside this node; the fixed `findBySerial` result type leaves the certificates interface unchanged. The cost is that each kiosk validates and rebuilds its own index on every snapshot; this is accepted. |

## Open Questions & Future Decisions

### Resolved

1. ✅ Lookup is served by a local embedded SQLite index; the certificate interface and result type are unchanged.

## References

- docs/high-level-design.md
- docs/intent/certificates/certificates-design.md — consumes `findBySerial`.
```

`docs/high-level-design.md` line 13 now reads: *"Owns snapshot validation and serial-number lookup; its lookup backend is an internal detail of this node."*

**LLD-level edge-case probe — to triage (fix now in the LLD vs. defer as open questions):**
1. "Validate its own index" is undefined: does it mean re-validating snapshot records, an integrity check on the built SQLite file, or both?
2. Is the index rebuilt in full on every snapshot or refreshed incrementally, and what is the rebuild-time budget against the 250 ms lookup / 150 MB snapshot goals?
3. On-disk layout of the active vs. staging index, and whether the derived index persists across kiosk restarts or is rebuilt on boot.
4. The import-failure error's shape and content (REG-003 requires "a useful error"; no shape is specified).
5. Whether a snapshot import may run while a lookup is in flight, and what the lookup sees during the atomic swap.

**I'm stopping at the Phase 2 boundary** — "finish the design" still walks the arrow phase by phase, so I haven't written specs, tests, or code. Four things I need from you before Phase 3 (reply with numbered notes and I'll incorporate them):

1. **Decision doc?** I recorded the choice as a Decisions & Alternatives row in the registry LLD but wrote no decision doc — I won't make that call for you. The heuristic is genuinely borderline: *against* a doc, the choice is confined to the registry node and the HLD's no-runtime-network-access tenet already narrows the field, and a long debate earns a doc on its own ("however long the debate ran"); *for* a doc, three credible options traded against several criteria and the rest of the registry arrow (specs, tests, code) is about to be sized around the result. Do you want (a) a full decision doc at `docs/intent/registry/decisions/`, linked from that row, or (b) the row alone? I'll write the doc only if you accept.
2. **Tenet lean.** The rationale leans on "prefer self-contained, offline mechanisms over ones that add a runtime network/service dependency." The HLD's `## Tenets` entries currently read as fixed rules/specs rather than one-line leans. Should I set that lean as a tenet (and reframe the rule-like lines into leans), or leave the Tenets section as-is? I won't reframe it on my own.
3. **Gap triage** for the five probe items above: which to resolve in the LLD now, which to defer.
4. **Approval to proceed** past this stop. On your explicit go-ahead I'll run Phase 3 (new EARS specs for index validation/rebuild + the post-draft consistency report), then the Phase 4 intent-narrowing edge audit, then tests-first and code — pausing at each boundary.