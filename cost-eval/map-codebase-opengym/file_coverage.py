"""How many of openGym's source files does a /map-codebase map name? Prints counts only.

    python3 -I file_coverage.py <opengym-checkout-at-e4a68a9> <map-dir> [<map-dir> ...]

A map dir holds the files a draw added under docs/: docs/high-level-design.md, docs/intent/ and docs/arrows/.
The project's own CLAUDE.md, to which the draw appended LID's block, is left out, because it names files itself.

The source files are the files git tracks at the pin, outside catalogue/ (exercise data and media), whose
extension is one of SOURCE, and whose path doesn't look like a test (TEST). For each draw, a file counts as named:
  - "by whole name" when its file name, extension included, appears in the map's text as a whole name, not
    run on into a longer one (so index.js isn't credited by index.jsx);
  - "by stem" when that, or its name without the extension, appears as a whole word.
These are two rough figures, not bounds; each both over- and under-credits:
  - Both match on the file name alone, and 129 of the 936 files share their name with another file, so one
    mention credits every file of that name.
  - The stem figure credits more: short stems ("index", or a locale's "de") match ordinary words.
  - Neither credits a file that the map covers only by a glob or a folder name.
Naming a file is not the same as describing it.
"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

SOURCE = re.compile(r"\.(js|jsx|mjs|cjs|ts|tsx|swift|kt|java|mc)$")
TEST = re.compile(r"(\.test\.|\.spec\.|/test/|/tests/|__tests__|Tests?/|/androidTest/|/test-)", re.IGNORECASE)
MAP_PARTS = ("docs/high-level-design.md", "docs/intent", "docs/arrows")


def source_files(repo: Path) -> list[str]:
    out = subprocess.run(["git", "-C", str(repo), "ls-files"], capture_output=True, text=True, check=True).stdout
    return [p for p in out.splitlines()
            if not p.startswith("catalogue/") and SOURCE.search(p) and not TEST.search(p)]


def map_text(map_dir: Path) -> str:
    parts = []
    for part in MAP_PARTS:
        p = map_dir / part
        files = [p] if p.is_file() else sorted(f for f in p.rglob("*") if f.is_file()) if p.is_dir() else []
        parts += [f.read_text(errors="replace") for f in files]
    return "\n".join(parts)


def main() -> None:
    repo, maps = Path(sys.argv[1]), [Path(a) for a in sys.argv[2:]]
    files = source_files(repo)
    print(f"source files: {len(files)}")
    for m in maps:
        text = map_text(m)
        by_name = by_stem = 0
        for f in files:
            name = f.rsplit("/", 1)[-1]
            stem = name.rsplit(".", 1)[0]
            if re.search(r"(?<![\w.-])" + re.escape(name) + r"(?![\w.-])", text):
                by_name += 1
                by_stem += 1
            elif re.search(r"(?<![\w])" + re.escape(stem) + r"(?![\w])", text):
                by_stem += 1
        label = m.parent.name if m.name == "map" else m.name  # a draw's records keep its map in <draw>/map/
        print(f"{label}: named by whole name {by_name}, by stem {by_stem}; "
              f"named nowhere {len(files) - by_name} by whole name, {len(files) - by_stem} by stem")


if __name__ == "__main__":
    main()
