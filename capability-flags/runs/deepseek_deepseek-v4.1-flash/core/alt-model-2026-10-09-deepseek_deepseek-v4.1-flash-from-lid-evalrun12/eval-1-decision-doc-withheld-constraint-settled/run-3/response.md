Registry design finished through the LLD. Phase 2 output and the review stop are below.

**Coherence pre-flight**
- HLD ↔ registry LLD: consistent. The backend is private to the registry node, so the HLD needed no architectural change; I did make one wording fix so the HLD no longer implies the backend is undecided ("its lookup backend is private to this node").
- Registry LLD ↔ REG specs: consistent, no spec edits implied by this choice.
- Tests/code: none exist — the arrow is docs-only so far, so nothing downstream to reconcile.
- One finding worth naming: the HLD tenet *"no runtime network access"* already eliminates the on-site HTTPS directory and the managed search service. Local SQLite is not just the preferred option, it is the only one consistent with the HLD — which is why these options looked close only until weighed against that tenet.

**LLD changes (`docs/intent/registry/registry-design.md`)**
- Backend fixed to a local embedded SQLite index (private file in the registry data dir; `records` keyed by normalized serial, plus a metadata row for snapshot date and schema version).
- Snapshot import builds a staging file `registry.next.db`, then atomically renames it over `registry.db`; the previous index is retained until the rename completes, so any failure leaves the last valid snapshot active.
- Lookup normalizes (trim + ASCII uppercase), does a primary-key equality check, and returns the snapshot date on both `Found` and `NotFound`.
- Decision recorded as a **Decisions & Alternatives row**, not a decision doc: the choice is settled by an inherited HLD constraint (the no-network tenet), and it affects only this node. I did not offer a doc, per the earns-its-place test.

**LLD-level edge-case probe** (what I could not resolve from the text as written):
1. During the activation rename, can a lookup return a record from one snapshot and a date from another if it reads them in separate operations?
2. A second snapshot arrives while `registry.next.db` already exists (in-flight or crash leftover) — is the earlier staging file reused, overwritten, or activated?
3. With no metadata row (first run, or `registry.db` missing/unreadable), what does `findBySerial` return and what date accompanies `NotFound`?
4. After a crash between build and rename, can a stale staging file ever become the active index?
5. The rename has no stated `fsync`/durability step, and SQLite `-wal`/`-shm` sidecars aren't addressed by renaming only the `.db`.
6. No free-disk check or defined behavior when space/time runs out building the staging index.
7. Normalization is undefined for empty, null/non-string, non-ASCII, or very long inputs, and what non-`NotFound` error shape results.
8. The import error shape is unspecified and the four failure causes aren't distinguished.

**Stop — Phase 2 review.** Please rule on: (a) the LLD as written, (b) which of the 8 probe gaps to fix in the LLD vs. defer, and (c) whether to proceed to Phase 3 (EARS), where I'd expect at most one new spec — an import-activation rule covering build failure, which REG-003/004 don't currently state. Also confirm you did not mean to revisit the no-network HLD tenet, since it is what settled this choice.