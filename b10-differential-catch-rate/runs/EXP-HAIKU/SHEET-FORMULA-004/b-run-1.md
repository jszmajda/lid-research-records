**TAX-VIEW** specification (reconstructed from lib.rs, formula.rs, tabs.rs):

TAX-VIEW-001: The Tax tab publishes two distinct typed bands, each with its own frozen header and native Sheets filtering: the accrual band (TAX_HEADER) and the reserve summary band (TAX_RESERVE_HEADER). The bands never interleave — no blank rows, labels, or embedded headers separate or sit within them.

TAX-VIEW-002: The accrual band renders one row per `Accrual`. Each row has exactly six columns (Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State), all engine values (no formulas).

TAX-VIEW-003: Accrual `Amount` is formatted as signed dollars with two decimal places via `fmt_cents` (e.g., `Cents(150_00)` → `"150.00"`, `Cents(-50_00)` → `"-50.00"`). If `applied_cents` is `None`, the cell is empty.

TAX-VIEW-004: Accrual `Jurisdiction` is a `config::Jurisdiction` rendered as `"Federal"` or `"State({code})"`.

TAX-VIEW-005: Accrual `Lifecycle State` is a `tax::AccrualState` rendered exactly as one of: `"Accrued"`, `"Allocated"`, `"Moved"`, or `"Paid"`.

TAX-VIEW-006: The reserve summary band renders one row per distinct `(Jurisdiction, Tax Year)` pair from `tax::annual_report`'s `AnnualRow`. Each row has exactly seven columns (Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall), all engine values.

TAX-VIEW-007: Reserve summary columns `Accrued`, `Moved`, `Paid`, `Outstanding`, and `Shortfall` are kernel-exact `Cents` values from the corresponding `AnnualRow` fields, formatted as signed dollars with two decimal places (no blank cells).

TAX-VIEW-008: Reserve summary `Jurisdiction` and `Tax Year` are rendered identically to accrual band (Jurisdiction via `jurisdiction_label`, Tax Year as string).

TAX-VIEW-009: All Tax tab cells are engine-computed values (no live `GOOGLEFINANCE` formulas), kernel-exact, stamped as-of-last-sync — distinct from Positions' live estimates.