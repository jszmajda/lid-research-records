```rust
// sheets-view crate: Tax tab projection (no accounting/tax math — kernel already computed it)

pub type Cents = i64;

#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum TaxTerm { ShortTerm, LongTerm }

/// One kernel-computed lot, valued at the last completed marks settle pass —
/// never GOOGLEFINANCE, never "now".
pub struct TaxRow {
    pub symbol: String,
    pub term: TaxTerm,
    pub cost_basis_cents: Cents,
    pub realized_gain_cents: Cents,
    pub unrealized_gain_cents: Cents,
    pub as_of_sync: chrono::DateTime<chrono::Utc>,
}

/// A stacked (subtotaled) block: per-lot rows + a term subtotal row.
pub struct TaxStack {
    pub term: TaxTerm,
    pub rows: Vec<TaxRow>,
    pub subtotal_cost_basis_cents: Cents,
    pub subtotal_realized_gain_cents: Cents,
    pub subtotal_unrealized_gain_cents: Cents,
}

/// Projects the kernel's settled snapshot into Tax-tab stacks.
/// Pure read of kernel output; asserts no live pricing is consulted.
pub fn project_tax_tab(snapshot: &KernelSnapshot) -> Vec<TaxStack> {
    let mut by_term: std::collections::BTreeMap<TaxTerm, Vec<TaxRow>> = Default::default();

    for lot in &snapshot.tax_lots {
        let mark = snapshot.marks.get(&lot.symbol)
            .expect("settle pass guarantees a mark for every held lot; no live fallback");
        let row = TaxRow {
            symbol: lot.symbol.clone(),
            term: lot.term_as_of(snapshot.as_of_sync),
            cost_basis_cents: lot.cost_basis_cents,
            realized_gain_cents: lot.realized_gain_cents,
            unrealized_gain_cents: mark.price_cents * lot.quantity - lot.cost_basis_cents,
            as_of_sync: snapshot.as_of_sync,
        };
        by_term.entry(row.term).or_default().push(row);
    }

    by_term.into_iter().map(|(term, rows)| {
        let (cb, rg, ug) = rows.iter().fold((0, 0, 0), |(cb, rg, ug), r|
            (cb + r.cost_basis_cents, rg + r.realized_gain_cents, ug + r.unrealized_gain_cents));
        TaxStack { term, rows, subtotal_cost_basis_cents: cb,
                   subtotal_realized_gain_cents: rg, subtotal_unrealized_gain_cents: ug }
    }).collect()
}
```

Assumptions:
1. "Kernel-exact" = values come verbatim from the kernel/ledger crate; sheets-view performs zero math, only grouping/formatting.
2. "Stacked" = per-lot rows grouped and subtotaled by tax term (short/long), a report-stack layout, not a UI stack widget.
3. "As-of-last-sync" = valued against `snapshot.as_of_sync`'s settled marks, not wall-clock or GOOGLEFINANCE.
4. A held lot missing a settled mark is a hard error (`expect`/`Result::Err` in production, not shown) rather than a live-price fallback — falling back would violate "distinct from Positions live estimate."
5. Distinctness from Positions is enforced structurally: `TaxRow` never touches the live-price path and is a separate type from any Positions row.
6. Term classification (`term_as_of`) uses a ≥366-day holding-period rule; EARS doesn't specify this, and real logic belongs in the kernel, not sheets-view.
7. Empty `tax_lots` yields an empty `Vec<TaxStack>` (empty tab), not an error.
8. Function returns owned data only; actual Sheets API cell-writing is a separate concern downstream.