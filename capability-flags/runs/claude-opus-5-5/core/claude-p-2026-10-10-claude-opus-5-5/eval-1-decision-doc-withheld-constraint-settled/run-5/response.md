The registry design is drafted around the local SQLite index, and it needs your review before I write any specs. I've stopped at the design; no specs, tests, or code have changed.

## What changed

- **`docs/intent/registry/registry-design.md`**: rewritten around the SQLite index. Please read it in full, since it is what you're approving.
- **`docs/high-level-design.md`**: one sentence. The Registry bullet now names the SQLite index instead of saying the backend "remains open".
- **Certificates**: untouched. `findBySerial` and its result types are unchanged.

## The design in brief

- **Index:** one SQLite file holds one snapshot. It has a records table keyed by normalized serial and a single-row table with the snapshot date and schema version. The active file is opened read-only, and SQLite ships inside the GaugeDesk install.
- **Import:** five steps, each of which must succeed before the next:
  1. Verify the signature manifest and the record file.
  2. Reject an unsupported schema version.
  3. Build a new index in a staging file on local disk, in one transaction. A malformed record or duplicate serial aborts the build.
  4. Run SQLite's integrity check and compare the record count.
  5. Flush, then atomically replace the active file.
- **Failure:** any failed step deletes the staging file, leaves the active index alone, and reports the step and cause. Lookups keep running against the active index throughout. A staging file left by an interrupted import is deleted at startup.
- **Lookup:** normalize the serial, probe the primary key, and read the snapshot date from the same file.

## Decisions I recorded

The backend choice is a row in the Decisions table, not a standalone decision doc. Your no-network tenets rule out the HTTPS directory and the managed service, so one line of rationale settles it.

I made two further choices that you didn't. Both are in the table; say so if you want either reversed.

- **The kiosk builds the index from the signed JSON records.** The alternative was shipping a prebuilt index inside the snapshot. Building locally means the kiosk only trusts records it verified itself, at the cost of import time on each kiosk.
- **A new snapshot is built as a separate file and swapped in.** The alternative was replacing rows inside the active index in one transaction. The swap means the active file is never opened for writing, at the cost of temporary disk space for a second index.

## Questions for you

I had an independent reader probe the draft for gaps, and these are its findings plus three of my own. For each, tell me whether to settle it in the design now (and how), or leave it as an open question.

These change behaviour and need your call:

1. **Near-duplicate serials.** Do two snapshot records whose serials differ only by letter case or surrounding whitespace count as duplicates and fail the import? The draft's build step implies yes, but REG-003 doesn't say.
2. **No active snapshot.** What does `findBySerial` return on a fresh kiosk? Both result types carry a snapshot date, so neither fits. A third result would touch the certificates interface.
3. **Unreadable active index.** What happens if the active file is corrupt or hits an I/O error at startup or mid-lookup? Returning NotFound would read as "not in the registry".
4. **Older snapshot.** May a validly signed snapshot older than the active one be imported?
5. **What the signature covers.** Does the manifest sign the snapshot date and schema version, or only the record file? The date appears on every certificate.
6. **Empty or semantically bad snapshots.** Should a signed snapshot with zero records, or records with a missing or invalid date or an empty serial, be rejected? "Malformed" is currently undefined.
7. **App upgrade that changes the index schema.** The draft doesn't keep the source snapshot on the kiosk, so the kiosk could have no usable registry until the next USB arrives. Should it keep the verified snapshot for rebuilds?
8. **Normalization details.** Which characters count as whitespace, how is internal whitespace treated, and does an empty serial return NotFound or an error?

For these I have a proposed answer, unless you object:

9. **Media changed between verify and build.** Copy the snapshot to local disk first, then verify and build from that copy.
10. **Failed or interrupted activation.** Staging and active files share a filesystem. A failed swap is an import failure with the old index still active. A staging file found at startup is always discarded.
11. **Import outcome reporting.** Every import ends in an explicit result: either activated with the new snapshot date, or failed with step and cause and the old snapshot date still active. The causes add integrity failure, count mismatch, media read error, and activation failure.
12. **Concurrent imports.** One import at a time; a second request is refused while one is running.

Outside the registry's current scope:

13. **Key rotation and "approved" media.** The design names one bundled public key and no media check. Changing the key means reinstalling GaugeDesk. Is that acceptable, and does "approved USB media" in the high-level design mean anything beyond a valid signature?

Once you've answered these and approved the design, the next step is updating the REG specs to match.