Decision doc written and linked from the Decisions & Alternatives row. It lives at `docs/intent/record-store/decisions/concurrent-edit-policy.md`:

> ```
> # Decision: Concurrent Visit Edits — Whole-Visit Revisions
>
> ## Context
> Field tablets can be offline for up to 48 hours, and workers sometimes correct
> the same visit independently after comparing field notes. The record store must
> define what happens when edits derived from different starting states of the
> same visit arrive: which edit becomes the current record, and what a
> coordinator must review. The spreadsheet process this project replaces resolves
> the same situation by overwriting — the quiet loss of a submitted correction
> is the problem the HLD names.
>
> Two edits to the same visit may touch unrelated fields (an observer-name
> correction and a missing species) or scientifically related ones (a species-
> identification revision and the cover estimate taken under the old
> identification). Which edits interact is botanical judgment: the server can
> detect that two submissions overlap a field, but not that two disjoint edits
> interact scientifically. This decision selects the concurrency policy;
> tablet-sync and review-export are sized around its outcome.
>
> ## Decision Elements
> Gate (inherited): No submitted edit is silently discarded (HLD tenet) — a
> policy that overwrites a submission's effect without retention and without
> review is eliminated.
>
> Weighted criteria:
> - No unreviewed combination of scientifically related edits (major) —
>   combining automatically requires judging field relatedness, and the
>   Non-Goals exclude inferring scientific intent.
> - Review volume within two coordinators' weekly capacity (major).
> - Provenance inspectability (major; HLD tenet).
> - Maintenance burden (moderate).
> - Correction latency for field workers (moderate).
> - Export completeness (moderate).
>
> ## Options in the Domain
> Last-write-wins overwrite — eliminated at the gate (the spreadsheet status quo).
>
> Whole-visit revisions — complete-payload submissions naming a base revision;
> divergent edits retained as competing revisions; coordinator selects; the
> server never combines content.
>   No unreviewed combination: strong. Review volume: weak. Provenance: strong.
>   Maintenance: strong. Latency: partial. Export completeness: weak.
>   Summary: trades review volume and export completeness for never
>   auto-combining and near-zero rule maintenance.
>
> Field-aware three-way merge — base state + structured field changes;
> disjoint edits auto-combine, overlaps queue. At its best, both workers' work
> lands without coordinator involvement. Demonstrated failure it must not have:
> A reidentifies species X; B corrects X's cover estimate; the fields are
> disjoint so the rules combine them — A's new identification paired with B's
> cover taken under the old identification, a record no worker observed, no
> signal to anyone. Catching that requires the rules to encode that a cover
> estimate belongs to its identification — one instance of the per-field-type
> knowledge the rule set must carry.
>   No unreviewed combination: weak. Review volume: strong. Provenance:
>   partial (composites). Maintenance: weak. Latency: strong. Export
>   completeness: strong.
>   Summary: trades rule maintenance and unreviewed combinations for minimal
>   review volume.
>
> Approval-gated merge — field-aware merge, but every auto-combined record
> waits for coordinator approval. Answers the silent-combination objection, but
> keeps the full rule set while restoring most of the review volume, in
> field-level detail — it pays both costs.
>
> ## Selection
> Whole-visit revisions. The criteria merge wins on — review volume, latency,
> export completeness — all presuppose the rules combine only edits that are
> safe to combine, and producing that presupposition requires exactly the
> judgment the project excludes (Non-Goal: no inference of scientific intent).
> The team weighed a larger review queue against maintained rules that could
> silently produce scientifically wrong records, and chose the queue. The
> approval-gated variant is not a middle path.
>
> Committing forecloses automatic application of any concurrent edit: every
> collision, however trivially unrelated, costs coordinator time and can hold a
> visit out of a Friday export.
>
> What the downstream designs must accommodate:
> - Tablet-sync: retain each visit's current revision number as the edit base;
>   submit complete payloads (no deltas, no base snapshots); treat "retained as
>   competing revision" as a visible outcome, not an error; expect a worker's
>   colliding edit to sit pending for days.
> - Review-export: a comparison screen (competing complete revisions vs.
>   current); hold unresolved visits out of the CSV; surface review-queue
>   depth — a chronically growing queue is the signal to re-run this decision;
>   expect Friday exports that legitimately omit unresolved visits, with the
>   omissions visible to the science partner rather than hidden.
>
> Re-running this decision: field-aware merge (with or without the approval
> gate) becomes right if (1) review volume demonstrably exceeds what two
> coordinators can clear weekly — a queue that grows across weeks and presses
> against the Friday deadline — and (2) the team can maintain per-field-type
> rules with scientific oversight, so rule changes are reviewable by the
> coordinators rather than implicit in code. A narrower move short of reversal:
> an explicitly safe field pair (e.g., observer-list corrections) could later be
> merged with coordinator approval as a carve-out, without reopening the policy.
> ```

Still open from the Phase 2 stop:

1. **Gap triage** — the 12 probe questions. My suggested split: fix #1–7, 9–11 (per-visit serialization, race ordering, create/create, revision numbering, idempotency-key scope, rule-2 retention, post-review retry, invalid selection, no-abandon, rule-1 retry), defer #8 (duplicate-content dedup) and #12 (listing ordering) as implementation detail. Confirm or adjust.
2. **Site-catalog touch-up** — its design still says tablet-sync's behavior "remains pending that choice." One line, different segment: may I update it?
3. **Phase 3** — on your approval (plus triage), I'll update the EARS: REC-001–006 stand; new specs for revision acceptance, competing-revision retention, review joining, resolution semantics, stale-set rejection, and state exposure.