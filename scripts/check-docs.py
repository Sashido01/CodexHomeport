#!/usr/bin/env python3
"""Validate bilingual user docs and source microversion consistency."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
PAIRED = ("README.md", "GETTING_STARTED.md", "SECURITY.md", "MAINTENANCE.md", "CI_POLICY.md", "CONTRIBUTING.md")

def main():
    errors = []
    for name in PAIRED:
        for lang in ("en", "ru"):
            path = ROOT / "docs" / lang / name
            if not path.is_file() or len(path.read_text(encoding="utf-8").strip()) < 80:
                errors.append(f"Missing or empty: docs/{lang}/{name}")
    version = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
    if not re.fullmatch(r"0\.0\.\d+", version):
        errors.append(f"Invalid microversion: {version!r}")
    for filename, pattern in (
        ("scripts/homeport.py", r'VERSION = "([^"]+)"'),
        ("scripts/homeport.ps1", r"\$Version = '([^']+)'"),
        ("scripts/homeport-menu.ps1", r"Codex Homeport (\d+\.\d+\.\d+)"),
    ):
        data = (ROOT / filename).read_text(encoding="utf-8")
        match = re.search(pattern, data)
        if not match or match.group(1) != version:
            errors.append(f"Version mismatch: {filename}")
    root_readme = (ROOT / "README.md").read_text(encoding="utf-8")
    if "docs/en/README.md" not in root_readme or "docs/ru/README.md" not in root_readme:
        errors.append("Missing English/Russian navigation in root README")
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"PASS: English/Russian documentation and version {version}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
