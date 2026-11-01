#!/usr/bin/env python3
"""Install public Codex starter files only. No auth, private data or hidden updates."""
import argparse
import json
import os
from pathlib import Path
import stat
import sys
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[1]
VERSION = "0.0.6"

def event(status, path, message=""):
    print(json.dumps({"time": datetime.now(timezone.utc).isoformat(),
                      "action": "bootstrap", "status": status, "item": path,
                      "message": message}, ensure_ascii=False))

def safe_path(path):
    """Do not write through a symlink or into a file used as a directory."""
    p = Path(os.path.abspath(path))
    for node in (p, *p.parents):
        if node.is_symlink():
            raise ValueError("symlink in destination: " + str(node))
    return p

def plan(home, codex_home):
    files = [
        (ROOT / "templates/codex/AGENTS.md", codex_home / "AGENTS.md", "codex/AGENTS.md"),
        (ROOT / "templates/codex/config.example.toml", codex_home / "config.toml", "codex/config.toml"),
    ]
    for directory in sorted((ROOT / "templates/skills").iterdir()):
        if not directory.is_dir() or directory.is_symlink():
            raise ValueError("unsafe skill directory")
        source = directory / "SKILL.md"
        if not source.is_file() or source.is_symlink():
            raise ValueError("missing or unsafe skill: " + directory.name)
        files.append((source, codex_home / "skills" / directory.name / "SKILL.md",
                      "codex/skills/" + directory.name + "/SKILL.md"))
    for source, dest, _ in files:
        if source.is_symlink() or source.stat().st_size > 256 * 1024:
            raise ValueError("unsafe public template")
        safe_path(dest)
        if dest.exists() and not dest.is_file():
            raise ValueError("destination is not a regular file: " + str(dest))
    return files

def main():
    parser = argparse.ArgumentParser(description="Install nonsecret Codex starter templates")
    parser.add_argument("--apply", action="store_true", help="Create only missing files")
    parser.add_argument("--codex-home", help="Explicit Codex profile (also supports CODEX_HOME)")
    args = parser.parse_args()
    home = Path.home()
    target = Path(args.codex_home or os.environ.get("CODEX_HOME") or home / ".codex").expanduser()
    target = safe_path(target)
    created = []
    try:
        files = plan(home, target)
        for source, dest, name in files:
            if dest.exists():
                event("SKIP_EXISTS", name)
                continue
            if not args.apply:
                event("WOULD_CREATE", name)
                continue
            safe_path(dest)
            dest.parent.mkdir(parents=True, exist_ok=True)
            safe_path(dest)
            data = source.read_bytes()
            fd = os.open(dest, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
            created.append(dest)
            with os.fdopen(fd, "wb") as stream:
                stream.write(data)
            if os.name != "nt":
                dest.chmod(stat.S_IRUSR | stat.S_IWUSR)
            event("CREATED", name)
        event("PASS", "bootstrap", "apply" if args.apply else "dry-run")
        return 0
    except Exception as exc:
        for dest in reversed(created):
            try:
                dest.unlink()
            except OSError:
                pass
        event("FAIL", "bootstrap", str(exc))
        return 1

if __name__ == "__main__":
    sys.exit(main())
