**Ubiquitous requirements**

- The Tax view shall be rendered as two distinct typed bands, each with its own frozen header and no among-data summary rows: an accrual band named `"Tax"` under header `["Sale ID","Lot ID","Jurisdiction","Tax Year","Amount","Lifecycle State"]`, and a reserve-summary band named `"Tax · Reserve Summary"` under header `["Jurisdiction","Tax Year","Accrued","Moved","Paid","Outstanding","Shortfall"]`. The two bands' names shall differ, and neither band's rows shall ever equal the other band's header (no embedded second header, no blank/label/separator row).
- Every cell in both Tax-tab bands shall be an engine-written value (`Cell::Value`); the Tax tab shall contain no live formula (`Cell::Formula`) cell — its figures are kernel-exact, stacked, and as-of-last-sync, distinct from the Positions tab's live `GOOGLEFINANCE`-driven pre/post-tax estimate.
- The accrual band shall contain exactly one row per input `Accrual`, in input order, with: Sale ID and Lot ID copied verbatim from the accrual key; Jurisdiction labeled `"Federal"` for `Jurisdiction::Federal` or `"State(<code>)"` for `Jurisdiction::State(code)`; Tax Year rendered as its bare integer string; Lifecycle State labeled `"Accrued"`, `"Allocated"`, `"Moved"`, or `"Paid"` per the accrual's `AccrualState` (ignoring any state-carried payload).
- The reserve-summary band shall contain exactly one row per input `AnnualRow`, in input order — one row per `(Jurisdiction, Tax Year)` — carrying that row's Accrued, Moved, Paid, Outstanding, and Shortfall cents figures verbatim from the kernel, all five populated (none blank), formatted via the shared signed-dollar rule: optional `-` sign, whole-dollar integer part, `.`, two-digit zero-padded cent remainder (e.g. `Cents(5000)` → `"50.00"`, `Cents(-150)` → `"-1.50"`).
- The reserve-summary row count shall equal the input `annual_rows` count; the accrual-band row count shall equal the input `accruals` count.

**Event-driven requirement**

- When an accrual's `applied_cents` is `None` (not yet applied), the Amount cell shall render as an empty string rather than omitting the row, erroring, or defaulting to `"0.00"`.

**Unwanted-behavior requirement**

- If the Tax tab were republished, it shall not corrupt or invent figures for a `(jurisdiction, tax_year)` absent from the kernel's `annual_rows`/`accruals` inputs — no row is synthesized; only rows present in the kernel output are rendered, each with all its stated columns non-ragged (row width equals header width).