Updated `docs/high-level-design.md` and completed the draft in `docs/intent/registry/registry-design.md`.

The design now specifies:

- A private, read-only embedded SQLite index.
- Stable `Found` / `NotFound` certificate-facing results.
- Persisted normalized serial numbers as unique lookup keys.
- Whole-index replacement through a temporary database and atomic activation.
- Rejection of serials that collide after normalization.
- No network, service credentials, or general-purpose search interface.
- Decisions and rationale covering SQLite, activation, normalization, and connection handling.

The edge-case probe found these unresolved gaps:

1. What happens if the database file is replaced but opening it or swapping the connection fails?
2. How should activation recover from a crash or power loss, and when is activation considered durable?
3. How should SQLite open, query, metadata, or corruption failures be surfaced without resembling `NotFound`?
4. How should concurrent imports be serialized and ordered?
5. What import error categories should callers receive?
6. May an older or identical snapshot replace the active snapshot?
7. How should empty normalized serials and non-ASCII whitespace be handled?
8. May an empty snapshot activate, and what record/metadata validation is required?
9. How should file-replacement conflicts and post-activation cleanup failures affect import success?
10. How should orphaned temporary databases be recovered after interruption?

The design also explicitly defers startup recovery, retaining source snapshots for rebuilds, and previous-index cleanup policy.

Please review the design and indicate which gaps to resolve now versus defer. After your approval, I’ll update the registry EARS specifications.