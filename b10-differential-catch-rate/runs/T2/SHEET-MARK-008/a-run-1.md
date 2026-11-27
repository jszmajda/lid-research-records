```rust
//! sheets-view: SHEET-MARK-008 — Quote Date companion column (Positions tab).

/// Builds the `Quote Date` cell formula for the position row whose ticker
/// lives in `symbol_cell` (e.g. "A2"). Emits days-since-epoch as a TEXT
/// string so the settle pass never depends on locale date parsing.
pub fn quote_date_formula(symbol_cell: &str) -> String {
    format!(
        r#"=IFERROR(IF(ISNUMBER(GOOGLEFINANCE({s},"tradedate")),TEXT(GOOGLEFINANCE({s},"tradedate")-DATE(1970,1,1),"0"),""),"")"#,
        s = symbol_cell
    )
}

/// Parses the read-back cell value into a days-since-1970-01-01 stamp.
/// Empty / blank / non-numeric (loading, errored, or stale schema) => None;
/// the settle pass treats None as "no quote available this pass".
pub fn parse_quote_epoch_days(raw: &str) -> Option<i64> {
    let t = raw.trim();
    if t.is_empty() {
        return None;
    }
    t.parse::<i64>().ok()
}
```

Assumptions (invented, not in the EARS text):

1. **Cell-reference shape**: caller passes the row's Symbol-column cell as a plain `&str` (e.g. `"A2"`); no validation/escaping of the reference is done here — that's the caller's contract.
2. **`GOOGLEFINANCE(symbol,"tradedate")` semantics**: assumed to return a Sheets serial-date number (days since 1899-12-30) when a quote exists, and a non-numeric/error/blank state while loading or on invalid symbol — this is the real observed Sheets behavior I'm relying on without verifying against current API docs.
3. **Epoch anchor**: `DATE(1970,1,1)` used verbatim as the Sheets-formula epoch anchor; subtraction yields a signed integer day count. Chose `i64` in Rust to admit negative values (pre-1970 trade dates), even though realistically always non-negative.
4. **Locale-proofing mechanism**: interpreted "`TEXT`-formatted serial-date difference" as `TEXT(<days>, "0")` — a plain-integer numeric format pattern, which I assume renders identically across Sheets locales (no thousands separator, no decimal point ambiguity). This is the crux locale-proofing move; if `"0"` itself is locale-variant in some edge locale, the requirement isn't fully met, but I found no better invariant format token.
5. **Empty-while-loading/errored**: implemented via `IFERROR(...,"")` wrapping an `ISNUMBER` guard, rather than trusting `IFERROR` alone — assumed `GOOGLEFINANCE` can return non-error non-numeric placeholders (e.g. `"Loading..."` string) that `IFERROR` alone wouldn't catch, so an explicit `ISNUMBER` check is added defensively.
6. **Read-back type**: assumed the sheets-view crate receives this cell's value as a `String` (formatted value), not a typed Sheets API cell object; parsing trims whitespace and treats any non-empty non-integer string as "no quote" (`None`) rather than erroring, since a partially-loaded read-back is expected transient state, not a bug.
7. **No timezone handling**: `GOOGLEFINANCE`'s trade-date is assumed already date-only (no time-of-day component), so no rounding/truncation logic is needed beyond the subtraction.
8. Module owns no accounting/tax logic, consistent with the sheets-view crate boundary — purely formula string + value parser.