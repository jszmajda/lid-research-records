I’d keep this as a **Decisions & Alternatives row**. The length of the debate isn’t the deciding factor; it’s what a future reader needs to understand the choice.

Here, the rationale is compact: protect reused comparison sheets from screening scans, accepting extra bookkeeping and tuning. The decision stays inside the preview cache; the API and render queue don’t depend on which policy wins.

A full decision doc earns its place when future maintainers need a deeper comparison to reconstruct the judgment, especially when other components are designed around it. This choice doesn’t currently meet that bar. I’d preserve the rationale in the row and put the remaining 2Q mechanics in the preview design.