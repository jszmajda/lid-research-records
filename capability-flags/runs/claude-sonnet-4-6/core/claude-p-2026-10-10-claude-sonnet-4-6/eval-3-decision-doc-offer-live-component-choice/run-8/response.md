Here is the updated LLD for your review — Phase 2 stop.

---

## Record Store LLD — draft for review

**What changed from the prior sketch:**

The open design choice is closed: whole-visit revisions. The LLD now carries the full contract the downstream nodes need.

**New sections added:**

- **Revision Model** — defines revision_id, base_revision_id, head advancement, and what makes a submission "clean" vs. "competing"
- **Visit States** — `open` / `conflicted` / `resolved`, with export eligibility for each
- **Public Contract** — four tables: submission envelope, acceptance response, current-state response, and conflict review operation
- **Decisions & Alternatives** — concurrency policy, null-base sentinel, and first-release coordinator actions recorded

**Key contract details worth reading carefully:**

- `base_revision_id = null` means "first submission to this visit." A null base against a visit that already has revisions creates a competing revision (conflict), not a new visit.
- Tablet-sync will store `head_revision_id` from the acceptance response and use it as `base_revision_id` on the next edit.
- The acceptance response returns `"open"` or `"conflicted"` — never `"resolved"`. A tablet learns it has a competing revision from the `conflicted` state in the response.
- The conflict review operation is idempotent: re-selecting the current head on a visit with no conflict returns `"open"`.

---

## LLD-level edge-case probe

These are the gaps I found. Please triage which to fix in the LLD now vs. defer.

1. **Concurrent coordinator resolution** (Deferred-1 in the LLD): two coordinators simultaneously resolve the same conflict with different selections — last write wins. Worth a locking note or explicit "last write wins" spec if coordinators are likely to share a queue.
2. **Coordinator rejection** (Deferred-2): no state is defined for "neither competing revision is field-correct." If this is a real workflow the coordinators use, it needs a state and an operation.
3. **Competing revisions against an already-conflicted visit**: a worker submits with base = a *competing* revision_id (not the head). The LLD says any non-head base creates a competing revision — this case is covered, but the resolution operation then has more than two competing revisions to show. The review interface needs to handle an arbitrary number. Worth confirming that's acceptable before review-export is designed.
4. **Visit not found**: the current-state and history endpoints have no specified 404 behavior. Minor — probably obvious — but worth a spec line.
5. **Clean submission after resolution**: a worker submits against the resolved head — visit moves to `open`. The `resolved` status is permanently lost even though a coordinator was involved. If audit trails matter here, this transition should be considered.

---

## Decision doc offer

The whole-visit vs. field-aware-merge choice passes the "cold reader would re-litigate it" test: credible options, traded against real criteria, and tablet-sync and review-export will be sized around the result. I can write a short decision doc at `docs/intent/record-store/decisions/concurrency-policy.md` to capture the tradeoff for future readers. The Decisions & Alternatives row already records it; the doc would add the fuller option-vs-criteria breakdown. Want one, or is the row enough?

---

Ready to proceed to Phase 3 (EARS specs) once you've reviewed the LLD and triaged the probe gaps. What needs to change?