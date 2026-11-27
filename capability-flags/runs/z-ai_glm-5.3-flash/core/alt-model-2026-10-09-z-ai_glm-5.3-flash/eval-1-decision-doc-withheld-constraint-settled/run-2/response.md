The SQLite choice is now folded into the registry design. Here's the phase output for your review.

## Registry LLD (updated — Phase 2)

`docs/intent/registry/registry-design.md` now records the selected backend and completes the design around it:

- **Architecture** — the lookup backend is a local embedded SQLite index, private to the registry node. One active index file per kiosk, built from the most recent valid snapshot; `findBySerial` queries it, and nothing outside the node touches SQLite storage. The certificates interface is unchanged.
- **Snapshot Import** — validate signature/schema/uniqueness, then build the replacement index in a **staging file**; the active index is never modified in place. Lookups keep serving from the active index during the import. After validation and build succeed, an atomic file swap activates the staged index. Any failure discards staging, keeps the previous index active, reports a useful error.
- **Lookup Behavior** — normalization is unchanged (trim whitespace, uppercase ASCII, punctuation significant). Normalized serials live in an **indexed column** so lookup is an indexed point query, meeting the 250 ms goal at 90,000 records. The snapshot date is read from the active index's metadata, so `NotFound` still carries it.
- **Decisions & Alternatives** — three rows: backend selection (with the HTTPS and managed-service alternatives and why they lost), build-then-swap activation, and the indexed normalized-serial column.

I also updated the HLD's registry line (docs/high-level-design.md:13), which said the backend "remains open" — now it names the SQLite index.

## Registry EARS (updated — Phase 3)

REG-001 through REG-004 are unchanged. Added:

- **REG-005**: When a snapshot import proceeds to index building, the system SHALL build the replacement SQLite index in a staging file and leave the active index unmodified until activation.
- **REG-006**: When a snapshot import fails after index building has begun, the system SHALL discard the staging index and keep the previous index active.
- **REG-007**: While a snapshot import is in progress, the system SHALL continue serving lookups from the active index.

**Consistency report**: every behavior in the LLD maps to a spec (REG-004/005/006/007 cover the import pipeline; REG-001/002 cover lookup; REG-003 covers rejection); no contradictions; scopes are explicit in the WHEN clauses (import-phase specs are scoped to import, not lookup). The indexed-column choice is design mechanism, deliberately left out of the specs.

## LLD-level probe — gaps for your triage

1. **First boot**: a kiosk with no imported snapshot yet — what does `findBySerial` return, and is there a snapshot date at all? I left this as a deferred open question rather than inventing an answer.
2. **Crashed imports**: a crash mid-import can leave a staging file on disk. Should there be a cleanup policy (e.g., delete stale staging files at startup), or is this deferred?
3. **Re-import of the same snapshot**: importing an identical snapshot rebuilds the index from scratch — acceptable, or should we skip rebuild when the manifest matches the active one?

## Decision doc offer

The backend choice was genuinely contested — three credible options traded on cost, network dependency, and maintenance, and the registry's import and lookup machinery is sized around the result. I've recorded it as a Decisions row; if you'd like it as a full decision doc (`docs/intent/registry/decisions/`) so a future reader can re-run the judgment, say so and I'll draft one — otherwise the row stands.

**Please review the LLD and specs above.** On your approval (plus your calls on gaps 1–3 and the decision doc), I'll amend the LLD/specs accordingly and proceed to Phase 5: failing tests first, then implementation.