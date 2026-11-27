Updated `docs/intent/registry/registry-design.md` for the local SQLite index, and aligned the HLD's architecture line.

The design now specifies:
- **Index layout:** immutable per-snapshot SQLite databases under `registry/snapshots/<snapshot-id>/`, selected by an `active` pointer file.
- **Schema:** a `records` table keyed by normalized `serial_key`, plus metadata for snapshot date, snapshot ID, source schema version, and record count.
- **Import:** signature and schema-version validation, staged index build in one transaction, normalized-key duplicate rejection, flush-and-close, then atomic pointer replacement. Any failure leaves the previous snapshot active.
- **Lookup:** local read-only SQLite query; whitespace trim and ASCII-only uppercasing; punctuation and internal whitespace preserved; snapshot date returned for both Found and NotFound.
- **Decisions & Alternatives:** backend selection, normalized index key, pointer-swap activation, and full rebuild versus incremental update.

I ran an edge-case probe against the LLD. Genuine gaps found:

1. Re-importing the same content digest into an existing snapshot directory — reuse, overwrite, or reject?
2. Today the design says a failed pointer replacement leaves `active` unchanged, but a directory-flush failure after a successful rename may already have taken effect.
3. A lookup that resolves the old pointer just before activation, then opens the file after the old directory is cleaned up.
4. Read-only handle reuse across two activations: how pointer changes are detected and what happens if the open database disappears underneath the handle.
5. Runtime error shape for a missing pointer, unreadable index, or SQLite I/O failure — the fixed Found/NotFound contract has no error representation.
6. Metadata versus directory/pointer disagreement — whether lookup trusts metadata for the returned snapshot date.
7. Concurrent imports: mutual exclusion, shared `active.tmp`, and staging-directory collisions.
8. What exactly the content digest covers, and whether the schema version and signature manifest are inside the signed bytes.
9. Whether a verified zero-record snapshot may activate.
10. Cleanup scope for older snapshot directories, orphans from failed pointer replacement, and failed best-effort removal.

Which of these should I fold into the LLD now, and which should stay deferred? Items 5 and 6 overlap with the deferred "no active snapshot" and startup-recovery questions.

The backend choice remained genuinely live across three credible options. Do you want a decision doc at `docs/intent/registry/decisions/lookup-backend.md`, or is the Decisions & Alternatives row sufficient?

Once you approve the LLD and settle the gap triage, I'll proceed to Phase 3 and update the registry EARS specs.