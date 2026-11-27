Drafted the registry LLD at `docs/intent/registry/registry-design.md` and updated the HLD's registry line so the backend is no longer described as open.

The design now covers:
- one immutable SQLite database per snapshot, with `records` keyed by normalized serial and snapshot metadata in `meta`
- signature/schema validation, streaming rebuild into `staging/`, duplicate rejection after serial normalization
- atomic `active` pointer swap plus in-process connection swap, keeping the previous snapshot active on any pre-commit failure
- read-only indexed lookup, with no network dependency

I recorded the backend choice as a Decisions row rather than a decision doc: the HLD's no-runtime-network tenet eliminates both network-backed options, so a cold reader would not need the full tradeoff re-litigated.

The LLD edge probe surfaced these unresolved gaps (the first four are already listed under Open Questions):

1. First run with no active snapshot: what does `findBySerial` return, and does the public contract gain an unavailable outcome? This affects the certificates node.
2. Operational read failure (I/O error, corrupt database) and a rejected concurrent import: what result or error shape is exposed?
3. Crash after moving a database into `snapshots/` but before the `active` rename: are orphan snapshot files cleaned up? After the rename commits, how does the in-memory connection reconcile on restart?
4. When is a superseded snapshot's connection closed and its database file pruned?
5. Does import stream the exact bytes signature verification covered, or reopen the snapshot file?
6. What exactly counts as "surrounding whitespace"; do non-ASCII letters case-fold; can a serial normalize to empty?
7. Is the `active` rename made durable by flushing the parent directory?
8. Is a signed snapshot with zero records valid, and should import preflight free disk space?

Do you approve the LLD as drafted for the Phase 2 stop? And for the gap list, which items should I fold into the LLD now versus record as deferred open questions?