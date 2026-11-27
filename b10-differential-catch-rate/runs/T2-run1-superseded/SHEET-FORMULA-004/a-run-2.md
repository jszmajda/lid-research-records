```rust
// sheets-view crate: projects kernel output only; no accounting/tax math here.

pub type Cents = i64;

/// Precomputed by the kernel's settle pass. sheets-view only copies fields.
pub struct KernelTaxLot {
    pub symbol: String,
    pub lot_id: String,
    pub cost_basis: Cents,
    pub proceeds: Cents,
    pub realized_gain: Cents,
    pub unrealized_gain: Cents, // from last marks read-back, not live
    pub long_term: bool,
}

pub struct KernelTaxSnapshot {
    pub last_sync: chrono::DateTime<chrono::Utc>, // settle-pass completion
    pub lots: Vec<KernelTaxLot>,
}

/// Cell values on this tab are always literals — never a GOOGLEFINANCE
/// formula — enforcing kernel-exactness at the type level.
pub enum TaxCell {
    Cents(Cents),
    Text(String),
    Timestamp(chrono::DateTime<chrono::Utc>),
}

pub struct TaxTabRow {
    pub cells: Vec<TaxCell>,
}

pub struct TaxTabView {
    pub as_of_last_sync: chrono::DateTime<chrono::Utc>,
    pub rows: Vec<TaxTabRow>, // one per stacked tax lot
    pub totals: TaxTabRow,
}

/// Projects the kernel's tax snapshot straight to tab rows. No gain/basis
/// arithmetic occurs here — that is kernel/tax-math territory.
pub fn project_tax_tab(snap: &KernelTaxSnapshot) -> TaxTabView {
    let rows = snap.lots.iter().map(|l| TaxTabRow {
        cells: vec![
            TaxCell::Text(l.symbol.clone()),
            TaxCell::Text(l.lot_id.clone()),
            TaxCell::Cents(l.cost_basis),
            TaxCell::Cents(l.proceeds),
            TaxCell::Cents(l.realized_gain),
            TaxCell::Cents(l.unrealized_gain),
            TaxCell::Text(if l.long_term { "LT".into() } else { "ST".into() }),
        ],
    }).collect::<Vec<_>>();

    let totals = TaxTabRow {
        cells: vec![TaxCell::Timestamp(snap.last_sync)],
    };

    TaxTabView { as_of_last_sync: snap.last_sync, rows, totals }
}
```

Assumptions:
1. `Cents = i64`, per stated workspace convention.
2. "Kernel-exact" interpreted as: every value comes verbatim from the kernel's persisted tax snapshot; sheets-view performs no subtraction/derivation (respects "owns no accounting or tax math"), only field mapping — corrected from an earlier draft that mistakenly recomputed gains here.
3. "Stacked" interpreted as one row per tax lot (not one row per symbol), since lot-level short/long-term distinction is the natural tax granularity distinct from Positions' per-symbol rollup.
4. "As-of-last-sync" is a single snapshot timestamp on the whole tab (from settle-pass completion), not per-row, since all lots settle together.
5. Distinctness from Positions enforced structurally: `TaxCell` has no formula variant, so a GOOGLEFINANCE string can never land on this tab; Positions' live estimate lives in a separate view type entirely.
6. Boundary — empty snapshot (`lots` empty): render totals row only, zeroed, not an absent/blank tab.
7. Boundary — no settle pass has ever run: not modeled; assumed an upstream invariant (kernel snapshot always carries a valid `last_sync`) rather than an `Option`, to avoid inventing a "never synced" placeholder unaddressed by the EARS.
8. Long/short-term boolean assumed precomputed upstream (kernel), not derived here, consistent with the no-tax-math constraint.