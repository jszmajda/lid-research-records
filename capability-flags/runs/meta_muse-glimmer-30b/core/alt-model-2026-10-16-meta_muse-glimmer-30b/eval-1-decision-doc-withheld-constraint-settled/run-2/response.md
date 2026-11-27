Phase 1 – HLD check
The HLD at docs/high-level-design.md is coherent with the change. Tenets require offline lookup, no network, failed import leaves last valid snapshot, and certificates must not read storage directly. Selecting a local embedded SQLite index satisfies those constraints and does not alter the HLD architecture. No HLD edits needed.

Phase 2 – LLD updated
Registry LLD rewritten to context-free form with the SQLite decision recorded. Key updates in docs/intent/registry/registry-design.md:
- Architecture now states lookup is backed by a local embedded SQLite index rebuilt from the active snapshot on each kiosk.
- Snapshot Import describes signature verification, schema check, uniqueness validation, build in temp location, atomic activation.
- Lookup Behavior retains normalization and snapshot-date return.
- Decisions & Alternatives table records the chosen local SQLite index vs on-site HTTPS directory and managed search service, with rationale tied to offline operation and the 250 ms goal.
- Open Questions & Future Decisions moved the backend selection to Resolved and deferred SQLite schema, build performance budget, and old snapshot retention.

LLD-level edge-case probe for this node:
1. What happens when the SQLite index build fails mid-way due to disk full or power loss?
2. What happens if two snapshots are presented for import concurrently?
3. What happens if the active SQLite file becomes corrupted between imports?
4. What happens when normalization of whitespace/case creates a collision that did not exist in the raw data?
5. What happens on lookup while a new index is being built – is the old index still served?
6. What happens when a serial contains non-ASCII letters – is normalization defined?
7. What happens if snapshot date is missing or malformed in the manifest?

Please review the updated LLD and triage which of the edge cases to address in the design now vs defer. On approval, I will proceed to Phase 3 – EARS spec draft/update with post-draft consistency verification and then stop for your review.