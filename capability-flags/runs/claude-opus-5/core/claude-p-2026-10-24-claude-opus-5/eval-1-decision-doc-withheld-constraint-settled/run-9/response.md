Pre-flight was clean: REG-001–004 all trace to the registry design, the design matches the HLD's architecture, and there's no code or tests yet, so nothing downstream had drifted.

**One thing about the option set before the design itself.** Of the three sketches, only the local SQLite index was actually available. The HLD's tenets say *"All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted"* and *"Kiosks have no network route during normal operation."* Both the on-site HTTPS directory and the managed search service need runtime network access from the kiosk, so each was foreclosed by a standing constraint rather than losing on balance. Last session's sketch should have said that — you spent deliberation on a comparison that the HLD had already settled. If you want either network option to be genuinely live, that's an HLD tenet change first, and I'd walk it from Phase 1.

That also sets how the choice gets recorded: a **Decisions & Alternatives row, not a decision doc**. The test is whether a cold reader of the landed result would be tempted to reverse it — and here one line ("the offline tenet eliminates the networked candidates") settles it completely. A doc would memorialize deliberation that the tenet makes unnecessary.

**What I wrote.** `registry-design.md` now carries the backend: one SQLite file per prepared snapshot holding both `equipment` (primary key on the normalized serial, `WITHOUT ROWID`) and a single-row `snapshot_meta`, so records and the reported snapshot date activate as one artifact. Import streams records into a staging file, enforces serial uniqueness via the primary key during the insert stream rather than as a separate pass, and activates by atomically renaming an `active` pointer file — so a failed or power-interrupted build never touches the index serving lookups. Five decision rows: backend, metadata location, uniqueness enforcement, activation mechanism, normalized-form storage.

I also made one edit outside the node: the HLD's registry line said *"Its private lookup backend remains open"*, which is now false. It reads *"Owns snapshot validation and lookup, including its private lookup backend."* No architectural change — say the word if you'd rather I revert it.

**Edge-case probe.** I had a subagent read only the artifacts and hunt gaps inside this component. Its findings, for you to triage — fix in the LLD now, or defer into Open Questions:

1. **No active index at all** (first boot, or a dangling pointer). Both result types carry a snapshot date; there's no third state. `NotFound` with no date, or a failure the interface doesn't model?
2. **A snapshot activates mid-session.** The design says the handle is held for the session *and* that activation is a pointer rename. Is a session pinned to the snapshot it opened, or does the next lookup see the new one?
3. **"Duplicate serial" — published form or normalized form?** Normalization is lossy, so `ab-1` and `AB-1` collide on the key. The LLD as written enforces uniqueness on the normalized key, i.e. that pair aborts the import. That's the one place I asserted a reading you haven't ruled on — confirm or I'll change it.
4. **Superseded index files.** Activation only moves the pointer, so old files accumulate. No retention or reclamation rule, and deleting one a session still holds open is its own question.
5. **Two concurrent imports** (two USB media, or a retry after an interruption). Is import mutually exclusive, or can one staging build clobber another?
6. **Import error shape.** "Names the stage that failed" has no error type, stage identifiers, or return path behind it — `findBySerial` is the only declared interface.
7. **Interruption between the two renames** in step 5: a fully built, never-activated file. Detected and reused, or discarded?
8. **A malformed record mid-stream** — abort, or skip? There's no record-validation stage and no record schema.
9. **An older snapshot than the active one** — replaceable like any other, or a defect to reject?
10. **A zero-record snapshot, or a missing/unparseable snapshot date or schema version** — currently nothing forbids activating it.

My read is that 1, 2, 3, and 6 want answers in the LLD before specs — they change what REG-002 and REG-003 have to say. 4, 5, 7–10 could defer without blocking Phase 3. Your call.

Tell me which to fix and which to defer (and your ruling on 3), and I'll revise the LLD and stop again before touching the EARS specs.