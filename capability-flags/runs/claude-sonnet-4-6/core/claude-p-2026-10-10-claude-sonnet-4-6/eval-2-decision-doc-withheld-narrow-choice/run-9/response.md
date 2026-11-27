All three phases are done. Here's the consolidated stop for your review.

---

## Phases 1–3 — Previews Design (2Q), for review

I'm presenting Phases 1–3 together given the clear prior decision. Each phase is labeled below.

---

### Phase 1 — HLD update

One line changed in `docs/high-level-design.md`:

> ~~Its eviction policy remains open.~~ → **managed with a two-queue (2Q) eviction policy.**

---

### Phase 2 — LLD update (`docs/intent/previews/previews-design.md`)

The open-candidates paragraph is gone. The Private Cache section now specifies:

**2Q Eviction**
- **Q1** (FIFO): every new sheet enters here.
- **Qm** (LRU): sheets referenced more than once are promoted here. Promotion is a move — total cache size unchanged.
- **Pre-admission eviction**: a single pass evicts from Q1's tail, then Qm's tail if Q1 is empty, until the sheet fits within *both* the Q1 byte budget and the 12 GiB total. (Probe item 3 — one pass satisfies both constraints simultaneously.)
- **Q1 byte budget**: configurable at startup, default 20% (~2.4 GiB). Must be at least one maximum sheet size; smaller is a misconfiguration. (Probe items 2 and 7.)
- The scan-resistance property is stated explicitly: screening sheets cycle through Q1 without displacing Qm.

**Decisions & Alternatives table** — two rows:
- Eviction policy: 2Q chosen over LRU and frequency-based with aging; rationale recorded.
- Q1 default 20%: rationale (absorbs ~1,200 screening sheets; leaves ~4,800 Qm slots).

**Open Questions** — two deferred items: admission serialization (up to 4 concurrent completions), and concurrent promotion/eviction on the same entry. Both existed implicitly before 2Q; 2Q makes them more visible.

---

### Phase 3 — EARS specs (`docs/intent/previews/previews-specs.md`)

Five new specs added (PREVIEW-006 through PREVIEW-010):

| ID | Summary |
|---|---|
| PREVIEW-006 | New sheet admitted → goes to Q1 |
| PREVIEW-007 | Q1 hit → promote entry to Qm head, then serve |
| PREVIEW-008 | Qm hit → move entry to Qm head, then serve |
| PREVIEW-009 | Eviction pass: Q1 tail first, Qm tail when Q1 empty, loop until sheet fits both budgets |
| PREVIEW-010 | Q1 configurable byte budget (default 20%, ~2.4 GiB), startup-only, min one sheet |

**Consistency report**: no new contradiction with PREVIEW-001–005; PREVIEW-009 refines the ordering implicit in PREVIEW-004 without conflicting with it. All specs read independently (no reliance on section context).

---

**Two things I want your triage on before we move to Phase 4:**

1. **Open Questions**: Should the admission serialization gap be addressed in the LLD now (even if left as "implementation must serialize admission atomically") or left purely deferred? If we leave it silent, any implementer will have to invent the answer.

2. **Q1 budget 20% default**: Correct as a starting point? The sketch said "a size split we'll have to tune" — the default is in the spec now so it will need an explicit change to override. Fine to leave, or should we mark it as provisional?