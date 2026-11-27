Phase 2 is drafted and stopped for your review. Here's where things stand.

## Phase 1 — HLD check

No architectural change: whole-visit revisions need no new node and don't move any responsibility between the four. Two lines were written around the choice being open, so they're now stale and I refreshed them:

- record-store's State cell: `Drafted; concurrency choice open` → `Drafted`.
- The paragraph under the table: "Tablet-sync and review-export depend on that node's **unresolved choice** … those two designs **must wait** for its contract" → "…are **sized around** that node's contract". The dependency statement stays; only the pending-ness goes.

## Phase 2 — record-store design

`docs/intent/record-store/record-store-design.md`, rewritten around the choice. The model:

- A visit is a chain of **revisions**, each a complete field set — never a diff — with author, receipt time, and its **base**(s). Revision IDs are per-visit integers in receipt order, so history reads as a legible sequence in a comparison screen.
- A revision is a **head** when nothing names it as a base. One head → the visit is **settled** and that head is the current record. Two or more → **contested**, and the visit has *no* current record until resolved (not a provisional one a caller could mistake for agreed).
- **Submission** carries visit UUID, plot UUID, base revision ID (absent on create), idempotency key, fields. Base on a head extends it; base on anything else adds a head. A submission to an already-contested visit is accepted and retained — a 48-hour-old field correction shouldn't bounce because review timing.
- An **invalid or foreign base revision ID is rejected**, not stored as a head: that's a stale/corrupt tablet record, and admitting it manufactures review work out of a client bug.
- **Resolution** has two forms — *selection* (one head's payload stands) and *composition* (coordinator authors the complete field set). Composition is there because unrelated edits make every head wrong somewhere; selection-only would force a coordinator to drop one of two valid corrections. Both record coordinator identity, resolved head IDs, and form.
- A resolution naming anything other than the exact current head set is **rejected with the current head set returned** — with two coordinators, simultaneous resolution is credible, and this makes them read the edit they hadn't seen.
- Six Decisions & Alternatives rows, including the merge rejection in your terms; three items in Deferred.

Scientific fields are deliberately **opaque** to the concurrency layer beyond type and plot-reference validation — that's the whole point of the option you picked, and it's stated so a cold reader doesn't add field comparison back in.

## Edge-case probe (delegated, blind to this conversation)

It found a genuine self-contradiction in my draft, which I fixed rather than bringing to you: a resolution "names every head it resolves" while `base` was singular, so by the stated head rule the unnamed heads stayed heads and the visit never actually settled. Resolution revisions now take multiple bases, and selection **copies** the chosen payload rather than pointing at it. A pass means no counterexample found, not proof; it said the thinnest areas were rejection shapes and the resolution revision's graph position, and the settled→contested direction was well covered.

Eight gaps remain. My recommended disposition — please override any:

1. **Rejection shapes** — the contract lists only success responses, but the prose implies five distinct rejections. *Recommend: fix in the LLD now*; tablet-sync's retry state machine is sized directly on which rejections are retryable.
2. **Edit based on a head a resolution already superseded** — re-contests the visit under the stated rule, vs. rejection. *Your call*: it's the live tension between "never discard a submitted edit" and coordinators resolving the same visit twice. I lean re-contest.
3. **Idempotent replay of a visit whose state has since changed** — return the original state, or the current one? *Recommend: current state with the original revision ID*, fixed in the LLD.
4. **Idempotency key scope and "identical payload" comparison** — global vs per-visit, and whether observer-list ordering counts. Also: **Resolve has no idempotency key**, so a coordinator's retry on a timeout is undefined. *Recommend: fix both in the LLD.*
5. **Missing base on a visit that already has revisions** — duplicate create, second root, or edit-the-head? *Recommend: reject; one baseless revision per visit as a stated invariant.*
6. **Can an edit change the visit's plot UUID?** *Your call* — is re-pointing a visit to a different plot a legitimate field correction, or is the plot immutable after creation? (Distinct from the archived-plot deferral.)
7. **Authorization** — nothing says only coordinators resolve, or whether a coordinator may submit an ordinary revision. *Your call*, and it touches Deferred #2 (resolving an already-settled visit).
8. **Simultaneous arrivals** — whether the revision sequence is gapless (do rejected submissions consume an ID?) and whether receipt times stay monotonic with IDs, since coordinators read both. *Recommend: fix in the LLD* — gapless, rejections consume nothing.

## Two things that need your judgment

**A decision doc for the concurrency choice?** This one clears the bar: two credible options traded against review workload, implementation burden, and the risk of silently combining scientifically related edits — and tablet-sync and review-export are about to be sized around the result. A cold reader six months from now, staring at a growing review queue, would be tempted to reverse it without seeing what merging would have cost. I've written it as a Decisions row already, which is the alternative; say the word and I'll write `docs/intent/record-store/decisions/concurrent-visit-edits.md` instead and link it from the row.

**Where does the vocabulary live?** `settled`, `contested`, and `head` currently live in record-store, which owns the contract. But tablet-sync and review-export both need these exact words, and LID's rule is that a term a sibling needs rises to the shared ancestor — which would put the definitions in the HLD. I've left them in record-store because the HLD already says siblings link back to this node rather than inventing concurrency semantics, but it's your call and it's cheap to move now, expensive after two more nodes cite it.

Nothing has been cascaded into the specs yet. On your go — plus the triage above and the two calls — I'll take Phase 3 and rewrite `record-store-specs.md`: REC-001 through REC-006 are policy-neutral and survive as-is, and the revision, head-state, resolution-form, and stale-resolution behaviors need new IDs.