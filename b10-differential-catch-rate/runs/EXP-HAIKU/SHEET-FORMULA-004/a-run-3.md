```rust
/// Tax tab projection: kernel-exact, stacked, tax-adjusted figures
/// Distinct from Positions live estimate (which uses GOOGLEFINANCE).
use std::collections::BTreeMap;

#[derive(Debug, Clone)]
pub struct TaxAdjustedLot {
    pub symbol: String,
    pub quantity_cents: i64,  // shares * 10000 (fixed-point)
    pub cost_basis_cents: i64, // USD cents, total
    pub unrealized_gain_cents: i64, // kernel-computed, not live
    pub wash_loss_disallowed_cents: i64, // tax adjustment
    pub sync_timestamp: i64, // last kernel sync
}

#[derive(Debug)]
pub struct TaxTabRow {
    pub symbol: String,
    pub quantity_shares: f64,
    pub cost_basis_usd: f64,
    pub unrealized_gain_usd: f64,
    pub adjusted_basis_usd: f64, // cost_basis - wash_loss_disallowed
    pub sync_date_iso: String,
}

/// Project kernel tax-adjusted lots to Tax tab.
/// Input: kernel state (exact, stacked as of last sync).
/// Output: rows for Google Sheets Tax tab.
/// 
/// Invariant: all figures are kernel-exact at sync_timestamp; no live repricing.
pub fn project_tax_tab(
    kernel_lots: &[TaxAdjustedLot],
) -> Vec<TaxTabRow> {
    // Group by symbol, stack (sum) tax adjustments within each position.
    let mut by_symbol: BTreeMap<String, Vec<TaxAdjustedLot>> = BTreeMap::new();
    for lot in kernel_lots {
        by_symbol.entry(lot.symbol.clone())
            .or_insert_with(Vec::new)
            .push(lot.clone());
    }

    let mut rows = Vec::new();
    for (symbol, lots) in by_symbol {
        let total_qty = lots.iter().map(|l| l.quantity_cents).sum::<i64>();
        let total_cost = lots.iter().map(|l| l.cost_basis_cents).sum::<i64>();
        let total_unrealized = lots.iter().map(|l| l.unrealized_gain_cents).sum::<i64>();
        let total_wash_disallowed = lots.iter().map(|l| l.wash_loss_disallowed_cents).sum::<i64>();
        
        // Use the most recent sync timestamp in this group.
        let sync_ts = lots.iter().map(|l| l.sync_timestamp).max().unwrap_or(0);

        rows.push(TaxTabRow {
            symbol,
            quantity_shares: total_qty as f64 / 10000.0,
            cost_basis_usd: total_cost as f64 / 100.0,
            unrealized_gain_usd: total_unrealized as f64 / 100.0,
            adjusted_basis_usd: (total_cost - total_wash_disallowed) as f64 / 100.0,
            sync_date_iso: format_timestamp(sync_ts),
        });
    }
    rows
}

fn format_timestamp(ts: i64) -> String {
    // Placeholder; real implementation uses chrono.
    format!("2026-08-01") // stub
}
```

**Assumptions Invented:**

1. **TaxAdjustedLot structure**: kernel emits tax lots with quantity (cents, fixed-point), cost basis, unrealized gain, and wash-loss disallowance; each lot carries its own sync timestamp.
2. **"Tax-adjusted"** = cost basis minus disallowed wash losses (per tax code); unrealized gains are kernel-computed at sync time, not live-repriced.
3. **"Stacked"** = per-symbol aggregation; sums quantities and all cost/tax fields within each position.
4. **Quantity encoding**: shares stored as `quantity_cents` (shares × 10,000 fixed-point) to preserve precision; converted to float for display.
5. **Edge cases**: Empty kernel state → empty tab; missing sync_timestamp defaults to 0; symbol names treated as UTF-8 strings (no currency normalization).
6. **No filtering**: All kernel lots included; caller responsible for temporal scoping ("last sync" boundary enforced upstream).
7. **Adjusted basis** = cost basis − wash disallowed; used for tax planning, distinct from live mark-to-market in Positions tab.
8. **Interpretation**: "kernel-exact" means no live repricing; "as-of-last-sync" defers to kernel's sync boundary; tax-adjusted figures are immutable until next kernel sync.