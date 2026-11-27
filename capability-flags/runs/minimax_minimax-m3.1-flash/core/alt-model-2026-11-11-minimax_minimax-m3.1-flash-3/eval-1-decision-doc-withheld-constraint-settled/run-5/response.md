The registry design is now finished through Phase 4. Two things need your call before I can go further, and one is a fork I found rather than one you raised.

## What changed

**HLD** (`docs/high-level-design.md`) — the backend line now names the local SQLite index; the "snapshot date on every lookup result" goal was corrected, and a new goal distinguishes a failed lookup from an inventory miss.

**Registry LLD** (`docs/intent/registry/registry-design.md`) — rewritten around the SQLite index: two-stage import (validate before touching the index, then build+activate in one transaction), the `records`/`meta` schema, the lookup key derivation, WAL and checkpoint handling, import concurrency, and a Decisions & Alternatives table with the three backends and the reasoning. Open Questions hold five deferred items.

**Registry specs** (`docs/intent/registry/registry-specs.md`) — REG-001–004 kept their IDs and meanings; REG-005–030 added for the behavior the earlier four didn't cover.

## The fork I hit

My first draft added a third result case, `Unavailable(reason)`. A blind-reader audit flagged that this contradicts the HLD's promise of a *fixed* result type, and I agree — a failure isn't an inventory answer. I restructured it: the result type stays `Found(record, snapshotDate)` | `NotFound(snapshotDate)`, and a lookup that can't be answered reports a failure with a reason (`NoSnapshot`, `IndexUnreadable`, `IndexInconsistent`) outside the result type. A miss is a claim the equipment isn't in inventory; a failure is a claim the search couldn't run. Collapsing the second into the first would let a corrupt index produce certificates asserting equipment is absent.

## Two decisions for you

**1. Certificates cascade.** The failure channel crosses into the certificates segment, which currently only handles `Found`/`NotFound` — a corrupt index would silently let export proceed, and an `Unavailable` would be shown as "not found". This crosses a segment boundary, so I stopped rather than edit `certificates-design.md`/`certificates-specs.md`. The prepared change: an `Unavailable` blocks export with the reason shown and no snapshot date, cleared by repeating the lookup for the *same* serial after an import; `CERT-001` needs the serial added to the preview (the certificate shows the inventory's serial, not the typed one); the PDF's snapshot date comes from the `Found` result, not re-read at export.

**2. Deferred open question that now has a spec.** Whether to accept a valid snapshot older than the active one. I wrote REG-029 pinning the current interim rule (accept it, report its date). USB import order isn't guaranteed and the inventory team is authoritative, so rejecting could block a legitimate correction — but an older date on a certificate is visible to a technician. I'd rather you decide than have me lock in either direction.

Say the word on both and I'll run the cascade into certificates and move to Phase 5 (tests first). I have not written any tests or code yet.