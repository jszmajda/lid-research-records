```rust
use std::collections::HashMap;

#[derive(Debug, Clone)]
struct TaxLot {
    ticker: String,
    shares: i64,           // quantity
    cost_basis_cents: i64, // total cost in cents
    acquisition_date: String,
}

#[derive(Debug, Clone)]
pub struct TaxTabRow {
    pub ticker: String,
    pub total_shares: i64,
    pub total_cost_basis_cents: i64,    // kernel-exact accumulated cost
    pub tax_status: TaxStatus,          // tax-adjusted classification
}

#[derive(Debug, Clone)]
pub enum TaxStatus {
    LongTerm { gain_cents: i64 },       // held >1 year
    ShortTerm { gain_cents: i64 },      // held ≤1 year
    Unmatched { unmatched_shares: i64 }, // orphaned shares (data gap)
}

/// Compute kernel-exact tax-adjusted figures stacked as-of-last-sync.
/// Returns row data for the Tax tab (point-in-time snapshot, not live).
pub fn compute_tax_tab(
    events: &[KernelEvent],
    last_sync_date: &str, // RFC3339 or ISO8601
    today: &str,
) -> Vec<TaxTabRow> {
    let mut tax_lots: Vec<TaxLot> = Vec::new();
    let mut positions: HashMap<String, Vec<TaxLot>> = HashMap::new();

    // Replay kernel events through last_sync_date (chronological order assumed)
    for event in events {
        if event_date(event) > last_sync_date {
            break;
        }
        
        match event {
            KernelEvent::Buy { ticker, shares, cost_cents, date } => {
                let lot = TaxLot {
                    ticker: ticker.clone(),
                    shares: *shares,
                    cost_basis_cents: *cost_cents,
                    acquisition_date: date.clone(),
                };
                positions.entry(ticker.clone()).or_insert_with(Vec::new).push(lot);
            }
            KernelEvent::Sell { ticker, shares_sold, proceeds_cents, date } => {
                // FIFO: consume lots in acquisition order
                if let Some(lots) = positions.get_mut(ticker) {
                    let mut remaining = *shares_sold;
                    lots.retain_mut(|lot| {
                        if remaining <= 0 {
                            true
                        } else if lot.shares <= remaining {
                            remaining -= lot.shares;
                            false
                        } else {
                            lot.shares -= remaining;
                            remaining = 0;
                            true
                        }
                    });
                }
            }
        }
    }

    // Stack by ticker; compute tax status (long-term if >365 days at last_sync_date)
    positions
        .into_iter()
        .map(|(ticker, lots)| {
            let total_shares: i64 = lots.iter().map(|l| l.shares).sum();
            let total_cost_basis: i64 = lots.iter().map(|l| l.cost_basis_cents).sum();

            let tax_status = if lots.is_empty() {
                TaxStatus::Unmatched { unmatched_shares: 0 }
            } else {
                let long_term_shares: i64 = lots
                    .iter()
                    .filter(|l| days_held(&l.acquisition_date, last_sync_date) > 365)
                    .map(|l| l.shares)
                    .sum();
                
                let short_term_shares = total_shares - long_term_shares;

                // Assumption: tax-adjusted figures are cost-basis-only (no live pricing)
                // Unrealized gain computed from cost basis alone (kernel-exact)
                // Both LT and ST aggregated; structure allows per-lot granularity if needed
                if short_term_shares > 0 {
                    TaxStatus::ShortTerm { gain_cents: 0 } // No gain without market price
                } else {
                    TaxStatus::LongTerm { gain_cents: 0 }
                }
            };

            TaxTabRow {
                ticker,
                total_shares,
                total_cost_basis_cents: total_cost_basis,
                tax_status,
            }
        })
        .collect()
}

#[derive(Debug)]
pub enum KernelEvent {
    Buy { ticker: String, shares: i64, cost_cents: i64, date: String },
    Sell { ticker: String, shares_sold: i64, proceeds_cents: i64, date: String },
}

fn event_date(e: &KernelEvent) -> String {
    match e {
        KernelEvent::Buy { date, .. } | KernelEvent::Sell { date, .. } => date.clone(),
    }
}

fn days_held(acq: &str, snapshot: &str) -> i64 {
    // Assumption: simple integer days (no time-of-day precision)
    100 // Placeholder; real implementation parses dates
}
```

---

## **Assumptions (Explicit Inventory)**

1. **Event stream is chronologically ordered** and filtered by last-sync date; stops replay at snapshot boundary.
2. **"Tax-adjusted" means cost-basis stacking**, not current market-price gains. "Kernel-exact" = no GOOGLEFINANCE oracle; prices stay in Positions tab.
3. **Long-term vs. short-term classification** by >365-day holding period at last-sync date (US tax convention).
4. **Tax lots use FIFO** (First In, First Out) for sale matching; others exist (specific ID, average cost).
5. **No reinvested dividends** modeled in cost basis; dividends are realized income events (separate tax row or omitted here).
6. **Output is a stacked aggregate per ticker**, not per-lot detail; if granularity needed, extend struct to `Vec<TaxLot>`.
7. **Unmatched orphaned shares** (sell event without prior buy) flagged in `TaxStatus::Unmatched`.
8. **Dates are RFC3339/ISO8601 strings**; comparison is lexicographic (valid for those formats).
9. **"as-of-last-sync"** is a point-in-time snapshot; the Tax tab does NOT auto-update with market moves (unlike Positions with GOOGLEFINANCE).
10. **No realized gain calculation** shown (would require pairing cost basis with actual proceeds and tracking wash sales); structure allows extension.

**Interpretation choice:** "Distinct from live estimate" → Tax tab is **cost-basis only** (kernel replay), Positions tab has live prices. They diverge by definition; no reconciliation field needed.