#!/usr/bin/env python3
"""Conservative checks for tracked public code. No guarantee against all secrets."""
from __future__ import annotations
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
BAD_NAMES = {'.env', 'auth.json', 'credentials.json', 'token.json', 'history.jsonl', 'id_rsa', 'id_ed25519'}
BAD_PARTS = {'sessions', 'backups', 'private', '.local', '.snapshots', 'logs', '.ssh'}
TOKEN_PATTERNS = (
    re.compile(r'\bgh[pousr]_[A-Za-z0-9_]{30,}\b'),
    re.compile(r'\bgithub_pat_[A-Za-z0-9_]{30,}\b'),
    re.compile(r'\bsk-[A-Za-z0-9_-]{30,}\b'),
    re.compile(r'-----BEGIN (?:RSA |OPENSSH |EC )?PRIVATE KEY-----'),
    re.compile(r'(?i)(?:api[_-]?key|access[_-]?token|password)\s*[=:]\s*["\'](?:[A-Za-z0-9/+_-]{18,})["\']'),
)


def main():
    result = subprocess.run(['git', 'ls-files', '-z'], cwd=ROOT, capture_output=True, check=True)
    paths = [x.decode('utf-8') for x in result.stdout.split(b'\x00') if x]
    failures = []
    for rel in paths:
        p = pathlib.PurePosixPath(rel)
        pieces = {x.lower() for x in p.parts}
        if p.name.lower() in BAD_NAMES or pieces.intersection(BAD_PARTS) or rel.endswith(('.pem', '.key', '.sqlite', '.sqlite-wal', '.sqlite-shm')):
            failures.append(f'Forbidden tracked path: {rel}')
            continue
        full = ROOT / rel
        if full.is_symlink():
            failures.append(f'Tracked symlink requires manual review: {rel}')
            continue
        if not full.is_file():
            continue
        if full.stat().st_size > 5 * 1024 * 1024:
            failures.append(f'Unexpected large tracked file: {rel}')
            continue
        try:
            contents = full.read_text(encoding='utf-8')
        except (UnicodeDecodeError, OSError):
            failures.append(f'Non-text tracked file needs review: {rel}')
            continue
        if any(pat.search(contents) for pat in TOKEN_PATTERNS):
            failures.append(f'Possible secret in tracked file: {rel}')
    if failures:
        print('\n'.join(failures), file=sys.stderr)
        return 1
    print(f'PASS: checked {len(paths)} tracked public files (heuristic, not proof of secret absence)')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
