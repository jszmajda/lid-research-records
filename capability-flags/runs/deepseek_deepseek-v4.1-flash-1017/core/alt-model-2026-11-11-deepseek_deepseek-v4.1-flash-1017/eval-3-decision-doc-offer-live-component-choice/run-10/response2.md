Written to `docs/intent/record-store/decisions/whole-visit-revisions.md` and linked from the LLD’s Decisions & Alternatives table.

It records:
- **Decision elements**: whole-visit scientific intent, coordinator review volume, maintained merge-rule burden, explainability, tablet submission cost, and operational fit.
- **The strongest case for field-aware three-way merge**: disjoint edits avoid coordinator review, change sets transmit less, and field-level provenance is available — with the counterweight that its rules cannot tell which edits are scientifically related.
- **Why whole-visit wins**: the current value is always exactly one worker’s submitted visit, no field-level rules need maintenance, and the exported value stays explainable. The larger queue is the accepted cost, with a clear signal to revisit if unresolved volume threatens the Friday export.
- **Tablet-sync obligations**: retain base revision IDs, resend whole payloads, reuse idempotency keys, never choose locally or rebase, and display competing heads.
- **Review-export obligations**: compare whole revisions, resolve with the full reviewed head set, handle conflicts by refreshing, exclude unresolved visits, and maintain no merge rules.

Before I move to Phase 3 (EARS), two things are still open from the LLD probe:

1. I can fold these into the LLD contract directly: idempotency lookup before existence checks; replay returns the same revision ID with current status; “identical payload” means the whole envelope; rejected submissions do not bind their key; concurrent resolutions have a single atomic winner; resolution retries are idempotent; conflict errors return the refreshed head set; resolved responses include author/base/receipt metadata; history orders by receipt time then revision sequence. The one genuine fork is **plot ID**: should a revision be forbidden from changing the visit’s plot, or may an edit move a visit to another plot?
2. `site-catalog-design.md` still says tablet-sync behavior “remains pending that choice.” May I update that sentence, even though it crosses into the site-catalog segment?

Confirm those and I’ll finish the LLD, then draft the EARS specs.