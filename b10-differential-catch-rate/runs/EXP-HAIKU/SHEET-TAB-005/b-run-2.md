**TAX-RESERVE-001**: Each per-(Jurisdiction, Tax Year) row in the Tax Reserve Summary tab renders **exactly one row per distinct (Jurisdiction, Tax Year)** pair from the kernel's `tax::annual_report` output. The pair is the **unique key**; duplicate keys are not produced by the kernel, and the projection carries them as-is (state-driven by accrual lifecycle).

**TAX-RESERVE-002**: The reserve summary's five columns—Accrued, Moved, Paid, Outstanding, Shortfall—carry **kernel-exact Cents values** from the corresponding AnnualRow fields (accrued_cents, moved_cents, paid_cents, outstanding_cents, shortfall_cents). These are **engine values, never formulas**, distinct from Positions' live-price estimates. They represent the **cumulative stacked state as of last sync**—not recalculated per settle pass.

**TAX-RESERVE-003**: All five reserve figures must be **present and non-empty** in every row. No column is blank or deferred for a given (Jurisdiction, Tax Year) pair. If the kernel produced an AnnualRow, all five Cents fields are populated and rendered.

**TAX-RESERVE-004**: Formatting rule (ubiquitous): All Cents(i64) values are formatted via `fmt_cents` — a signed dollar-cents string ("$X.XX"):
  - Divide `v.abs()` by 100 (whole dollars), mod 100 (fractional cents)
  - Format as `"{whole}.{frac:02}"`
  - Prepend "-" if `v < 0`
  - Example: Cents(150_00) → "150.00", Cents(-150_00) → "-150.00"

**TAX-RESERVE-005**: Cell writing contract: Each reserve-summary cell is written as a **Cell::Value (engine value, not formula)**. The SheetsViewClient trait requires Cell::Value to be written as a Sheets `userEnteredValue` (not forced string), so Sheets parses a numeric value like "150.00" as a number, preserving arithmetic semantics in downstream formulas if any (none in the reserve band itself, but the contract is load-bearing for consistency).

**TAX-RESERVE-006**: The reserve summary band is its **own typed range** with its own frozen header (TAX_RESERVE_HEADER: ["Jurisdiction", "Tax Year", "Accrued", "Moved", "Paid", "Outstanding", "Shortfall"]). It is **kept separate from the accrual band** so neither carries among-data summary rows and both stay **natively filterable** in Sheets. Both bands are part of the single Tax view but are distinct ViewTab entities on render (TaxView.reserve_summary).

**TAX-RESERVE-007**: No live-price coupling. The reserve summary is **not recomputed on settle pass**; it is stale until the next full replay + republish. The Positions tab's live post-tax estimate columns (Est. Unrealized Tax, Net Unrealized) depend on effective tax rates from tax's unrealized estimate; the reserve summary carries only the accrual-lifecycle-state figures (accrued, moved, paid, outstanding, shortfall), which lag the live position.

---

**Spec ID path:** SHEET-TAX-RESERVE-{001..007}  
**Pattern:** State-driven (accrual lifecycle) + ubiquitous (one row per jurisdiction×year)