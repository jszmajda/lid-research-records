I finished the registry LLD at `docs/intent/registry/registry-design.md` around the local SQLite index.

Worth flagging: the on-site HTTPS and managed-search options were never compatible with the HLD tenet that every lookup complete from files on the kiosk with no runtime network access, so the local index is the only one of the three that satisfies the existing architecture. I recorded all three in the Decisions & Alternatives table with that rationale rather than reopening the choice.

The design now settles:

- Per-snapshot `registry.sqlite` files, built in staging and activated by an atomic `active` pointer replacement.
- Import validation (signature, schema, normalized-serial uniqueness, integrity check, record count) before activation; any failure leaves the previous snapshot active.
- A normalized `serial_key` primary key, giving indexed exact-match lookup and a snapshot date read from the same database as the record.
- Retention of the immediately previous snapshot for rollback, with older ones removed.

The Phase 2 edge-case probe surfaced four gaps I did not settle unilaterally:

1. Should a valid snapshot with zero records be accepted and activated, or rejected as a likely operator error?
2. What should startup do when the `active` pointer or its database is missing or unreadable?
3. May a valid snapshot dated earlier than the active snapshot replace it?
4. What can lookup return before any snapshot has ever been activated, given the result type requires a snapshot date?

For each, tell me whether to resolve it in the LLD or defer it. If you approve the design as it stands, I'll move to the EARS update (Phase 3).