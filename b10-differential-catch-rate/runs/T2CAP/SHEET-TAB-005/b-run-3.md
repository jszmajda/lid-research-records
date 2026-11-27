SHEET-TAX-RES-001 (ubiquitous) — The Tax surface SHALL publish the reserve summary as its own typed band, named "Tax · Reserve Summary", distinct from the accrual band ("Tax"), each with its own frozen header, one row per entity, and no among-data summary rows (no blank/label/embedded-header rows inside either range).

SHEET-TAX-RES-002 (ubiquitous) — The reserve-summary band SHALL carry exactly the columns, in order: Jurisdiction, Tax Year, Accrued, Moved, Paid, Outstanding, Shortfall (indices 0–6).

SHEET-TAX-RES-003 (event-driven) — WHEN the Tax view is rendered, the system SHALL emit exactly one reserve-summary row per `AnnualRow` supplied by `tax::annual_report`, in the order supplied (row count == input row count), keyed by `(Jurisdiction, Tax Year)`.

SHEET-TAX-RES-004 (ubiquitous) — Each reserve-summary row's five money figures SHALL be the kernel-exact values taken verbatim from that row's `AnnualRow`: Accrued←`accrued_cents`, Moved←`moved_cents`, Paid←`paid_cents`, Outstanding←`outstanding_cents`, Shortfall←`shortfall_cents`. `sheets-view` SHALL perform no arithmetic, derivation, netting, or re-computation of these figures (e.g. it SHALL NOT derive Outstanding or Shortfall from the other columns).

SHEET-TAX-RES-005 (ubiquitous) — Every reserve-summary cell SHALL be an engine `Value`; no cell SHALL be a live formula. The band SHALL contain no GOOGLEFINANCE/live-price dependency and is kernel-exact as of the last sync, distinct from the Positions tab's live estimate.

SHEET-TAX-RES-006 (ubiquitous) — Money figures SHALL be rendered as a signed fixed-2-decimal dollar string from integer `Cents`: sign prefix `-` when negative, then `|cents|/100`, `.`, and `|cents|%100` zero-padded to two digits (e.g. `Cents(5000)`→"50.00", `Cents(2000)`→"20.00", `Cents(0)`→"0.00").

SHEET-TAX-RES-007 (unwanted behavior) — None of the five money columns SHALL ever render as an empty string; each SHALL carry a rendered figure even when the underlying amount is zero.

SHEET-TAX-RES-008 (ubiquitous) — Jurisdiction SHALL render as the label `Federal` for `Jurisdiction::Federal` and `State(<code>)` for `Jurisdiction::State(code)`. Tax Year SHALL render as the decimal integer year (e.g. "2022").

SHEET-TAX-RES-009 (ubiquitous) — The reserve summary SHALL reflect the full accrual lifecycle recorded in tax events: an `Allocate`/`Move`/`Pay` sequence against an accrual key is reflected as distinct non-zero Moved and Paid figures for that `(Jurisdiction, Tax Year)` (e.g. Move 50.00 then Pay 20.00 for Federal/2022 renders Moved "50.00", Paid "20.00").

SHEET-TAX-RES-010 (ubiquitous) — The reserve-summary band SHALL NOT be a member of `VIEW_TABS` (which remains the four tabs Positions, Open Lots, Realized, Tax) nor a separate entry in the workbook tab ordering; it is part of the Tax surface.

SHEET-TAX-RES-011 (ubiquitous) — Rendering the Tax view SHALL be infallible (no error return); it depends only on the supplied accruals and annual rows and requires no snapshot, alias map, or marks.