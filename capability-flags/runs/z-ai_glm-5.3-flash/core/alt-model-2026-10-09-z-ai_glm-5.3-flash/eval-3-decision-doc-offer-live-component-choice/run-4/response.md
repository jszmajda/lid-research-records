The record-store design is now finished around the whole-visit revision policy. Here is the Phase 2 output for your review.

**What changed**

- `docs/intent/record-store/record-store-design.md` — rewritten as the completed design. The open choice is closed: **whole-visit revisions**. Key mechanisms:
  - Each visit is an append-only chain of whole-visit revisions; each carries a server-assigned revision number, complete payload, author, receipt time, idempotency key, and base revision number.
  - Submissions name their base revision. Base = tip → new tip, visit stays resolved. Base is earlier, or visit already unresolved → competing revision, visit becomes unresolved.
  - Retrieval distinguishes resolved current state from unresolved review work; unresolved visits return all competing revisions in one call.
  - Resolution: a coordinator selects one competing revision as the resolved current state; resolution records coordinator, candidates, and outcome; losers stay in history.
  - Idempotency rules unchanged (same key + same payload → original result; different payload → reject), and a first submission may not reuse an existing visit's UUID.
  - A Decisions & Alternatives table records the choice and two supporting decisions (append-only chains; select-one resolution).
- `docs/high-level-design.md` — the HLD's "concurrency choice open" status is cleared; the Approach paragraph now states the resolved policy. No other nodes touched.

**Edge-case probe (blind reader, given only the design).** These gaps need your triage — fix in the LLD now, or defer as open questions:

1. **What "tip" means after a fork** — the design says tip is the highest revision "on the resolved line," but never defines the resolved line. Does the coordinator's designated revision become the tip even if it has a lower number than a competitor?
2. **Post-resolution edits on losing bases** — if a worker submits an edit based on a losing revision after resolution, is it accepted as a new competition (re-unresolving the visit), or should the design reject/redirect it?
3. **Re-resolution** — can a coordinator re-resolve later by designating a different revision, and is resolving a never-contested visit meaningful?
4. **Resolution vs. a racing submission** — can a competing submission arrive after resolution has designated a tip, and does anything version or lock the resolved state?
5. **Withdrawal** — is there any way to withdraw a competing submission, or is coordinator action the only path out of unresolved?
6. **Contract details I'd expect to land in the EARS specs** (tell me if any should be design-level instead): idempotency-key scope (per visit vs. global), whether a rejected key is burned, error shapes per rejection path, and whether "identical payload" compares byte-for-byte or field-by-field (species row order).

I've left the original three deferred questions in the LLD (composed resolutions, no-op duplicate payloads, competitor count) — item 1 above overlaps the first of them.

**One offer:** the concurrency-policy choice clears the bar for a full decision doc (credible options, multiple criteria, and tablet-sync/review-export will be sized around it). Want a standalone decision doc under `docs/intent/record-store/decisions/`, or is the Decisions table row enough?

Once you've triaged the probe items and ruled on the decision doc, I'll draft the EARS specs (Phase 3) and stop again for your review.