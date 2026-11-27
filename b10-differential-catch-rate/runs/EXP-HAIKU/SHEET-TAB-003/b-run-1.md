**P-TAB-003: Republish Atomicity, Frozen Header & Tail Truncation**

When a view tab is republished, the following requirements govern state survival and overwrites:

**SHEET-PUB-001 [Ubiquitous]:** Frozen header — Row 1 (typed column header) is written once on first publish and **never rewritten** on any subsequent republish. A republish presenting a different header is a protocol violation (enforced as a panic, not silently accepted). The test `republish_regenerates_data_and_never_rewrites_frozen_header` confirms header byte-identity across republishes.

**SHEET-PUB-002 [State-driven]:** Atomic data regeneration — On republish, the data range (rows 2 onward, anchored at `DATA_START_ROW=2`) is atomically overwritten in **one** `batchUpdate` call. All prior data rows are **unconditionally replaced wholesale** (never appended or merged). If a republish carries N data rows, exactly N rows exist beneath the frozen header after the update; any stale rows from a prior republish carrying more rows are **tail-truncated** to the new count.

**SHEET-PUB-003 [Value-driven]:** Cell typing — `Cell::Value` is written as `userEnteredValue` (Sheets parses natively: bare numbers as numeric, percent-suffixed strings like `"20.0000%"` coerce to numeric fractions for formula multiplication). `Cell::Formula` is written as `userEnteredValue` with `=` prefix (live formulas like `=GOOGLEFINANCE(...)` recalculate on quote changes).

**SHEET-PUB-004 [Unwanted-behavior]:** No partial write — If `batch_update_view` fails, the tab is left as-is (no half-written window). A subsequent republish retries the full atomic write. If the tab doesn't exist (fresh workbook), bootstrap (create sheet → write header → write data); if any step fails, rollback incomplete.

**SHEET-PUB-005 [State-driven]:** Symbol-row identity invariant — Positions tab (and settle-pass read-back) key on row identity (symbol column). One row per distinct symbol is enforced. If a snapshot somehow carried duplicate rows for one symbol, return `DuplicateSymbolRow` error (loud, never silent).

**SHEET-PUB-006 [Event-driven]:** Settle pass serialized — The marks settle pass (reading back `GOOGLEFINANCE`-computed Price/Quote Date cells) runs **after** the data write completes in the same cycle, never inline with formula write, ensuring formulas have time to recalculate before read-back.

**SHEET-PUB-007 [Ubiquitous]:** Stale banner best-effort — If publish fails, write in-tab STALE banner (`"STALE — last sync {timestamp}"`). Banner failure doesn't corrupt data integrity; workbook surfaces as stale but canonical log is unaffected.

---

**Constants:** `DATA_START_ROW = 2` (1-based); header byte-identity enforced; residual rows truncated to exact new row count; no append/merge semantics.