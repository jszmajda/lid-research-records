I'd keep it as a row in the previews design's Decisions & Alternatives table, not a standalone doc.

A decision doc is for choices a future reader would keep re-litigating without the competing options and criteria. This one is internal to the preview worker. Review API, the HTTP contract, the budget, and the queue don't depend on it, and 2Q is a strong fit for the mixed workload the HLD describes (long one-off screenings plus repeated comparisons). A cold reader will want to know why 2Q and why not LRU or frequency with aging, and a row with those alternatives and their rationale answers that. The length of the debate doesn't change this, since the test is whether the choice stays live once it lands.

I'd make a doc worth it only if something outside the previews node comes to depend on the policy, such as a monitoring or capacity-planning contract that reads cache metrics. That isn't in the design today.

Still waiting on two things from Phase 1: approval of the HLD edit, and whether to use the classic 2Q split (25% probation, 75% main, ghost list up to 50% of the entry count) as the starting values.