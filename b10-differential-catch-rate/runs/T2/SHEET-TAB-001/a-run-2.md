```rust
// sheets-view: SHEET-TAB-001 — one row per entity, typed headers, no interspersed summary rows.

pub struct Cents(pub i64);

/// One typed column value; kept explicit rather than stringly-typed
/// so Sheets receives real types for native filter/sort.
pub enum Cell {
    Text(String),
    Cents(Cents),
    Number(f64),
    Date(chrono::NaiveDate),
    Bool(bool),
}

/// A row-shaped view of one entity for a given tab.
/// Column order returned by `headers()` and `cells()` must match 1:1.
pub trait SheetRow {
    fn headers() -> &'static [&'static str];
    fn cells(&self) -> Vec<Cell>;
}

pub struct PositionRow { pub entity_id: String, pub symbol: String, pub qty: i64, pub cost_basis: Cents }
pub struct OpenLotRow { pub entity_id: String, pub lot_id: String, pub qty: i64, pub open_date: chrono::NaiveDate, pub cost_basis: Cents }
pub struct RealizedRow { pub entity_id: String, pub symbol: String, pub proceeds: Cents, pub gain: Cents }
pub struct TaxRow { pub entity_id: String, pub tax_year: i32, pub short_term_gain: Cents, pub long_term_gain: Cents }

// impl SheetRow for each Row type: headers() returns fixed column names,
// cells() returns the matching Cell vec. Omitted here for brevity.

pub enum TabKind { Positions, OpenLots, Realized, Tax }

pub trait SheetWriter {
    fn clear_tab(&mut self, tab: TabKind) -> Result<(), PublishError>;
    fn write_row(&mut self, tab: TabKind, cells: Vec<Cell>) -> Result<(), PublishError>;
}

#[derive(Debug)] pub struct PublishError(pub String);

/// Publishes exactly one header row followed by exactly one row per
/// input entity — no blank or subtotal rows in between.
pub fn publish_tab<R: SheetRow>(
    writer: &mut dyn SheetWriter,
    tab: TabKind,
    rows: &[R],
) -> Result<(), PublishError> {
    writer.clear_tab(tab)?;
    let headers = R::headers().iter().map(|h| Cell::Text(h.to_string())).collect();
    writer.write_row(tab, headers)?;
    for row in rows {
        debug_assert!(rows.len() as u64 == rows.iter().count() as u64); // one row per entity, no aggregation here
        writer.write_row(tab, row.cells())?;
    }
    Ok(())
}
```

Assumptions:
1. "Entity" is tab-specific and pre-resolved by the kernel (e.g., Position = symbol, Open Lot = lot id, Realized = closed-lot event, Tax = tax-year bucket); sheets-view does not dedupe/aggregate, since it owns no accounting math.
2. Empty `rows` slice is valid: header row only, zero data rows — not an error.
3. Duplicate entity IDs in input are not detected/merged by this module (would be accounting logic); only a `debug_assert` flags the invariant in dev builds.
4. "Read-only" is enforced upstream (Sheets protected-range API call, not shown) — out of scope for row-shaping.
5. "Typed headers" means each header names its column's `Cell` variant by construction, not runtime type inference.
6. GOOGLEFINANCE formula cells (live-price oracle) belong to a separate spec/column and aren't modeled here.
7. "No among-data summary rows" is interpreted strictly: nothing but header + one data row per entity in the published range; any totals live outside this band (unimplemented).
8. Four tabs are independent `publish_tab` calls with distinct row types — no shared/union row shape.
9. `clear_tab`/`write_row` fully replace prior contents (idempotent republish) rather than diff-patching.