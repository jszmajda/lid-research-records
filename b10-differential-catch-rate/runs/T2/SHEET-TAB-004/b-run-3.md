**EARS reconstruction — Tax tab data-band layout (sheets-view)**

**[Ubiquitous]** The Tax tab SHALL render as two distinct typed bands: an accrual band (tab name `"Tax"`) and a reserve-summary band (named range `"Tax · Reserve Summary"`), each carrying its own frozen header, so the reserve summary never sits inside the accrual range and neither band carries the other's rows.

**[Ubiquitous]** `TAX_RESERVE_TAB` SHALL remain a sub-range of the Tax surface, not a fifth entry in `VIEW_TABS` (which SHALL contain exactly 4 names: Positions, Open Lots, Realized, Tax).

**[Ubiquitous]** The accrual band's header SHALL be exactly the 6 columns `["Sale ID","Lot ID","Jurisdiction","Tax Year","Amount","Lifecycle State"]`.

**[Ubiquitous]** The reserve-summary band's header SHALL be exactly the 7 columns `["Jurisdiction","Tax Year","Accrued","Moved","Paid","Outstanding","Shortfall"]`.

**[Event-driven]** WHEN the Tax view is rendered from a list of accruals, the system SHALL emit exactly one row per accrual (row count == accrual count), each row exactly 6 cells wide, in the input order, with no blank/separator/label row and no row whose full cell-text sequence equals the reserve-summary header (no embedded second header masquerading as data); every row's first cell (Sale ID) SHALL be non-empty.

**[Event-driven]** WHEN the Tax view is rendered from a list of `AnnualRow`s, the system SHALL emit exactly one row per `(Jurisdiction, Tax Year)` pair, each row exactly 7 cells wide, in input order, using the kernel-exact `accrued_cents`/`moved_cents`/`paid_cents`/`outstanding_cents`/`shortfall_cents` values unmodified from the tax kernel, each formatted via `fmt_cents` (sign only if negative, integer part, `.`, exactly 2 fraction digits, e.g. `"-150.00"`).

**[Ubiquitous — value normalization]** Within the accrual band: Jurisdiction renders as `"Federal"` or `"State({code})"`; Lifecycle State renders as one of `"Accrued"|"Allocated"|"Moved"|"Paid"`; Tax Year renders as a bare integer string (no separators); all cells are `Cell::Value` (no live formulas — the Tax tab is kernel-exact, as-of-last-sync, never GOOGLEFINANCE-backed).

**[Unwanted behavior]** IF an accrual's `applied_cents` is `None` (not yet applied) THEN the Amount cell SHALL render as the empty string — never `"0.00"`, never a row omission, never a whole-render failure.

Not enforced by this code/tests: any explicit sort order beyond input iteration order, and any row-count upper bound.