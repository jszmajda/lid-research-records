The registry design is drafted around the local SQLite index and is ready for your review; I have not touched the specs yet, since they follow from what you approve here.

The draft is in `docs/intent/registry/registry-design.md`. I also replaced the one line in `docs/high-level-design.md` that said the lookup backend "remains open". Nothing is committed.

## What the design now says

- **Index:** one SQLite file per snapshot, with a records table keyed by normalized serial number and a one-row table holding the snapshot date and schema version. A lookup is a single primary-key read against a read-only file.
- **Import:** four steps in fixed order: verify the signature, check the schema version, stream the records into a new staging index inside one transaction, then atomically swap it in for the active index.
- **Failure:** any failed step deletes the staging index, leaves the active one untouched, and reports which step failed and why. Startup deletes a staging index left by an interrupted import.
- **Lookup and interface:** `findBySerial`, the normalization rules and the result types are unchanged, so the certificates design is not affected.

## How the choice is recorded

The backend choice is a row in the design's Decisions table, not a standalone decision doc. The project's own tenets forbid runtime network access for lookups, so the HTTPS directory and the managed search service were never eligible, and one line of rationale covers that.

## Choices I made that need your ruling

1. **Duplicate serials are judged on the normalized form.** Two records differing only by case or surrounding whitespace fail the import. The existing text said only "validate for uniqueness". The other reading, raw uniqueness, would let the index hold two records that one lookup matches.
2. **Build a whole new index, then swap.** I chose this over updating the active index in place. It costs temporary disk space for a second index, but a failed import cannot damage the active one.
3. **The kiosk keeps no copy of the source snapshot.** A damaged index is therefore recovered by re-importing from USB.

## Gaps to triage

I had a subagent read the design cold, and added three gaps of my own (4–6). For each, tell me whether to fix it in the design or leave it as an open question. I recommend fixing 1–3 and 7–10 now, and need your answer on 4–6, which are currently listed as open questions in the design.

1. **Power loss during activation.** The design says "atomic replacement" but not what must be flushed to disk first, or how startup recognises a half-finished swap.
2. **Verified bytes versus parsed bytes.** The snapshot is read once to verify and again to build; nothing guarantees the USB content is the same both times. Copying to the kiosk first would close this.
3. **What the signature covers.** If the snapshot date or schema version sits outside the signed bytes, a tampered date would appear on every certificate.
4. **No snapshot ever imported.** Both result types carry a snapshot date, so neither fits a fresh kiosk. Any answer changes the interface the certificates component uses, so I will not change it without your say.
5. **Older snapshot than the active one.** Should a validly signed but older snapshot be accepted, rejected, or accepted after a warning?
6. **Active index missing or unreadable.** What should a lookup do, given there is no source copy to rebuild from?
7. **Empty or tiny snapshot.** A validly signed snapshot with zero records would replace 90,000 and turn every lookup into NotFound.
8. **Malformed records and dates.** The design does not define a malformed record (missing fields, a serial that normalizes to empty) or a missing or future snapshot date. `findBySerial("")` is also unspecified.
9. **Second import or cancel.** "One import at a time" does not say whether a second request is rejected or queued, and there is no cancel path.
10. **Smaller mechanics.** These are when later lookups switch to the new file, lookup speed while a 150 MB build is running, SQLite's journal files in the cleanup path, and an app update that cannot read the existing index.

Once you have ruled on these, I will update the design and draft the spec changes for your review.