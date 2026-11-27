This reads context-free. Now I'll stop here and present Phase 1/Phase 2 output plus the probe for the user's review, per the skill's mandatory stop.

## Phase 1 — HLD check

No HLD change needed. The HLD already treats the backend as an internal, unselected detail ("Its private lookup backend remains open") and its tenets already require offline-only operation. The local-SQLite choice is architecture-neutral from the HLD's view.

## Phase 2 — LLD update (`docs/intent/registry/registry-design.md`)

- Architecture: backend finalized as a local embedded SQLite index, rebuilt per-kiosk from the active signed snapshot; stays internal to the Registry node.
- Lookup Behavior: now says lookups query that local SQLite index.
- Added a **Decisions & Alternatives** table with one row recording the choice. Rationale given: it's the only candidate consistent with the HLD's no-runtime-network tenet — the other two candidates needed lab-network or external connectivity the kiosk doesn't have. Given that, I did not offer a full decision doc; an inherited constraint settles this one, which is the skill's bar for a table row instead of a doc. Let me know if you'd rather have the full doc anyway.

## LLD-level edge-case probe (delegated to a blind subagent, given only the LLD text)

Gaps worth triaging before specs/tests are written:

1. Snapshot import succeeds but SQLite index build fails partway (disk full, power loss) after validation but before activation — what state is left active?
2. A lookup request arrives while a new snapshot is validating and the index is rebuilding.
3. The previous snapshot's SQLite index file is deleted/corrupted/missing at startup even though the snapshot is still marked active.
4. Two snapshot imports are triggered concurrently (USB re-inserted mid-import).
5. The rebuilt index disagrees with the source snapshot (e.g., a collision/truncation during index insertion that the JSON-level uniqueness check didn't catch).
6. Kiosk crashes between "activate snapshot" and "mark index as built from this snapshot."
7. Disk space is insufficient to hold both the old and new index during rebuild.
8. Schema version is supported but record field layout changed in a way the SQLite table doesn't account for.
9. `findBySerial` is called before any snapshot has ever been imported — no index exists yet.
10. Signature verification succeeds but the snapshot date is missing, malformed, or earlier than the current active snapshot's date.

Please tell me: (a) any numbered feedback on the LLD edit above, and (b) which of the 10 gaps to resolve now (folded into this LLD) versus defer as open questions — then I'll proceed to Phase 3 (EARS).