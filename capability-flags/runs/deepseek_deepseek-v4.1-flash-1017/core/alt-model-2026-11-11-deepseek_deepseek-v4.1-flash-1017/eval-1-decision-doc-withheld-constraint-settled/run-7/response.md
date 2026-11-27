I updated `docs/high-level-design.md` and `docs/intent/registry/registry-design.md` to select and design the local embedded SQLite index.

**Coherence pre-flight**
- Removed the HLD's now-stale "lookup backend remains open" statement.
- LLD now specifies: snapshot validation and normalized uniqueness, streaming build into a staging SQLite database, atomic active-index pointer swap, read-only lookups, and operational-failure handling.
- No code or tests exist yet, so nothing downstream to reconcile.

**LLD decisions recorded**
| Decision | Chosen | Rationale |
|---|---|---|
| Lookup backend | Local embedded SQLite index | Only option satisfying the HLD tenet that lookups use kiosk files with no runtime network. |
| Snapshot activation | Versioned DB + atomically replaced active-index pointer | Every lookup sees a complete snapshot; failed imports leave the previous one active. |
| Serial uniqueness | Reject collisions after lookup normalization | Keeps lookup deterministic when normalized serials collide. |
| Index access | Read-only at lookup | Kiosk records are immutable. |

The full draft is in `docs/intent/registry/registry-design.md`.

**LLD edge-case probe**
The probe surfaced gaps needing your triage:

1. **Operational failure vs fixed result type** — `findBySerial` is fixed to `Found`/`NotFound`, but an unreadable index must not look like NotFound. Throw a typed error, or widen the contract? This affects the certificates node.
2. **Lookup/activation handoff** — must an in-flight lookup pin the DB it opened before activation removes the old file? Must record and snapshot date come from the same opened DB?
3. **First run** — before any snapshot exists, is that a distinct state, an operational failure, or NotFound with what snapshot date?
4. **Index schema mismatch at lookup** — after app upgrade/rollback, does lookup refuse, rebuild, or report an operational failure?
5. **Concurrent imports** — is import single-flight, and how is staging identified/cleaned?
6. **Activation crash safety** — confirm temp-file + fsync + rename + directory fsync, plus startup cleanup of orphaned DBs.
7. **Normalization and malformed records** — exact whitespace class, empty-after-normalization serials, required record fields/date formats, and error detail.
8. **Validation/build ordering** — what exactly the signature covers, and whether staging writes begin before full verification.
9. **Snapshot date contract** — format, backward-dated snapshots, empty signed snapshots.
10. **Resource/lookup lifecycle** — over-limit snapshots, staging on the same volume, connection/cache model for the 250 ms goal.
11. **Key/manifest handling and import error shape** — rotation, which key is recognized, and distinguishable import error categories.

My recommendation: fold **2–8** into the LLD now; **1** needs your call because it may touch the certificates contract; defer **9–11** to Open Questions. Which should go where, and do you approve this LLD so I can update the `REG` specs next?