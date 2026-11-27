**Ubiquitous:**
- U1: The system shall render the Tax tab's data as two structurally distinct bands — an accrual band and a reserve-summary band — each a separate typed range with its own frozen header, never merged into one range and never containing the other's rows.
- U2: The accrual band shall be published under the tab name `"Tax"` (`TAX_TAB`); the reserve-summary band shall be published under the distinct name `"Tax · Reserve Summary"` (`TAX_RESERVE_TAB`), and the reserve-summary band shall not count as a fifth entry in the four-tab `VIEW_TABS` list (length stays 4).
- U3: The accrual band's header shall be exactly `["Sale ID","Lot ID","Jurisdiction","Tax Year","Amount","Lifecycle State"]` (`TAX_HEADER`).
- U4: The reserve-summary band's header shall be exactly `["Jurisdiction","Tax Year","Accrued","Moved","Paid","Outstanding","Shortfall"]` (`TAX_RESERVE_HEADER`).
- U5: In both bands, data rows begin at the fixed anchored row 2 (`DATA_START_ROW`), immediately beneath the frozen header at row 1.

**Event-driven:**
- E1: When `render_tax` is called with N accruals and M annual rows, the system shall emit exactly N rows in the accrual band (one per accrual, input order preserved) and exactly M rows in the reserve-summary band (one per `(Jurisdiction, Tax Year)`).
- E2: When emitting any row in either band, the system shall emit exactly as many cells as that band's header has columns (no ragged rows).

**State-driven (value normalization):**
- S1: While rendering the Jurisdiction cell, `Federal` renders as the literal string `"Federal"`; `State(code)` renders as `"State({code})"`.
- S2: While rendering the Lifecycle State cell, `AccrualState::Accrued`/`Allocated`/`Moved`/`Paid` render as the literal strings `"Accrued"`/`"Allocated"`/`"Moved"`/`"Paid"` respectively (variant fields dropped).
- S3: While an accrual's `applied_cents` is absent, the Amount cell shall render as an empty string rather than `"0.00"` or omitting the row.
- S4: All monetary cells in both bands render via the signed two-decimal-place format (e.g., `Cents(15000)` → `"150.00"`; negative values prefixed `-`); Tax Year renders as a bare integer string.

**Unwanted behavior:**
- UB1: The accrual band shall never contain a blank, label, or separator row among its data: every row's first cell shall be non-empty, and no row's first cell shall equal the literal `"RESERVE SUMMARY"`.
- UB2: The accrual band shall never contain a row whose full cell-text sequence equals `TAX_RESERVE_HEADER` (no embedded second/reserve header masquerading as an accrual data row).
- UB3: The reserve-summary band shall never be embedded inside the accrual band's row range; it is written under its own distinct name and header, keeping both bands natively filterable/sortable end to end.