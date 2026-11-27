**Phase 1 — HLD updated** (`docs/high-level-design.md`): Approach and Architecture now state that each kiosk builds a local index over the snapshot it imports, so lookup needs no network and no running service. The "backend remains open" line is gone. The offline tenet already covered this choice, so the decision row lives in the registry LLD (its substance is registry-internal), not in a new HLD decisions section.

**Phase 2 — Registry LLD rewritten** (`docs/intent/registry/registry-design.md`): local embedded SQLite index, built per import from the signed snapshot. Sections now cover kiosk artifacts and the active pointer, the three-stage import (Accept / Build / Activate) with the pointer replacement as the commit point, index schema and exact normalization rule, lookup behavior, rebuild-from-retained-snapshot, and performance. Six Decisions rows record the backend choice (with the HTTPS directory and managed service as the rejected alternatives) plus rebuild, activation, key, and retention choices. The HLD's offline tenet settles the backend choice, so I did not add a decision doc.

A delegated edge-case probe of the LLD surfaced 11 gaps. I closed the mechanical ones in the doc (pointer representation and durability, activation crash states and startup reconciliation, rebuild workflow, field/date formats, snapshot-date provenance, index↔snapshot invariants, normalization edges). Six remain genuine forks, recorded under "Open Questions" and needing your call:

1. **Lookup outcome shape** — keep `Found`/`NotFound` and raise failures as errors, or add an outcome for "no usable index"? (A third outcome would touch the certificates segment, so I'd pause there.)
2. **Damaged/missing index** — self-heal by rebuilding from the retained snapshot, or report and wait for a technician?
3. **Import concurrency** — one foreground import at a time, or unattended imports that must survive interruption and re-run?
4. **Older snapshot** — reject a snapshot not newer than the active one, or last-import-wins?
5. **Returned serial** — the snapshot's original spelling, or the normalized form?
6. **Invalid record** — fail the whole import, or skip and count?

Also deferred to the snapshot-format work: the field-level rules of a snapshot record and the size/record-count limits beyond 90,000 records and 150 MB.

How do you want 1–6 resolved? Once you rule, I'll cascade into the registry EARS specs (REG-001–004) and pause there for review.