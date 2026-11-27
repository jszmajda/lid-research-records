SHEET-POS-FORMULA — Per-row live-formula anchoring (Positions tab)

**Ubiquitous**
- SHEET-POS-F-001: The Positions tab SHALL use the fixed column order Symbol(A), Shares(B), Avg Cost/Share(C), Total Basis(D), Price(E), Market Value(F), Unrealized P&L(G), Est. Tax Rate(H), Est. Unrealized Tax (est)(I), Net Unrealized (est)(J), Unrealized %(K), Realized P&L(L), Quote Date(M, zero-based index 12).
- SHEET-POS-F-002: Data rows SHALL begin at the anchored 1-based row `DATA_START_ROW = 2`, beneath the frozen header in row 1; the row number of the i-th (0-based) data row SHALL be `i + 2`.
- SHEET-POS-F-003: Exactly these columns SHALL be live formulas: Price, Market Value, Unrealized P&L, Est. Unrealized Tax (est), Net Unrealized (est), Unrealized %, Quote Date. All other columns SHALL be engine values, including Est. Tax Rate.
- SHEET-POS-F-004: For a data row numbered r, the formulas SHALL be exactly: E `=GOOGLEFINANCE("<ticker>","price")`; F `=Er*Br`; G `=Fr-Dr`; I `=Gr*Hr`; J `=Gr*(1-Hr)`; K `=IF(Dr=0,0,Gr/Dr)`; M `=IFERROR(TEXT(INT(GOOGLEFINANCE("<ticker>","tradetime"))-DATE(1970,1,1),"0"),"")`.
- SHEET-POS-F-005: `<ticker>` SHALL be the alias-map-resolved ticker for the row's symbol (double-quoted), and the Price and Quote Date formulas of a row SHALL use the same resolved ticker.
- SHEET-POS-F-006: Est. Tax Rate SHALL be written as a percent literal with exactly four fractional digits (`ppm/10000`, e.g. `"20.0000%"`), typed as a `userEnteredValue` so Sheets coerces it to the numeric fraction that `=G*H` and `=G*(1-H)` multiply.
- SHEET-POS-F-007: The settle read-back SHALL take Price from column index 4 and Quote Date from column index 12 of the range starting at `DATA_START_ROW`, keyed by the column-0 symbol.
- SHEET-POS-F-008: Open Lots, Realized, Tax accrual and Tax reserve-summary rows SHALL contain no formula cells.

**State-driven**
- SHEET-POS-F-009: WHILE a symbol has no effective tax rate, Est. Tax Rate SHALL be the empty string while I/J/K formulas remain unchanged.

**Unwanted behavior**
- SHEET-POS-F-010: A row's formulas SHALL NOT reference any row number other than their own r, so a row shift cannot mis-pair cells.
- SHEET-POS-F-011: IF two rows carry the same symbol, render_positions SHALL return `Err(ViewError::DuplicateSymbolRow(symbol))` and publish no tab.
- SHEET-POS-F-012: On republish the frozen header SHALL NOT be rewritten and data SHALL be replaced wholesale with tail truncation, so row anchors stay valid; a differing header is a contract violation (panic in the fake).