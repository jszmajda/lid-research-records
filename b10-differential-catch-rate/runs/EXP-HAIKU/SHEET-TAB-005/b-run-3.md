TAX-RESERVE-001: **Tax Reserve Summary Structure**
The Tax Reserve Summary is a distinct typed band (separate from the accrual band, each with its own frozen header, `TAX_RESERVE_TAB` / `TAX_RESERVE_HEADER`) rendering kernel-exact accrual lifecycle data by `(Jurisdiction, Tax Year)` pair, one row per unique pair from the kernel's `AnnualRow` set.

TAX-RESERVE-002: **All Five Lifecycle Columns Mandatory**
Each reserve-summary row must populate all five numeric columns (no blank/empty cells): `Accrued`, `Moved`, `Paid`, `Outstanding`, `Shortfall`. A missing or empty figure is a requirement violation (test: `reserve_summary_carries_all_five_kernel_exact_columns` line 383–389 asserts no empty text).

TAX-RESERVE-003: **Kernel-Exact Values, Not Live Formulas**
Reserve-summary cells are values (not formulas); every cell is `Cell::Value(…)`, rendering the kernel-computed `Cents` figures from `tax::annual_report`'s `AnnualRow` directly, never synthesized or post-tax-estimated. Values are stacked, as-of-last-sync snapshots of the accrual lifecycle state (distinct from Positions' live-formula estimates).

TAX-RESERVE-004: **Currency Format: Signed Dollar.Cents**
All numeric columns render via `fmt_cents(Cents)`, which formats as `[−]whole.fractional_2digits`, where `whole = v / 100` and `fractional = v % 100` (e.g., `Cents(5000)` → `"50.00"`, `Cents(−2000)` → `"-20.00"`).

TAX-RESERVE-005: **Row Correspondence**
Each reserve-summary row exactly corresponds to one `AnnualRow` in iteration order; the row count equals `annual_rows.len()`. Keying is identity: jurisdiction label, tax year label, then the five `Cents` figures from the `AnnualRow` (accrued_cents, moved_cents, paid_cents, outstanding_cents, shortfall_cents).

---

**Pattern**: State-driven (kernel-written accrual lifecycle stored in `AnnualRow`; render reflects that state exactly). **Error semantics**: no conversion error (Cents is already an integer); missing AnnualRow data is a kernel bug, not a render concern.