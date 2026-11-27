The registry design is drafted around the local SQLite index and is ready for your review; specs, tests, and code are untouched until you approve it.

One thing about the choice: the HLD tenets forbid any runtime network access, which rules out the HTTPS directory and the managed search service outright. So I recorded it as a row in the registry's Decisions table rather than a separate decision doc.

## What changed

- **`docs/intent/registry/registry-design.md`**: rewritten with the SQLite design below.
- **`docs/high-level-design.md`**: one line, replacing "Its private lookup backend remains open" with the local index.
- **Certificates**: nothing changes; `findBySerial` and its two results are as before.

## The design

- **Storage**: one SQLite index file per imported snapshot, written once and never modified, plus a small pointer file naming the active one. SQLite is linked into the application, so there is nothing extra to install.
- **Index contents**: a `records` table keyed by normalized serial number, and a one-row `snapshot` table with the snapshot date, schema version, record count, and index layout version.
- **Import**: verify the signature and records file, check the schema version, check disk space, build a new index, check it, then switch the pointer and delete the old index. Lookups are answered from the old index until the switch.
- **Failure**: any failure before the switch deletes the temporary file, leaves the pointer alone, and reports the step and the reason.
- **Lookup**: a read-only primary-key read, with the record and snapshot date taken from the same index file.

Three choices in the draft are mine, each with a Decisions row:

- **Separate file plus pointer**, rather than replacing rows in the active database in one transaction. The active index is never written during an import; the cost is disk space for two indexes while one runs.
- **Duplicates caught by the primary key** during the build, rather than by collecting serials in memory, so import memory stays flat.
- **A malformed record rejects the whole snapshot**, rather than being skipped. The earlier design did not cover this case.

## Questions for you

These are in the design's Open Questions section.

1. **Duplicates that differ only by case or whitespace.** If a snapshot holds both `ab-1` and `AB-1`, is that a duplicate that rejects the import? The draft says yes, because a lookup cannot tell them apart. The other reading is that snapshot serials are already canonical and are compared exactly.
2. **No usable index.** A kiosk that has never imported a snapshot, or whose index will not open, has no snapshot date, and `findBySerial` has no result for that. I recommend the registry reports itself as not ready and the kiosk asks for a snapshot, leaving the interface alone. The alternative is a third result type, which changes the certificates design.
3. **Older snapshots.** May a snapshot dated earlier than the active one be imported?

## Gaps from a cold read

I had a subagent read the draft without this conversation. Tell me which to fix now and which to defer; my recommendation is to fix all but 8 and 9, which need your answer first.

1. **Startup cleanup can delete the last valid index.** It deletes "any index file the pointer does not name", so a missing or unreadable pointer would delete everything, against the tenet. Cleanup should run only when the pointer resolves.
2. **Activation is two operations.** Renaming the index and replacing the pointer are described as one atomic step, and a failure during or after activation has no stated outcome. The pointer swap should be the single commit point, flushed to disk.
3. **Verified bytes versus built bytes.** The draft does not say the build reads the same bytes that were verified. If the media changes in between, unverified records could be indexed. Copying to local staging or hashing while streaming would close this.
4. **Deleting the old index.** "Once no lookup is still using it" names no mechanism, and the draft does not say whether a lookup opens the index each time or holds a connection.
5. **"Can always be rebuilt" is too strong.** The kiosk does not keep the snapshot, so a corrupt index, or an application update that changes the index layout, needs the USB media again. Should the kiosk keep the last snapshot file (up to 150 MB)?
6. **Re-importing the active snapshot.** Index file naming is undefined, so the behaviour here is undefined too.
7. **Disk filling mid-build.** The space check has no estimation rule, and it is unclear which error the technician sees.
8. **Normalization edge cases.** Internal whitespace, non-ASCII characters, and a serial that normalizes to empty are unstated. So is whether `Found` returns the serial as typed or as normalized.
9. **"Valid record" is undefined.** Blank lines, a trailing newline, unknown extra fields, and missing or unparseable dates each need a ruling.
10. **Concurrent or interrupted imports.** A second import request, a cancellation, and a shutdown mid-import have no stated behaviour.

Once you have answered the three questions and triaged the gaps, I'll revise the design and then draft the spec updates for your review.