**EARS requirements enforced — Tax Reserve Summary figures**

1. **Ubiquitous.** The system shall source the Tax tab's reserve-summary band exclusively from `tax::annual_report`'s `AnnualRow` sequence (parameter `annual_rows`), never from the accrual list, never recomputed in `sheets-view`, and never from a live/sheet formula.

2. **Ubiquitous.** For each `AnnualRow`, the system shall render exactly one reserve-summary row under `TAX_RESERVE_HEADER` = [Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall], with the five monetary columns taken verbatim (kernel-exact, no adjustment) from `accrued_cents`, `moved_cents`, `paid_cents`, `outstanding_cents`, `shortfall_cents` respectively.

3. **Ubiquitous.** The reserve-summary rows shall be emitted in the same order as, and with count equal to, the input `annual_rows` slice (one row per `(Jurisdiction, Tax Year)`, 1:1).

4. **Ubiquitous — formatting.** Each monetary column shall be formatted by the canonical cents formatter: sign character (`-` if negative, else none) + `abs(cents)/100` + `.` + two-digit zero-padded `abs(cents)%100` (e.g. `Cents(5000)` → `"50.00"`, `Cents(-100)` → `"-1.00"`, `Cents(0)` → `"0.00"`). A zero value shall format as `"0.00"`, never as an empty string.

5. **Ubiquitous — normalization.** Jurisdiction shall render as the literal `"Federal"` for `Jurisdiction::Federal` and as `"State(<code>)"` (code interpolated verbatim, no case/whitespace transform) for `Jurisdiction::State(code)`. Tax Year shall render as the plain decimal string of the year integer (no thousands separator, no padding).

6. **Ubiquitous — cell typing.** Every cell in the reserve-summary band shall be `Cell::Value` (an engine-written value); the system shall never emit `Cell::Formula` in this band, distinguishing it from the Positions tab's live `GOOGLEFINANCE`-dependent columns.

7. **Ubiquitous — structural separation.** The reserve-summary band shall be published as its own `ViewTab` (name `TAX_RESERVE_TAB`, `"Tax · Reserve Summary"`) with its own frozen header, distinct from the accrual band's `ViewTab` (`TAX_TAB`); the system shall never interleave reserve-summary rows (blank/label/embedded-header rows) inside the accrual band's one-row-per-accrual range.

8. **Unwanted behavior.** If an `AnnualRow` is present for a `(Jurisdiction, Tax Year)`, none of its five formatted monetary columns shall be blank/empty — an empty string in Accrued/Moved/Paid/Outstanding/Shortfall is a defect (test-pinned regression guard), even when the underlying value is zero.

9. **Ubiquitous.** The reserve-summary values reflect state as of the last completed sync (no live recompute on read); a moved/paid lifecycle (e.g. partial move + partial payment against an accrual) shall surface as distinct, independently correct Moved and Paid figures on the matching `(Jurisdiction, Tax Year)` row, each traceable back to its `AnnualRow` counterpart with no reserve-summary-side reconciliation logic.