```rust
// sheets-view: Positions tab, "Quote Date" companion column (SHEET-MARK-008).
// Owns formula generation + read-back parsing only; no accounting/tax math.

/// Builds the per-row Quote Date formula. `symbol_cell` is the same A1
/// reference the row's Price column already anchors its GOOGLEFINANCE
/// call on (e.g. "A2").
pub fn quote_date_formula(symbol_cell: &str) -> String {
    format!(
        "=IFERROR(TEXT(INT(GOOGLEFINANCE({sym},\"tradetime\"))-DATE(1970,1,1),\"0\"),\"\")",
        sym = symbol_cell
    )
}

/// Parses the read-back cell string into a day-count-since-epoch stamp.
/// Returns `None` for the empty (loading/errored) case.
pub fn parse_quote_epoch_days(cell_value: &str) -> Option<i64> {
    let trimmed = cell_value.trim();
    if trimmed.is_empty() {
        return None;
    }
    trimmed.parse::<i64>().ok()
}
```

Assumptions (all invented, none stated in the EARS):

1. **"Trade date" = GOOGLEFINANCE's `"tradetime"` attribute.** GOOGLEFINANCE has no literal `"tradedate"` attribute; `"tradetime"` returns a datetime serial for the last trade. `INT()` strips the time-of-day fraction to isolate the trading day.
2. `symbol_cell` is the same per-row anchor cell the Price column's own GOOGLEFINANCE call already references — one call per attribute per row, no batched range form.
3. `DATE(1970,1,1)` is used instead of the hardcoded Sheets serial `25569`, so the epoch anchor is self-documenting in-sheet rather than a magic number; both evaluate identically in Sheets' internal date-serial system.
4. A single `IFERROR(..., "")` wrapper covers both formula errors (`#N/A`, `#VALUE!`) *and* the transient `"Loading..."` string — `INT()` applied to that string itself raises `#VALUE!`, so no special-case branch for the literal loading text is needed to satisfy "empty while loading/errored."
5. `TEXT(...,"0")` is the chosen locale-proof format: plain integer digits, no thousands separator, no date-locale rendering — this is what makes `parse_quote_epoch_days` a bare `i64` parse instead of a datetime parse.
6. Negative day-counts (dates before 1970-01-01) are not special-cased in the parser; GOOGLEFINANCE is not expected to return pre-epoch trade dates, but the type isn't artificially restricted to `u32`/non-negative.
7. Header text/column placement on the Positions tab is a tab-builder projection concern outside this sketch's scope — only formula generation and read-back parsing are covered, consistent with sheets-view owning no accounting/tax math.
8. Staleness/freshness policy (e.g., a trade date several days old due to a market holiday) is intentionally not encoded here; this column reports GOOGLEFINANCE's answer as-is, and any freshness judgment is the settle pass's responsibility, not this formula's.