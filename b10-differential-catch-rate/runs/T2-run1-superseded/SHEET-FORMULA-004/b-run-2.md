**Ubiquitous:**
- The Tax tab shall render as two distinct typed bands, each under its own frozen header, never merged into one range: the accrual band (header: `Sale ID, Lot ID, Jurisdiction, Tax Year, Amount, Lifecycle State`) and the reserve-summary band (header: `Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall`).
- Every cell in both Tax-tab bands shall be an engine `Value`, never a live `Formula` — the figures are kernel-exact, stacked, as-of-last-sync (distinct from Positions' live pre/post-tax estimate, which uses formulas).
- The accrual band shall contain exactly one row per input `Accrual`, in given order, with no blank, label, separator, or embedded-second-header row among the data (row width always equals header width).
- The reserve-summary band shall contain exactly one row per input `AnnualRow` (one per `(Jurisdiction, Tax Year)`), in given order, with all five figure columns populated — never blank — even when a figure's value is zero.
- Every currency figure (Amount, Accrued, Moved, Paid, Outstanding, Shortfall) shall be formatted as: a `-` sign prefix iff the value is negative, then `⌊|cents|/100⌋` followed by `.` and `|cents| mod 100` zero-padded to exactly 2 digits (e.g., `Cents(15000)` → `"150.00"`; `Cents(-5)` → `"-0.05"`).
- Jurisdiction shall render as the literal `"Federal"` for the Federal variant, and as `"State({code})"` (code interpolated, no transformation) for a State variant.
- Lifecycle State shall render as one of the four literals `"Accrued"`, `"Allocated"`, `"Moved"`, `"Paid"` — the variant's name only; any inner variant data (e.g. `Allocated{..}`) is discarded, not rendered.
- Tax Year shall render as the plain decimal string of its integer year (`to_string()`), with no zero-padding or other formatting.
- The reserve-summary figures shall be copied verbatim from the corresponding `AnnualRow` fields (`accrued_cents`, `moved_cents`, `paid_cents`, `outstanding_cents`, `shortfall_cents`) with no recomputation, re-derivation, or rounding beyond `fmt_cents`.

**Event-driven:**
- When an accrual's applied amount is absent (`applied_cents = None`), the system shall render that row's Amount cell as an empty string (never `"0.00"` or an error marker).
- When an accrual's applied amount is present (`Some(v)`), the system shall render that row's Amount cell as `fmt_cents(v)`.

**Unwanted behavior:**
- The reserve-summary band shall never be stuffed inside the accrual band's range — no `"RESERVE SUMMARY"` label row, no blank separator row, and no row whose cell text equals the reserve-summary header, appearing among accrual-band rows.