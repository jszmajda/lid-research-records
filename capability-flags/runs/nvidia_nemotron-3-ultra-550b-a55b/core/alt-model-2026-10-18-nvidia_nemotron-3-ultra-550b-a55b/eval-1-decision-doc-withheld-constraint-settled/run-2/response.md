## Phase 4 — Intent-Narrowing Edge Audit

I've analyzed the registry specs for cross-spec interactions, composition ambiguities, and latent intent gaps. Here are the genuine forks:

### 1. REG-005 "atomically swap" — two plausible readings
- **Reading A**: File-level atomic rename (`new.db` → `active.db`) on POSIX, with a separate connection pool swap.
- **Reading B**: In-process connection swap without file rename (keep one file, `DELETE FROM ...; INSERT ...` in a transaction).

**Difference**: Reading A survives power loss mid-swap; Reading B is simpler but leaves a window where the DB is being rewritten.

### 2. REG-006 date format — not specified
- Calibration date, due date: ISO 8601 (`YYYY-MM-DD`)? Unix epoch ms? Something else?
- Snapshot date as "global property": a single-row metadata table? A PRAGMA user_version? A separate file?

### 3. REG-007 "within 250 ms" — cold vs. warm cache
- First lookup after boot (cold page cache) vs. subsequent lookups. The 250 ms goal is ambitious cold on 4 GB RAM with 90k rows unless the index fits in memory.

### 4. REG-008 startup with previous valid snapshot
- Spec says "report error and await import" — but the HLD tenet says "A failed snapshot import must leave the last valid snapshot available." If the index file is corrupt but the *source snapshot JSON* is intact, should the system auto-rebuild from the last good snapshot instead of blocking?

### 5. REG-003 + REG-005 interaction — partial index on failed import
- REG-003: reject import, retain active snapshot.
- REG-005: build index, then atomically swap.
- **Fork**: Does "build index" happen *before* validation (wasted work on bad snapshots) or *after* validation but *before* atomic swap? If after validation, a crash between build and swap leaves the old index intact (good), but the new index file sits orphaned.

### 6. REG-001 normalization scope
- "Surrounding whitespace and ASCII letter case" — does this apply to the *input only*, or also to the stored serial numbers in the index? If stored serials have internal spaces (e.g., `AB- 123`), normalizing only the input won't match.

---

**Please resolve each fork** (numbered 1–6) with your intended reading, or tell me if any should be deferred as open questions.