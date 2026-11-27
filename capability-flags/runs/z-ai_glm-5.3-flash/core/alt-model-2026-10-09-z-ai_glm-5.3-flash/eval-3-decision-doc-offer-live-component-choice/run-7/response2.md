The decision doc is written at `docs/intent/record-store/decisions/whole-visit-revisions.md` and linked from the record-store LLD's Decisions & Alternatives row.

It covers what you asked for:

- **Why the other approach stays live** — a dedicated "Why the other approach stays live" section: the price paid is review workload alone (criterion C1), so if same-base conflicts on unrelated fields outpace two coordinators before the Friday export, the trade should be re-run — but any future field-aware design must still clear the no-silent-combination gate (G1), retain all original submissions, and provide field-level provenance.
- **What tablet and export work must accommodate** — in both the Selection section and mirrored in the LLD's Downstream Contracts: tablet-sync tracks a base revision ID per draft, resubmits complete payloads, and shows an unresolved outcome as a pending decision; review-export exports resolved visits only, builds a whole-revision comparison screen, and consumes resolution outcomes naming the selected revision and competing set.

The doc's machinery: one gate (no silent combination of scientifically related fields — this is what eliminates field-aware merge), four weighted criteria tied to HLD tenets, both options presented at their strongest with concrete demonstrations, and the selection reasoning.

Still pending from the Phase 2 stop: your approval of the record-store LLD itself, and triage of the ten edge-case probe questions (fix in the LLD vs. defer) — 2, 3, 5, 6, and 8 look most likely to hide real gaps. Once you rule on those, Phase 3 (EARS updates, including the stale REC-004 wording) begins with its own stop.