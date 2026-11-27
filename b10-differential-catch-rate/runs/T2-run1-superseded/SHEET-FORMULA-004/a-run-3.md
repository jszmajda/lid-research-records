```rust
// sheets-view: Tax tab projection (SHEET-FORMULA-004)
// Kernel owns tax math; this module only maps kernel output to sheet rows.

pub enum TaxTerm { ShortTerm, LongTerm }

/// One kernel-exact tax lot figure, already computed upstream.
pub struct TaxLotFigure {
    pub symbol: String,
    pub lot_id: LotId,
    pub acquired: NaiveDate,
    pub term: TaxTerm,
    pub cost_basis_cents: i64,
    pub proceeds_cents: i64,
    pub realized_gain_cents: i64,
    pub unrealized_gain_cents: Option<i64>, // None once lot fully closed
}

/// Kernel's tax snapshot as of the last settle/marks-read-back pass.
pub struct TaxTabSnapshot {
    pub as_of_sync: DateTime<Utc>, // settle-pass timestamp; never "now"
    pub lots: Vec<TaxLotFigure>,   // stacked: one row per lot, unaggregated
}

/// Projects kernel-exact figures onto the Tax tab. No GOOGLEFINANCE formula,
/// no live price — distinct from `project_positions_tab`, which does read a
/// live-price formula column.
pub fn project_tax_tab(snapshot: &TaxTabSnapshot) -> SheetTab {
    let mut rows = Vec::with_capacity(snapshot.lots.len() + 1);
    rows.push(SheetRow::banner(format!(
        "Tax — as of last sync {}",
        snapshot.as_of_sync.to_rfc3339()
    )));
    for lot in &snapshot.lots {
        rows.push(SheetRow::from_lot(lot));
    }
    SheetTab { name: "Tax".into(), rows, formulas: Vec::new() }
}
```

Assumptions (invented, not derivable from the EARS text alone):

1. "Kernel-exact" means values are pre-computed by the kernel/accounting core and passed in as plain data (`i64` Cents) — sheets-view does zero math, only formatting/row-mapping, per the given constraint.
2. "Stacked" interpreted as one row per tax lot (short-term/long-term lots listed individually, not netted into one per-symbol total) — the reading that best contrasts with a single aggregated "estimate" number on Positions. An alternative reading (stacked = ST/LT subtotal rows beneath each symbol) was rejected as less literal a fit for "kernel-exact... distinct from... estimate."
3. "As-of-last-sync" is carried as an explicit `DateTime<Utc>` field surfaced in a banner row, so the tab visibly timestamps itself against the live Positions tab rather than relying on sheet metadata.
4. `unrealized_gain_cents` is `Option<i64>`: `None` once a lot is fully closed (no live price to mark it against) — boundary case for lots with zero remaining shares.
5. Money fields are `i64` Cents per the project convention; no `f64` anywhere.
6. `formulas: Vec::new()` explicitly asserts the Tax tab contains no `GOOGLEFINANCE` (or other live-formula) cells — the mechanism distinguishing it from Positions.
7. Empty `lots` (e.g., no lots yet synced) renders as banner-only with zero data rows — no error, since kernel absence-of-data is a valid state, not an invalid one.
8. Currency/symbol validity, lot ID uniqueness, and negative-cents sanity are assumed already enforced upstream by the kernel; sheets-view does not re-validate, consistent with "owns no accounting or tax math."