**EARS requirements enforced — Tax tab data-band layout (sheets-view)**

**Ubiquitous — two distinct bands.**
The system shall render the Tax view as two independently-published bands, each its own `ViewTab` with its own frozen header, never nested inside the other: (a) an accrual band published under tab name `"Tax"`, and (b) a reserve-summary band published under tab name `"Tax · Reserve Summary"` (distinct name from the accrual band's tab).

**Ubiquitous — fixed headers.**
The accrual band's header shall be exactly `["Sale ID","Lot ID","Jurisdiction","Tax Year","Amount","Lifecycle State"]` (6 columns). The reserve-summary band's header shall be exactly `["Jurisdiction","Tax Year","Accrued","Moved","Paid","Outstanding","Shortfall"]` (7 columns).

**Event-driven — row cardinality/order.**
WHEN rendering the Tax view from a slice of accruals and a slice of annual rows, the system shall emit exactly one accrual-band row per input accrual and exactly one reserve-summary row per input annual row, in the input's order, with each row's cell count equal to its band's header length (no ragged rows).

**Unwanted behavior — no among-data summary rows.**
The accrual band shall never contain a blank/separator row, a row whose first cell is empty, a row labeled `"RESERVE SUMMARY"`, or any row whose cell texts equal the reserve-summary header — no summary/label/embedded-header row may appear among accrual data, so the band stays natively filterable/sortable end to end.

**Ubiquitous — cell content mapping, accrual row.**
Each accrual row shall contain, in order: Sale ID (value), Lot ID (value), Jurisdiction label, Tax Year (decimal string), Amount, Lifecycle State label. Jurisdiction label: `Federal`→`"Federal"`; `State(code)`→`"State(code)"`. Amount: `applied_cents` formatted (signed, 2-decimal, e.g. `"150.00"`/`"-150.00"`) when present; empty string `""` when absent (not-yet-applied). Lifecycle label: `Accrued`→`"Accrued"`, `Allocated{..}`→`"Allocated"`, `Moved{..}`→`"Moved"`, `Paid{..}`→`"Paid"` (state-payload fields ignored for the label text).

**Ubiquitous — cell content mapping, reserve-summary row.**
Each reserve-summary row shall contain, in order: Jurisdiction label, Tax Year (decimal string), then Accrued, Moved, Paid, Outstanding, Shortfall — each the kernel-exact `Cents` value formatted with the same signed 2-decimal rule, with no re-derivation, re-aggregation, or re-rounding in this layer.

**Ubiquitous — value/formula typing.**
Every cell in both Tax-tab bands shall be `Cell::Value`; the Tax view shall contain no `Cell::Formula` (no live `GOOGLEFINANCE`-dependent cells) — it is kernel-exact and as-of-last-sync, distinct from the Positions tab's live-price bands.

Files read: `.../sheets-view/src/lib.rs`, `.../sheets-view/tests/tabs.rs`.