Coherence pre-flight (resumption) — I checked the registry segment against the HLD before drafting. REG-001..004 trace cleanly to the LLD; there are no tests or code yet (all specs are active gaps). Drift found and fixed first: the LLD listed three backend candidates, two of which (on-site HTTPS directory, managed search service) require runtime network access that the HLD tenet *"no runtime network access is permitted"* forbids, and the HLD carried a stale *"Its private lookup backend remains open"* clause.

**How I recorded the choice (no question for you on this):** I ran the landed-state test. The no-network tenet is an inherited constraint that eliminates both service-backed candidates, and the choice affects only the registry node (certificates keep the same lookup result and interface). That is exactly the case the skill says gets a **Decisions row, not a full decision doc — however long the debate ran**, so I recorded a row and did not offer a doc. The "went back and forth / looked pretty close" is a symptom of the deliberation, not the landed design; from current intent the local index is the only admissible backend.

**Phase 1 (HLD check):** No architectural change — the registry still owns validation and lookup over a private backend. I removed only the stale "remains open" phrase (naming SQLite at the HLD would have put a leaf decision at the wrong attachment level). Tenets already cover this; nothing to re-elicit.

**Phase 2 — finished registry LLD** (written to `docs/intent/registry/registry-design.md`):

```
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Kiosks have no network route during normal operation, so a lookup resolves against storage on the kiosk.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node consumes only this interface; registry storage and query details are invisible to it.

The lookup backend is a local embedded SQLite index built from the active snapshot. Snapshot validation, index construction, and lookup all belong to this node. No service, credential, or network connection is involved in a lookup.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Build a complete SQLite index from the validated records into a staging file. Keep the current active index serving lookups until the new index is fully built and queryable, then activate it in one step. An import failure discards the staging index, leaves the previous snapshot active, and reports a useful error.

## Index Lifecycle

The active snapshot has exactly one corresponding local index. A replacement snapshot produces a new index that replaces the active one only after a successful build. The snapshot date carried on every lookup result comes from the active snapshot's metadata. Lookups and index construction resolve entirely against files on the kiosk.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Query the local SQLite index by normalized serial number. Return the snapshot date even when no matching record exists.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index built at import | On-site HTTPS directory; managed search service | Kiosks have no runtime network route (HLD tenet), so any service-backed lookup is inadmissible. An embedded index keeps snapshot validation, index rebuild, and lookup inside this node with no service to operate, and leaves the certificate interface unchanged. |
```

**LLD-level edge-case probe** (delegated to a blind subagent given only the design text; findings surfaced, not applied — you triage):

1. What happens when `findBySerial` runs before any snapshot is activated (or the index file is missing/corrupt), given `NotFound` must carry a `snapshotDate` from active metadata?
2. What concrete shape does "a useful error" take on import failure, and does it distinguish signature / schema-version / duplicate-serial failures?
3. Are serials checked for uniqueness in raw or normalized form, and does a duplicate abort the whole import or skip one record?
4. If a lookup is in flight when a new index activates "in one step," does it finish against the old or new index, and which `snapshotDate` does it carry?
5. If a second import starts while the first staging index is still building, are imports serialized, is earlier staging discarded, or can two coexist?
6. After a successful swap, what becomes of the previous active index, and does "exactly one corresponding local index" hold if that handling fails?
7. During activation, can a single result pair a record from one snapshot with the other snapshot's date?
8. For a serial with non-ASCII letters, internal whitespace, or only punctuation, which exact characters are uppercased/stripped and what index key is queried?

**Segment boundary:** the certificates LLD/specs are untouched. This decision's substance stays in the registry segment; no cross-segment cascade is warranted, so I did not pause to propagate into certificates. The within-segment EARS cascade is still pending below.

**STOP — Phase 2 boundary.** Nothing has been written to specs, tests, or code; I'm pausing here as the workflow requires. Please:

1. **Approve** the finished registry LLD, or give numbered feedback (I'll revise before cascading).
2. **Triage the probe gaps** — which to fix in the LLD now vs. defer as open questions (deferred items go into an Open Questions section).
3. **Confirm the no-runtime-network tenet still stands** — I've treated it as the deciding constraint. If you actually meant to relax it, two of the sketched options become admissible and I'll redo the Decisions row before anything else lands.
4. **Inspection / specifying instrument:** default is you read each phase output whole at its stop (drafting-then-review), which is what I've done. Say if you'd rather go one concept at a time (elicitation), authorize a zero-context reader or delegated inspector for the stops, or relocate review out-of-band.

On your approval I'll run Phase 3 (EARS cascade: new `REG-xxx` specs for index build/atomic activation, plus a consistency report), Phase 4 (cross-spec intent-narrowing edge audit with blind per-spec divergence probes), then tests-first and code with `@spec` annotations — each with its own stop.