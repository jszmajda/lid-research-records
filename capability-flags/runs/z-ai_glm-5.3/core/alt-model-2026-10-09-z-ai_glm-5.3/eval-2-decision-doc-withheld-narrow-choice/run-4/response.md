Phase 1 and Phase 2 are complete and both docs are updated. Here's the full stop for your review before I draft EARS.

## Phase 1 — HLD check

Architecture is unchanged — the HLD already anticipated any eviction policy (fixed interface, private worker state). One stale line fixed in `docs/high-level-design.md:14`: "Its eviction policy remains open" now reads:

> Replacement uses 2Q: new sheets pass through a small probation queue, and only reused sheets reach the main LRU queue, so sequential screenings do not evict comparison sheets.

## Phase 2 — Previews LLD (`docs/intent/previews/previews-design.md`)

The settled policy is recorded as rows in the Decisions & Alternatives table (not a decision doc — the choice is local to this node, and the table carries the alternatives and rationale a cold reader needs). The new **Replacement Policy: 2Q** section:

- **A1 (probation, FIFO)** — every new sheet enters A1; A1 bounded to a configurable fraction of the 12 GiB budget, **default 25% (~3 GiB)**; overflow evicts A1's oldest.
- **Am (main, LRU)** — a hit on an A1 entry promotes it (two uses = comparison clip, not screening one-off); Am hits refresh recency; overflow evicts Am's LRU victim.
- Admission needing space frees A1's FIFO victim first, then Am's LRU victim; the byte bound is authoritative.
- No ghost directory: an A1-evicted entry re-enters as a fresh first use (the re-render is ordinary 202-path behavior). Classic ghost-list 2Q is a recorded rejected alternative.
- Superseded renderer versions age out normally; pending jobs hold no queue position.

Decisions rows cover: policy (vs. LRU, frequency-with-aging), 2Q variant (vs. ghost list), A1 split (25% tunable), and policy-state privacy. Deferred open questions: tuning the A1 fraction from pilot data, and whether a pending-time hit counts toward promotion (currently: no).

## Edge-case probe (delegated; please triage)

Ten gaps found. My proposed disposition:

**Fix in the LLD now** (narrow, one natural reading each — I'll add a line per item on your OK):
3. Precedence between the per-queue eviction rules and the global admission order (promotion evicts only Am's LRU victim; admission drains A1 first, then Am).
4. Hit racing an eviction — propose: eviction wins, the request falls to the miss path and re-renders.
5. Promotion is an atomic, debit-free move within the shared budget (no double-counting).
6. Failed renders leave no trace — first successful admission is the first use.
7. Am-evicted sheets also re-enter A1 as probationers (symmetric with A1 eviction).
10. A1 fraction has a floor: at least one sheet.

**Needs your call** (real forks I won't settle alone):
1. What ticket-holders see when their pending job **fails** — new ticket on next request? 5xx? (Only "release the dedup entry" is specified; PREVIEW-005 will need a companion.)
2. Precise definition of a **"hit"** for promotion (does any 200-served request count? aborted requests?).

**Defer**: 9 (temp-output bound and crash-recovery cleanup — negligible at ~2 MiB × 4 jobs). **Already settled by PREVIEW-001**: 8 (404 is determined before enqueuing).

Please confirm: (a) the LLD as written — especially the no-ghost variant and the 25% A1 default; (b) the triage above — apply the five "fix now" items, and give me your reading on gaps 1 and 2; (c) then I'll proceed to Phase 3 EARS (new 2Q specs plus the gap-1/2 companions).