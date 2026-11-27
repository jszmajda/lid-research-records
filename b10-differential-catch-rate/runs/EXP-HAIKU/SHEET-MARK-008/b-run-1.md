## Quote-Date Encoding Specification (H-MARK-008)

**PATTERN: Event-driven** — Quote date formula recomputes on each GOOGLEFINANCE refresh; settle pass reads back the computed value once per cycle.

**ENCODE (Write Contract)**

- **Column position**: Quote Date is column 12 (0-indexed) in Positions tab, paired with Price (column 4).
- **Formula structure**: `=IFERROR(TEXT(INT(GOOGLEFINANCE(ticker,"tradetime")),"0"),"")`
  - INT truncates GOOGLEFINANCE's raw `tradetime` to date serial (integer day count)
  - TEXT(...,"0") renders as digits-only string (locale-proof, parseable identically in any locale)
  - IFERROR wraps the entire expression: returns empty string when loading or errored, never an error marker (#N/A, #ERROR!)
- **Ticker resolution**: Formula uses the alias-resolved ticker (after AliasMap.resolve), not the raw symbol.
- **Transient state**: While GOOGLEFINANCE is loading or errored, the cell is empty (IFERROR suppression).

**DECODE (Read-Back Contract)**

- **Column index**: Quote Date is column 12; Price is column 4. Read both from same row.
- **Parse rule**: String value trimmed and parsed as i32 → Date(quote_days). A blank/empty/unparseable value defaults to Date(0).
- **State coupling**: Quote date is read back only alongside a numeric Price reading; transient/permanent price errors leave quote date unread for that symbol.
- **Settlement constraint**: Quote date is a companion stamp to numeric marks — absent marks yield no quote date for that symbol; carried-forward prior marks retain their prior quote dates.

**INVARIANTS**

- One quote-date value per symbol per settle pass (keyed by symbol row identity).
- Quote date value is always non-negative (date serial / integer day count).
- Mismatched or misaligned (Price/Quote Date) columns are a structural error (assertion in render_positions).