I finished the registry LLD at `docs/intent/registry/registry-design.md`: SQLite index built per snapshot, atomic activation via an `active` pointer swap, fixed interface unchanged, and the backend choice recorded with the rejected alternatives. Note the on-site HTTPS and managed-service options both conflict with the HLD tenet forbidding runtime network access — that's the stated rationale, so I did not offer a separate decision doc.

The LLD-level edge probe surfaced ten gaps. Please tell me which to fold into the LLD now vs. defer:

1. Should the freshly built `registry.db` be integrity/record-count validated before activation, rather than trusting the build? (Import steps 5–6)
2. What moves the built DB from `incoming/` to `snapshots/<id>/`, and is that move ordered before the pointer write? (Current text leaves this implicit.)
3. Is the new DB/directory fsynced before the `active` rename, so a crash can't point at non-durable data? (Active snapshot)
4. Is a zero-record snapshot a valid activation, or is non-empty a required invariant? (Import step 4)
5. Where is the previous snapshot's name recorded so fallback is possible after a later activation? (Active snapshot)
6. How are malformed records (missing field, non-ISO date, null) rejected, and with what error shape? (Import step 4)
7. What is the concrete import-error shape / failed-step identifier? (Snapshot Import)
8. What prevents an in-flight lookup's snapshot directory from being removed or renamed mid-read? (Lookup Behavior)
9. What does `findBySerial` return when no `active` exists or the DB is unreadable? (Deferred 1–2; the fixed interface has no error result, so this is a real fork.)
10. Does import step 4 use exactly the lookup normalization, and may an older-dated snapshot replace a newer one? (Import vs Lookup)

Approve the LLD as-is, or name the gaps to fix before I move to EARS?