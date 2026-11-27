```rust
// sheets-view crate: ledger Symbol -> GOOGLEFINANCE ticker resolution + formula build
// @spec SHEET-MAP-001

use std::collections::HashMap;

/// Ledger-side instrument identifier.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Symbol(pub String);

/// Subset of `config` relevant to this spec.
pub struct SheetMapConfig {
    /// Per-symbol overrides. Absence of a `Symbol` key means "unset" for
    /// that symbol -> identity resolution, per spec text.
    pub alias_map: HashMap<Symbol, String>,
}

impl SheetMapConfig {
    /// Resolve a ledger Symbol to its GOOGLEFINANCE ticker string.
    /// @spec SHEET-MAP-001
    pub fn resolve_ticker(&self, symbol: &Symbol) -> String {
        self.alias_map
            .get(symbol)
            .cloned()
            .unwrap_or_else(|| symbol.0.clone())
    }

    /// Build the `Price` column formula for a given Symbol.
    /// @spec SHEET-MAP-001
    pub fn build_price_formula(&self, symbol: &Symbol) -> String {
        let ticker = self.resolve_ticker(symbol);
        format!("=GOOGLEFINANCE(\"{}\", \"price\")", ticker)
    }
}
```

Assumptions (invented, not stated by the EARS text):

1. `Symbol` is a newtype over `String` (Eq/Hash/Clone) usable as a map key; the EARS doesn't define its shape.
2. "Unset" is modeled per-symbol (no entry in `alias_map` for that key), not as an optional whole-map. Read "identity when unset" as scoped to the individual symbol's alias, since that's the closer antecedent.
3. Resolution is infallible — every symbol has a defined result (alias or identity), so no `Result`/`Option` return type; no error path exists per the spec's own wording.
4. No normalization: lookup is exact-match (no case-folding, no trimming) since the spec states nothing about symbol normalization.
5. No validation or escaping of the resolved ticker before interpolating into the formula string (e.g., embedded quotes, empty string, whitespace) — spec only says "build the Price formula from the resolved ticker," not that it validates the result. This is a latent gap I'm flagging, not silently fixing.
6. Formula shape: `=GOOGLEFINANCE("<ticker>", "price")`. The EARS says "build the Price formula" but not which GOOGLEFINANCE attribute string to pass; `"price"` is the explicit/documented default I chose over the bare two-arg form for the same result — functionally equivalent, but this attribute-string literal is an invention.
7. No handling of an alias resolving to an empty or malformed ticker — passed through verbatim, since the spec doesn't scope boundary behavior here.
8. Scope respected: no accounting/tax math, no kernel-output types touched — only Symbol-to-ticker mapping and string formula construction, consistent with sheets-view crate boundaries.