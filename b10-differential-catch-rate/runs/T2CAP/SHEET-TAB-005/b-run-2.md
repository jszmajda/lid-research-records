SHEET-TAX-RESERVE-NNN — Tax reserve summary figures

1. **Ubiquitous.** The Tax surface SHALL publish the reserve summary as its own typed band, named `"Tax · Reserve Summary"` (distinct from the accrual band `"Tax"`), with the frozen header `["Jurisdiction","Tax Year","Accrued","Moved","Paid","Outstanding","Shortfall"]`, one row per `(Jurisdiction, Tax Year)` and no among-data summary/label/blank/embedded-header rows. The band is not a fifth entry in `VIEW_TABS`.

2. **Ubiquitous.** The reserve summary SHALL derive every figure solely from `tax::annual_report`'s `AnnualRow` values supplied to `render_tax`; `sheets-view` SHALL perform no accounting or tax arithmetic (no summing, netting, or deriving Outstanding/Shortfall itself).

3. **Event-driven.** When the Tax view is rendered, for each supplied `AnnualRow` in the order supplied, the system SHALL emit exactly one row whose cells are: Jurisdiction label — `"Federal"` for Federal, `"State(<code>)"` for a state; Tax Year — the decimal `TaxYear` integer; and Accrued, Moved, Paid, Outstanding, Shortfall — the row's `accrued_cents`, `moved_cents`, `paid_cents`, `outstanding_cents`, `shortfall_cents` respectively, each rendered as a signed dollar string with exactly two decimals (`Cents(5000)` → `"50.00"`, `Cents(-5000)` → `"-50.00"`, sign taken from the integer, magnitude formatted as `abs/100 "." abs%100` zero-padded to 2). Row count SHALL equal the supplied `AnnualRow` count.

4. **Ubiquitous (kernel-exact, not live).** Every reserve-summary cell SHALL be an engine `Value`, never a `Formula`; the band SHALL contain no `GOOGLEFINANCE` or other live-price-dependent cell. The figures are kernel-exact and as-of-last-sync, distinct from the Positions tab's live estimate.

5. **Unwanted behavior.** None of the five money columns SHALL ever render blank/empty for a present `AnnualRow` — all five are always populated, including when a figure is zero (`"0.00"`), and regardless of accrual lifecycle state (Accrued / Allocated / Moved / Paid).

6. **Ubiquitous.** Reserve-summary rows SHALL reflect the accrual lifecycle applied by the tax kernel: Moved and Paid carry the kernel's applied amounts (e.g. a Federal 2022 row after a `Move` of `Cents(50_00)` and a `Pay` of `Cents(20_00)` renders `"50.00"` and `"20.00"`).

7. **Ubiquitous.** The band SHALL be published under the same publish contract as other view tabs: rows written from `DATA_START_ROW = 2` beneath a never-rewritten frozen header row 1, with residual-tail truncation, atomically per tab; `render_tax` SHALL be infallible (returns `TaxView`, no error path).