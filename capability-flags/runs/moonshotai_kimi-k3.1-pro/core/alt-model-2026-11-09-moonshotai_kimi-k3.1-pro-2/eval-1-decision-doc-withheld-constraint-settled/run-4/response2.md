It would be **overkill here**.

The choice is substantially settled by an inherited constraint: kiosks have no runtime network access, which rules out both networked alternatives. SQLite then follows naturally from the need for predictable local lookups. A cold reader can understand that reasoning from the HLD’s **Key Design Decisions** entry already added.

A full decision doc would become worthwhile if the choice remained genuinely reversible—for example, if future kiosks might have reliable connectivity or richer search requirements. For the current design, the HLD entry is enough.