I recommend a decision doc. A cold reader would reasonably reconsider 2Q against LRU and aged-frequency eviction, and the choice trades scan resistance against implementation and tuning complexity. The preview LLD will be shaped around that choice.

It should be owned by the previews segment and linked from the LLD’s Decisions & Alternatives table. It will record the selection criteria, the three evaluated policies, why 2Q was selected, and the boundary that the API, render queue, and 12 GiB budget remain unchanged.

Please confirm that you want the decision doc, and approve the Phase 1 HLD update, so I can draft it during Phase 2.