The probe is back. Here is the Phase 2 stop.

---

## Phase 2 — record-store LLD completed around whole-visit revisions

I've rewritten `docs/intent/record-store/record-store-design.md` to close the open concurrency choice. The shape:

- **Revision model** — a visit is a set of immutable revisions; each names the **base revision** it was edited from (absent only on the visit's first submission). Lineage, not arrival order, decides outcomes: a submission whose base is a head *extends* that line; a submission whose base already has a child *branches* into a competing head. A visit with one head has a **current revision**; a visit with >1 head is **unresolved**.
- **Submission envelope** — visit UUID, base revision ID, author, idempotency key, full field payload. The two idempotency rejections and an unknown-base rejection are specified.
- **Resolution** — a coordinator selects one competing revision as current; the others are retained as superseded history. No server-side field stitching — that's the whole-visit boundary you chose.
- **Downstream contract** — spelled out for tablet-sync (retain/send base revision IDs; surface unresolved status) and review-export (comparison screen from competing revisions; hold unresolved visits out of the CSV).
- **Decisions & Alternatives** records the four choices (policy, concurrency signal, resolution mechanics, preservation) with the field-aware-merge rejection and your rationale.

I have **not** touched the EARS specs yet — that's Phase 3, after this stop.

## Decision-doc offer

The concurrency choice clears the bar for a full decision doc: two credible options traded against several criteria (review workload, implementation burden, *silent combination of scientifically related edits*), with two downstream nodes about to be sized around the result — a cold reader a season from now would otherwise re-litigate "why not auto-merge the disjoint fields?" I'd put it at `docs/intent/record-store/decisions/concurrency-policy.md` and link it from the Decisions row.

**Q0.** Write the decision doc, or leave just the Decisions & Alternatives row (already in the LLD)?

## Edge-case probe — your triage

The delegated probe surfaced real internal gaps. I'd like to **fix these wording/invariant points now** (they're precision, not forks) unless you object:

- **A1.** Branch rule: make explicit that when a base already has a child, the new revision is an *additional head* and the earlier child does **not** thereby become authoritative — both are competing heads, the visit is unresolved, and server processing order never picks a winner. (Closes the probe's sharpest ordering concern.)
- **A2.** Invariants: every visit always has ≥1 head (zero-heads is impossible); the base graph is a tree, so cycles can't form (the revision ID is assigned *after* its base is named); acceptance and child-linking are atomic; idempotency-key handling is serialized per key.
- **A3.** Fix "the others are marked superseded" → "the other **competing** revisions" (internal non-head ancestors were already non-heads — retained history, not newly superseded).
- **A4.** Retrieval contract: pin the response shapes — unresolved returns the flag + competing revisions with no current-revision field; distinguish a never-submitted UUID from an existing visit; and give the three rejections (unknown base / key-reuse-different-payload / failed validation) distinct shapes.

And these are **genuine design calls I shouldn't make for you** — my lean noted, please rule:

- **Q1. Is resolution reversible?** A coordinator picks the wrong revision — can they re-open / re-resolve? *Lean: yes, recorded as a new resolution with the prior retained — the "keep the path inspectable" and "don't discard" tenets push toward reversible.*
- **Q2. Idempotency-key scope and "identical payload."** *Lean: key unique per (visit, author); "identical" = the field payload + base revision, excluding server-assigned fields.*
- **Q3. Interim policy for a submission based on an already-superseded revision** (your Deferred Q2 is the *real* round-trip decision with tablet-sync; this is just what the server does meanwhile). *Lean: reject as stale for now, so the LLD is fully defined today.*
- **Q4. Max competing heads.** The normative design permits any number ≥2; the deferred item is only about an *optional* later cap. *Lean: confirm no cap in v1 — I'll make the doc read consistently either way.*
- **Q5. Plot re-validation at resolution time** (catalog may have archived the plot since submission). *Lean: validate at submission only; resolution just selects an already-validated revision.*

Reply by number. Once this LLD is settled I'll move to Phase 3 (EARS) — including refining REC-005/006 and adding specs for the revision model, branch detection, and resolution.