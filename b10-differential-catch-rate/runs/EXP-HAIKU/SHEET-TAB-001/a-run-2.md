```rust
// SHEET-TAB-001 implementation sketch
// Publishes four tabs with one data row per entity, typed headers, no summary rows

use std::collections::HashMap;

#[derive(Debug, Clone)]
pub struct EntityPosition {
    pub entity: String,
    pub quantity: i64,           // shares in smallest unit
    pub cost_basis_cents: i64,   // total accumulated cost
    pub market_value_cents: i64, // =GOOGLEFINANCE formula in Sheets
}

#[derive(Debug, Clone)]
pub struct EntityOpenLot {
    pub entity: String,
    pub open_quantity: i64,           // aggregated open shares
    pub open_cost_basis_cents: i64,   // aggregated open cost
    pub oldest_acquisition_date: String, // earliest YYYY-MM-DD
}

#[derive(Debug, Clone)]
pub struct EntityRealized {
    pub entity: String,
    pub shares_realized: i64,      // lifetime sum
    pub proceeds_cents: i64,       // lifetime sum
    pub cost_basis_cents: i64,     // lifetime sum
    pub gain_loss_cents: i64,      // proceeds - cost
}

#[derive(Debug, Clone)]
pub struct EntityTax {
    pub entity: String,
    pub tax_year: i32,
    pub proceeds_cents: i64,
    pub cost_basis_cents: i64,
    pub gain_loss_cents: i64,
}

pub struct SheetTabs {
    pub positions: Vec<EntityPosition>,
    pub open_lots: Vec<EntityOpenLot>,
    pub realized: Vec<EntityRealized>,
    pub tax: Vec<EntityTax>,
}

impl SheetTabs {
    /// Create tabs from kernel state, aggregating per entity.
    /// Each tab produces exactly one row per entity.
    pub fn from_kernel(
        positions: HashMap<String, (i64, i64, i64)>, // entity -> (qty, cost, mkt_value)
        open_lots: HashMap<String, (i64, i64, String)>, // entity -> (qty, cost, oldest_date)
        realized: HashMap<String, (i64, i64, i64)>, // entity -> (shares, proceeds, cost)
        tax_by_entity_year: HashMap<(String, i32), (i64, i64)>, // (entity, year) -> (proceeds, cost)
    ) -> Self {
        let positions = positions
            .into_iter()
            .map(|(entity, (qty, cost, mkt))| EntityPosition {
                entity,
                quantity: qty,
                cost_basis_cents: cost,
                market_value_cents: mkt,
            })
            .collect();

        let open_lots = open_lots
            .into_iter()
            .map(|(entity, (qty, cost, date))| EntityOpenLot {
                entity,
                open_quantity: qty,
                open_cost_basis_cents: cost,
                oldest_acquisition_date: date,
            })
            .collect();

        let realized = realized
            .into_iter()
            .map(|(entity, (shares, proceeds, cost))| EntityRealized {
                entity,
                shares_realized: shares,
                proceeds_cents: proceeds,
                cost_basis_cents: cost,
                gain_loss_cents: proceeds - cost,
            })
            .collect();

        let tax: Vec<EntityTax> = tax_by_entity_year
            .into_iter()
            .map(|((entity, year), (proceeds, cost))| EntityTax {
                entity,
                tax_year: year,
                proceeds_cents: proceeds,
                cost_basis_cents: cost,
                gain_loss_cents: proceeds - cost,
            })
            .collect();

        SheetTabs { positions, open_lots, realized, tax }
    }

    /// Convert to native Sheets format (TAB_NAME\tCOL1\tCOL2\n...)
    /// Headers are implicit column names; no summary/total rows appended.
    pub fn to_sheet_batch(&self) -> Vec<(&'static str, Vec<Vec<String>>)> {
        vec![
            ("Positions", self.position_rows()),
            ("Open Lots", self.open_lot_rows()),
            ("Realized", self.realized_rows()),
            ("Tax", self.tax_rows()),
        ]
    }

    fn position_rows(&self) -> Vec<Vec<String>> {
        std::iter::once(vec![
            "entity".into(), "quantity".into(), "cost_basis_cents".into(),
            "market_value_cents".into(),
        ])
        .chain(self.positions.iter().map(|p| vec![
            p.entity.clone(),
            p.quantity.to_string(),
            p.cost_basis_cents.to_string(),
            p.market_value_cents.to_string(),
        ]))
        .collect()
    }

    fn open_lot_rows(&self) -> Vec<Vec<String>> {
        // Headers + one row per entity, no subtotals
        std::iter::once(vec![
            "entity".into(), "open_quantity".into(), "open_cost_cents".into(),
            "oldest_date".into(),
        ])
        .chain(self.open_lots.iter().map(|l| vec![
            l.entity.clone(),
            l.open_quantity.to_string(),
            l.open_cost_basis_cents.to_string(),
            l.oldest_acquisition_date.clone(),
        ]))
        .collect()
    }

    fn realized_rows(&self) -> Vec<Vec<String>> {
        std::iter::once(vec![
            "entity".into(), "shares_realized".into(), "proceeds_cents".into(),
            "cost_basis_cents".into(), "gain_loss_cents".into(),
        ])
        .chain(self.realized.iter().map(|r| vec![
            r.entity.clone(),
            r.shares_realized.to_string(),
            r.proceeds_cents.to_string(),
            r.cost_basis_cents.to_string(),
            r.gain_loss_cents.to_string(),
        ]))
        .collect()
    }

    fn tax_rows(&self) -> Vec<Vec<String>> {
        std::iter::once(vec![
            "entity".into(), "tax_year".into(), "proceeds_cents".into(),
            "cost_basis_cents".into(), "gain_loss_cents".into(),
        ])
        .chain(self.tax.iter().map(|t| vec![
            t.entity.clone(),
            t.tax_year.to_string(),
            t.proceeds_cents.to_string(),
            t.cost_basis_cents.to_string(),
            t.gain_loss_cents.to_string(),
        ]))
        .collect()
    }
}
```

**Explicit Assumptions:**

1. **One row per entity, not per position/lot/transaction**: SHEET-TAB-001 says "one row per entity"; Open Lots and Realized must aggregate per entity (sums/earliest-date).
2. **Tax is one row per entity per year**, not lifetime—disambiguates "single row" by adding year dimension; meaningful for tax filing.
3. **Entity is a string ticker/ISIN**, immutable identifier across all tables.
4. **Quantity is integer shares**; costs are integer cents (no float).
5. **Market value is populated externally** (Sheets GOOGLEFINANCE formula); sketched as field but not computed here (sheets-view owns that projection).
6. **No summary rows**: headers + data rows only; Sheets sorting/filtering is native (no pre-computed totals).
7. **Invalid/null input**: Assumed filtered upstream by kernel; no error handling for malformed entity names or negative money.
8. **Typed headers**: Column names are the first row; types are implicit (string/int).
9. **Gain/loss computed here**: proceeds_cents - cost_basis_cents (realized and tax rows).
10. **Fallback for missing data**: Unrepresented entities simply omit rows (no padding/zero-rows).

**Interpretation choice:** "One row per entity" is strict—enables native Sheets filter/sort *per entity band*, not per transaction. Aggregation preserves entity-level summary without hierarchical drill-down (per requirement: no summary rows).