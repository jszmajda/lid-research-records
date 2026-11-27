**Phase 4 — Intent-Narrowing Edge Audit**

I've found the following genuine forks where a blind implementer could diverge from latent intent. Please resolve each:

---

**1. REG-001 vs REG-008: Where normalization happens**
- REG-001: "system SHALL normalize... before returning"
- REG-008: "query... using a parameterized SELECT on the normalized serial number column"
- *Fork*: Does the registry normalize the input *before* the SQL query (application-side), or does the SQL query use `UPPER(TRIM(?))` (database-side)? The design says "normalize before lookup" — application-side is clearer for testability and keeps SQL trivial.

**2. REG-003 vs REG-007: Import failure scope**
- REG-003: rejects on "invalid signature, unsupported schema version, or duplicate serial numbers"
- REG-007: "fails at any stage" leaves previous index
- *Fork*: Does "any stage" include SQLite index build errors (disk full, corruption, constraint violation)? The design says "after all validation and index build succeed" — yes, index build errors should also leave previous active.

**3. REG-008: Parameterized SELECT exact shape**
- *Fork*: `SELECT * FROM index WHERE serial_norm = ?` returns 0 or 1 row (PK). What if duplicate `serial_norm` somehow exists despite validation? The design validates "serial numbers for uniqueness" — but on *raw* serials. Two different raw serials could normalize to the same value (e.g., "ABC-123" and "abc 123"). Should the index build reject this, or should the query handle multiple rows?

**4. REG-009: Implementation detail vs. behavioral spec**
- REG-009 mandates denormalized `snapshot_date` column.
- *Fork*: Is this a *requirement* (testable: "lookup returns snapshot date without join") or an *implementation decision* (testable only by inspecting schema)? The design records it in Decisions table — consider moving to design-only and keeping specs behavioral.

**5. CERT-002: "When the registry returns NotFound" — what about errors?**
- The registry interface returns `Found | NotFound`. What if the registry throws (corrupt index, IO error)? CERT-002 only addresses `NotFound`.
- *Fork*: Should certificates also block export on registry *errors*, or surface them differently?

**6. Sequencing: REG-005 → REG-006 → REG-007**
- The three specs imply a sequence but don't state it. A test could pass them independently while missing the atomic-swap ordering.

---

**Please resolve each fork (numbered 1–6) with your intended reading.** I'll then narrow the specs accordingly before writing tests.