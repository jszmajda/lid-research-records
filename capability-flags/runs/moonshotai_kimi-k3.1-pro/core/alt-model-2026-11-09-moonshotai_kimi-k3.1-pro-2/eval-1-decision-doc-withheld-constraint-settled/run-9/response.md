The local SQLite design is now recorded in:

- `docs/high-level-design.md` — SQLite is the registry’s private lookup backend.
- `docs/intent/registry/registry-design.md` — completed storage, import, activation, recovery, concurrency, and lookup design. The certificate-facing interface remains unchanged.

The design uses multiple snapshot generations in one SQLite database, WAL mode, serialized imports, normalized-serial uniqueness, and a transactionally committed active-snapshot pointer.

The edge-case probe found these decisions needing your triage:

1. **No active snapshot:** Should lookup return a third result variant or an operational error?
2. **Database failure:** What exact error variant or exception should `findBySerial` expose for corruption or an unreadable index?
3. **Invalid activation:** Should activating an incomplete, nonexistent, or already-active snapshot be rejected or treated idempotently?
4. **Previous snapshot state:** Should activation explicitly transition the previous snapshot to a historical state?
5. **Record validity:** Should empty snapshots be accepted, and which missing or invalid fields make a record malformed?
6. **Import errors:** Do you want stable error categories distinguishing invalid media from kiosk/storage failures?
7. **Abandoned staging data:** Should the next import automatically reclaim it before proceeding?
8. **Empty serial input:** Should it be an input error or ordinary `NotFound`, and what counts as surrounding whitespace?
9. **Retention and storage:** What retention limit and free-space headroom should apply?
10. **Corruption recovery:** How should operators be notified and service restored?

Which of these should we resolve in the LLD now, and which should remain deferred? In particular, **1 and 2 affect the registry’s public interface**. After your review, I’ll proceed to the EARS specification update.