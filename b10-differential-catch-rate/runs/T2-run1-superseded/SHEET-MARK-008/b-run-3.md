```
EARS — Quote Date companion column (trade-date encoding)

[Ubiquitous] The system shall render column index 12 ("Quote Date") of the
Positions tab, for every position row, as a live formula:
`=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`
where `<ticker>` is the same alias-resolved ticker used by that row's `Price`
formula (column 4).

[Ubiquitous] The formula shall truncate GOOGLEFINANCE's `tradetime` to its
date serial via `INT(...)`, then re-base it to days-since-1970-01-01 (the
kernel `Date` epoch) by subtracting `DATE(1970,1,1)` — never the raw
`tradetime` value.

[Ubiquitous] The formula shall render the re-based integer via `TEXT(...,"0")`
— a plain digits-only string with no thousands separator, decimal point, or
locale-dependent date formatting — so every workbook locale renders it
identically.

[State-driven] WHILE the underlying `GOOGLEFINANCE(...,"tradetime")` value is
loading or erroring, the Quote Date formula shall evaluate to the empty
string `""` (via the outer `IFERROR`), never an error token (e.g. `#N/A`,
`#ERROR!`).

[Event-driven] WHEN the settle-pass read-back parses a Positions row's
`Price` cell (column 4) as a finite numeric value, the system shall read the
companion Quote Date cell at column index 12 (a fixed offset, not searched by
header), trim it of surrounding whitespace, and parse it as a signed 32-bit
integer count of days since 1970-01-01.

[Unwanted behavior] IF the Quote Date cell is absent, empty, or fails to
parse as a 32-bit integer (including the empty string the formula renders
while loading/erroring), THEN the system shall default the parsed quote date
to `0` (i.e. epoch date 1970-01-01) rather than raising an error, returning
`None`, or leaving the mark unstamped.

[Ubiquitous] Quote-date parsing is performed only in conjunction with a
numeric Price reading (`PriceReading::Numeric { price_usd, quote_date }`); a
non-numeric Price reading (`Transient`/`Permanent`) carries no quote-date
value at all.

Constants pinned: `PRICE_COL = 4`, `QUOTE_DATE_COL = 12` (also asserted as
the Positions header's literal `"Quote Date"` index by test). No tie-break
rule beyond the epoch-default fallback; no other normalization (e.g. no
timezone shift, no rounding) applied to the parsed integer.
```

Files read: `{scratch}/audit-baseline/crates/runtime/src/adapters.rs`, `{scratch}/audit-baseline/crates/sheets-view/src/lib.rs`, `{scratch}/audit-baseline/crates/sheets-view/tests/formula.rs`