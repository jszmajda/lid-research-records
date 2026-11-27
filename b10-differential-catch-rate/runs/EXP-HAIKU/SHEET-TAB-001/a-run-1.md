# Rust Implementation Sketch: SHEET-TAB-001

```rust
use std::collections::BTreeMap;

#[derive(Clone, Debug)]
enum ColumnType { String, Number, Currency, Date }

#[derive(Clone)]
struct TypedHeader { name: String, col_type: ColumnType }

struct ViewTab {
    name: &'static str,
    headers: Vec<TypedHeader>,
    rows: BTreeMap<String, BTreeMap<String, String>>, // entity_id -> {col_name -> value}
}

impl ViewTab {
    fn new(name: &'static str, headers: Vec<TypedHeader>) -> Self {
        ViewTab { name, headers, rows: BTreeMap::new() }
    }

    fn add_entity(&mut self, entity_id: String, data: BTreeMap<String, String>) {
        self.rows.insert(entity_id, data);
    }

    fn to_sheets_format(&self) -> Vec<Vec<String>> {
        let mut output = vec![];
        
        // Header row with type hints for Sheets
        output.push(
            self.headers.iter()
                .map(|h| format!("{}:{:?}", h.name, h.col_type))
                .collect()
        );

        // Data rows: one per entity (BTreeMap iteration order)
        for (_, entity_data) in &self.rows {
            let row: Vec<String> = self.headers.iter()
                .map(|h| entity_data.get(&h.name).cloned().unwrap_or_default())
                .collect();
            output.push(row);
        }

        output
    }
}

pub struct SheetTabs {
    positions: ViewTab,
    open_lots: ViewTab,
    realized: ViewTab,
    tax: ViewTab,
}

impl SheetTabs {
    pub fn new() -> Self {
        SheetTabs {
            positions: ViewTab::new("Positions", vec![
                TypedHeader { name: "Entity".into(), col_type: ColumnType::String },
                TypedHeader { name: "Qty".into(), col_type: ColumnType::Number },
                TypedHeader { name: "Basis".into(), col_type: ColumnType::Currency },
            ]),
            open_lots: ViewTab::new("Open Lots", vec![
                TypedHeader { name: "Entity".into(), col_type: ColumnType::String },
                TypedHeader { name: "LotId".into(), col_type: ColumnType::String },
                TypedHeader { name: "Qty".into(), col_type: ColumnType::Number },
            ]),
            realized: ViewTab::new("Realized", vec![
                TypedHeader { name: "Entity".into(), col_type: ColumnType::String },
                TypedHeader { name: "Gain".into(), col_type: ColumnType::Currency },
            ]),
            tax: ViewTab::new("Tax", vec![
                TypedHeader { name: "Entity".into(), col_type: ColumnType::String },
                TypedHeader { name: "LongTerm".into(), col_type: ColumnType::Currency },
            ]),
        }
    }

    pub fn publish(&self) -> Vec<(&'static str, Vec<Vec<String>>)> {
        vec![
            (self.positions.name, self.positions.to_sheets_format()),
            (self.open_lots.name, self.open_lots.to_sheets_format()),
            (self.realized.name, self.realized.to_sheets_format()),
            (self.tax.name, self.tax.to_sheets_format()),
        ]
    }
}
```

## Assumptions (Explicit Inventory)

1. **Entity**: A string identifier (e.g., ticker symbol, security ID, or account).
2. **"Typed headers"**: Column names paired with type hints (String/Number/Currency/Date) to inform Sheets about data interpretation.
3. **"Publish"**: Generate row-major Vec<Vec<String>> suitable for Google Sheets API `batchUpdate` or CSV export.
4. **One row per entity**: BTreeMap enforces uniqueness by entity_id; deterministic sort-order supports stable filtering/sort in Sheets.
5. **No summary rows**: Strict constraint—every row represents exactly one entity; no aggregate/subtotal rows.
6. **Missing values**: Default to empty string (allows Sheets native blank cells, preserving filter logic).
7. **Tab schemas**: Positions (entity, qty, basis), Open Lots (entity, lot_id, qty), Realized (entity, gain), Tax (entity, long_term gain)—inferred from typical portfolio workflows.
8. **No validation**: Assumes caller populates correct columns; row construction is caller's responsibility.
9. **Interpretation**: "Per-entity data band" means all data for one entity clustered in a single row; "native Sheets filtering/sorting work directly" is achieved by strict tabular format (headers → data, no annotations/metadata rows).