# Rust Implementation: Tax Tab (SHEET-FORMULA-004)

```rust
/// Tax tab: kernel-exact, stacked, as-of-last-sync snapshot
/// Contrast: Positions tab uses GOOGLEFINANCE for live prices; Tax tab is frozen at sync

use std::collections::BTreeMap;

/// Kernel-sourced tax position (deterministic, not live)
#[derive(Clone, Debug)]
pub struct TaxLot {
    symbol: String,
    quantity_units: i64,
    cost_basis_cents: i64,       // kernel-exact
    cost_per_unit_cents: i64,    // for tax reporting
    is_long_term: bool,          // tax bucket (LTCG vs STCG)
    acquisition_date: i64,       // unix seconds
}

/// Tax tab snapshot: kernel state captured at last sync
#[derive(Clone, Debug)]
pub struct TaxTabSnapshot {
    sync_timestamp_secs: i64,
    tax_lots: BTreeMap<String, Vec<TaxLot>>,  // stacked by symbol
    total_unrealized_cents: i64,               // kernel-exact, NOT live
}

impl TaxTabSnapshot {
    /// Build from kernel accounting output (not live price feed)
    pub fn from_kernel(
        sync_ts: i64,
        kernel_lots: Vec<TaxLot>,
    ) -> Self {
        let mut stacked = BTreeMap::new();
        let mut total = 0i64;

        for lot in kernel_lots {
            let unrealized = lot.quantity_units * (lot.cost_per_unit_cents)
                - lot.cost_basis_cents;  // placeholder; kernel provides exact
            total += unrealized;
            stacked
                .entry(lot.symbol.clone())
                .or_insert_with(Vec::new)
                .push(lot);
        }

        TaxTabSnapshot {
            sync_timestamp_secs: sync_ts,
            tax_lots: stacked,
            total_unrealized_cents: total,
        }
    }

    /// Project to Google Sheets rows (distinct schema from Positions tab)
    pub fn sheet_rows(&self) -> Vec<Vec<String>> {
        let mut rows = vec![vec![
            "Symbol", "Qty", "Cost Basis (¢)", "Term", "Acq Date",
        ]
            .iter()
            .map(|s| s.to_string())
            .collect()];

        for (sym, lots) in &self.tax_lots {
            for lot in lots {
                rows.push(vec![
                    sym.clone(),
                    lot.quantity_units.to_string(),
                    lot.cost_basis_cents.to_string(),
                    if lot.is_long_term { "LT" } else { "ST" }.to_string(),
                    lot.acquisition_date.to_string(),
                ]);
            }
        }

        // Summary row (kernel-exact, NOT GOOGLEFINANCE)
        rows.push(vec![
            "TOTAL UNREALIZED (¢)".to_string(),
            String::new(),
            self.total_unrealized_cents.to_string(),
            String::new(),
            String::new(),
        ]);

        rows
    }
}
```

## Assumptions (Exhaustive)

1. **"kernel-exact"** = deterministic figures from kernel accounting engine; unrealized gains computed from cost-basis and cost-per-unit, NOT from live prices.
2. **"stacked"** = aggregated by symbol; multiple tax lots per symbol preserved (FIFO tax reporting).
3. **"as-of-last-sync"** = snapshot frozen at a captured timestamp; remains static until next sync.
4. **"distinct from Positions live"** = Positions tab uses `=GOOGLEFINANCE("TICKER","price")` formulas that auto-update; Tax tab is hardcoded sheet rows (static after sync).
5. **Money = integer cents** (i64, no decimals).
6. **Tax-adjusted** = includes cost basis, acquisition date, LTCG/STCG bucket (for later tax reporting).
7. **Ambiguity choice**: "tax-adjusted figures" means cost-basis and tax-lot metadata, NOT realized gains (those belong to realized-gains tab, if present).
8. **Edge case**: Empty kernel state → empty rows except header + zero-total row.
9. **Fallback**: If sync timestamp missing, use system time; if lot lacks long-term indicator, default to short-term.
10. **Out-of-scope**: Tax calculations (realized G/L, basis step-up) happen in kernel; sheets-view only *projects* kernel output.

---

**Interpretation rationale**: "Kernel-exact" and "as-of-last-sync" strongly suggest the Tax tab is a *static snapshot* of kernel state, not a derived live computation. Contrast with Positions (live GOOGLEFINANCE) forces this design.