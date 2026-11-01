#!/usr/bin/env python3
"""Codex Homeport: portable, conservative profile backup and recovery.

Only local, user-chosen backup directories. Never sends data to a server.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
import re
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import sys
import uuid

SCHEMA = 1
VERSION = "0.0.6"
MAX_FILES = 5000
MAX_FILE_BYTES = 25 * 1024 * 1024
MAX_TOTAL_BYTES = 250 * 1024 * 1024
AUDIT_PATH = None
DIRS = ("codex/skills", "codex/rules", "codex/prompts", "codex/memories", "agents/skills")
FILES = ("codex/config.toml", "codex/AGENTS.md", "codex/instructions.md")
EXCLUDE = frozenset({".git", ".env", "auth.json", "history.jsonl", "sessions", "logs", "log", "backups", "cache", "tmp", "temp", "packages", "node_modules", "__pycache__", "secrets.json", "credentials.json", "token.json", ".ssh", "id_rsa", "id_ed25519", ".aws", ".azure"})


def stamp():
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def _json_event(action, status, **fields):
    return json.dumps({'time': datetime.now(timezone.utc).isoformat(), 'action': action, 'status': status, **fields}, ensure_ascii=False)


def audit(line):
    if AUDIT_PATH is not None:
        AUDIT_PATH.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
        if AUDIT_PATH.exists() and AUDIT_PATH.is_symlink():
            raise ValueError('audit log symlink denied')
        with AUDIT_PATH.open('a', encoding='utf-8') as stream:
            stream.write(line + '\n')
        if os.name == 'posix':
            os.chmod(AUDIT_PATH, 0o600)


def event(action, status, **fields):
    # Never emit user file contents; audit logs still contain potentially private filenames.
    line = _json_event(action, status, **fields)
    print(line)
    audit(line)


def audit_file(action, relative, size, digest):
    audit(_json_event(action, 'FILE', path=relative, size=size, sha256=digest))


def validate_rel(name: str) -> PurePosixPath:
    if not isinstance(name, str) or not name or '\\' in name or ':' in name or '\x00' in name:
        raise ValueError("invalid path in manifest")
    p = PurePosixPath(name)
    if p.is_absolute() or any(x in (".", "..", "") for x in name.split('/')):
        raise ValueError("unsafe path in manifest")
    parts = p.parts
    for x in parts:
        low = x.lower()
        base = low.split('.')[0]
        if (low in EXCLUDE or low.startswith('.env') or low.endswith(('.sqlite', '.sqlite-wal', '.sqlite-shm', '.pem', '.key'))
            or low.endswith((' ', '.')) or any(c in x for c in '<>"|?*')
            or base in ({'con', 'prn', 'aux', 'nul'} | {f'{kind}{i}' for kind in ('com', 'lpt') for i in range(1, 10)})
            or any(ord(c) < 32 for c in x)):
            raise ValueError('excluded file in manifest')
    allowed = (name in FILES or (len(parts) == 2 and parts[0] == 'codex' and parts[1].endswith('.config.toml')) or any(name.startswith(d + '/') for d in DIRS))
    if not allowed:
        raise ValueError("path not on allowlist: " + name)
    return p


def is_symlink_component(path: Path, boundary: Path):
    """Protect all existing nodes between boundary and path inclusive."""
    boundary = boundary.absolute()
    path = path.absolute()
    if not path.is_relative_to(boundary):
        raise ValueError('destination escapes home')
    probe = boundary
    if probe.is_symlink():
        raise ValueError('symlink boundary denied')
    for part in path.relative_to(boundary).parts:
        probe = probe / part
        if probe.is_symlink():
            raise ValueError('symlink denied: ' + str(probe))


def sha256(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def confirm_outside_git(path: Path):
    path = path.expanduser().absolute()
    # A linked parent could point into a tracked worktree without being visible lexically.
    for node in (path, *path.parents):
        if node.is_symlink():
            raise ValueError("Private backup path contains symlink")
    roots = [path, *path.parents]
    if any((q / '.git').exists() for q in roots):
        raise ValueError('Private backup must be OUTSIDE a Git worktree')
    # Also catch Git linked worktrees via git -C; git may not be installed on clean target.
    anchor = next((q for q in roots if q.exists()), None)
    if anchor:
        p = subprocess.run(['git', '-C', str(anchor), 'rev-parse', '--is-inside-work-tree'], capture_output=True, text=True, check=False) if shutil.which('git') else None
        if p and p.returncode == 0 and p.stdout.strip() == 'true':
            raise ValueError('Private backup must be OUTSIDE a Git worktree')


def confirm_outside_profile(path: Path, roots):
    path = path.expanduser().absolute()
    for root in roots.values():
        root = root.expanduser().absolute()
        if path == root or path.is_relative_to(root):
            raise ValueError('Private backup/audit must not be INSIDE live profile')


def homes(args):
    home = Path(args.home).expanduser().absolute()
    codex = Path(args.codex_home).expanduser().absolute() if args.codex_home else Path(os.environ.get('CODEX_HOME', home / '.codex')).expanduser().absolute()
    if codex.is_symlink():
        raise ValueError('Codex home is a symlink; inspect manually')
    return home, {'codex': codex, 'agents': home / '.agents'}


def candidates(roots):
    result = {}
    ch = roots['codex']
    for name in ('config.toml', 'AGENTS.md', 'instructions.md'):
        f = ch / name
        if f.is_file() and not f.is_symlink():
            result['codex/' + name] = f
    if ch.exists():
        for f in ch.glob('*.config.toml'):
            if f.is_file() and not f.is_symlink():
                result['codex/' + f.name] = f
    for dirname in DIRS:
        root_name, subdir = dirname.split('/', 1)
        if roots[root_name].is_symlink():
            continue
        directory = roots[root_name] / subdir
        if directory.is_symlink() or not directory.is_dir():
            continue
        for p in directory.rglob('*'):
            if p.is_symlink() or not p.is_file():
                continue
            rel = dirname + '/' + p.relative_to(directory).as_posix()
            try:
                validate_rel(rel)
            except ValueError:
                continue
            # Avoid following symlink parents even though rglob normally doesn't recurse them.
            if any(parent.is_symlink() for parent in p.parents if parent == directory or directory in parent.parents):
                continue
            result[rel] = p
    return dict(sorted(result.items()))


def target_path(roots, rel):
    p = validate_rel(rel)
    root = roots[p.parts[0]]
    target = root.joinpath(*p.parts[1:])
    is_symlink_component(target, root.parent if root.name == '.codex' or root.name == '.agents' else root)
    return target


def backup(args):
    _, roots = homes(args)
    backup_dir = Path(args.dir).expanduser().absolute()
    confirm_outside_git(backup_dir)
    confirm_outside_profile(backup_dir, roots)
    if backup_dir.exists():
        raise ValueError('Backup directory already exists; choose a NEW directory')
    entries = candidates(roots)
    if not entries:
        raise ValueError('No user configuration found; no empty backup created')
    if len(entries) > MAX_FILES:
        raise ValueError("Too many profile files")
    backup_dir.mkdir(parents=True, mode=0o700)
    try:
        (backup_dir / 'data').mkdir(mode=0o700)
        records = []
        total_bytes = 0
        for rel, src in entries.items():
            size_before = src.stat().st_size
            if size_before > MAX_FILE_BYTES or total_bytes + size_before > MAX_TOTAL_BYTES:
                raise ValueError("Profile exceeds conservative size limits")
            total_bytes += size_before
            dest = backup_dir / 'data' / rel
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(src, dest)
            digest = sha256(dest)
            size = dest.stat().st_size
            if size != size_before or size > MAX_FILE_BYTES:
                raise ValueError("Source changed during backup")
            records.append({'path': rel, 'sha256': digest, 'size': size})
            audit_file('backup', rel, size, digest)
        metadata = {'format': 'codex-homeport', 'schema': SCHEMA, 'created_utc': datetime.now(timezone.utc).isoformat(), 'files': records}
        (backup_dir / 'manifest.json').write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
        # Never make public backups; POSIX owner-only permissions where available.
        if os.name == 'posix':
            for directory, folders, files in os.walk(backup_dir):
                os.chmod(directory, 0o700)
                for f in files:
                    os.chmod(Path(directory) / f, 0o600)
        verify_dir(backup_dir)
        event('backup', 'PASS', files=len(records), backup=str(backup_dir))
    except BaseException:
        shutil.rmtree(backup_dir, ignore_errors=True)
        raise


def verify_dir(backup_dir):
    manifest = backup_dir / 'manifest.json'
    if not manifest.is_file() or manifest.is_symlink():
        raise ValueError('missing or unsafe manifest')
    if manifest.stat().st_size > 4 * 1024 * 1024:
        raise ValueError('Manifest too large')
    obj = json.loads(manifest.read_text(encoding='utf-8'))
    if obj.get('format') != 'codex-homeport' or obj.get('schema') != SCHEMA or not isinstance(obj.get('files'), list):
        raise ValueError('unsupported manifest schema')
    if not obj['files']:
        raise ValueError('empty manifest')
    if len(obj['files']) > MAX_FILES:
        raise ValueError('Too many manifest entries')
    total_bytes = 0
    seen = set()
    seen_portable = set()
    for entry in obj['files']:
        if not isinstance(entry, dict):
            raise ValueError('invalid manifest entry')
        rel = entry.get('path')
        size = entry.get('size')
        digest = entry.get('sha256')
        if type(size) is not int or not 0 <= size <= MAX_FILE_BYTES or not isinstance(digest, str) or not re.fullmatch(r'[a-f0-9]{64}', digest):
            raise ValueError('invalid manifest metadata')
        total_bytes += size
        if total_bytes > MAX_TOTAL_BYTES:
            raise ValueError('Manifest exceeds size limit')
        validate_rel(rel)
        if rel in seen or rel.casefold() in seen_portable:
            raise ValueError('duplicate/case-colliding manifest entry')
        seen.add(rel)
        seen_portable.add(rel.casefold())
        src = backup_dir / 'data' / rel
        is_symlink_component(src, backup_dir)
        if not src.is_file() or src.stat().st_size != size or sha256(src) != digest:
            raise ValueError('corrupt backup entry: ' + rel)
        audit_file('verify', rel, size, digest)
    return obj


def restore(args):
    _, roots = homes(args)
    backup_dir = Path(args.dir).expanduser().absolute()
    confirm_outside_profile(backup_dir, roots)
    obj = verify_dir(backup_dir)
    targets = [(row['path'], backup_dir / 'data' / row['path'], target_path(roots, row['path'])) for row in obj['files']]
    conflicts = sum(dst.exists() for _, _, dst in targets)
    if not args.apply:
        event('restore-plan', 'DRY_RUN', entries=len(targets), existing_to_replace=conflicts, new=len(targets)-conflicts)
        return
    confirm_outside_git(backup_dir)
    # Keep an independently addressable rollback snapshot in a private non-Git directory.
    rollback = backup_dir.parent / (backup_dir.name + '-rollback-' + stamp() + '-' + uuid.uuid4().hex[:8])
    if rollback.exists():
        raise ValueError('rollback path collision')
    rollback.mkdir(parents=True, mode=0o700)
    (rollback / 'old').mkdir(mode=0o700)
    (rollback / 'staged').mkdir(mode=0o700)
    touched = []
    try:
        # Stage and verify each source before any target mutation.
        staged_targets = []
        hashes = {row['path']: row['sha256'] for row in obj['files']}
        for rel, src, dst in targets:
            staged = rollback / 'staged' / rel
            staged.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(src, staged)
            if sha256(staged) != hashes[rel]:
                raise ValueError('Source changed during staging')
            staged_targets.append((rel, staged, dst))
            if dst.exists():
                if not dst.is_file():
                    raise ValueError('existing destination is not a regular file')
                old = rollback / 'old' / rel
                old.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(dst, old)
        for rel, src, dst in staged_targets:
            dst.parent.mkdir(parents=True, exist_ok=True)
            # Check again after directory creation (reject symlink parents).
            root = roots[rel.split('/')[0]]
            is_symlink_component(dst, root.parent if root.name in ('.codex', '.agents') else root)
            existed = dst.exists()
            temp = dst.parent / ('.homeport-' + uuid.uuid4().hex)
            try:
                shutil.copyfile(src, temp)
                os.replace(temp, dst)
            finally:
                temp.unlink(missing_ok=True)
            touched.append((rel, dst, existed))
            audit_file('restore', rel, src.stat().st_size, sha256(src))
        for row in obj['files']:
            dst = target_path(roots, row['path'])
            if sha256(dst) != row['sha256']:
                raise ValueError('post-restore hash mismatch')
        event('restore', 'PASS', files=len(targets), rollback=str(rollback))
    except BaseException:
        for rel, dst, existed in reversed(touched):
            try:
                if existed:
                    shutil.copyfile(rollback / 'old' / rel, dst)
                else:
                    dst.unlink(missing_ok=True)
            except OSError:
                event('rollback', 'FAILED', path=rel)
        raise


def main():
    parser = argparse.ArgumentParser(description='Codex Homeport: conservative Codex profile recovery')
    parser.add_argument('command', choices=('status', 'backup', 'verify', 'restore', 'version'))
    parser.add_argument('--dir', help='Absolute local private backup path')
    parser.add_argument('--home', default=str(Path.home()), help='User home, for isolated tests')
    parser.add_argument('--codex-home', help='Override CODEX_HOME')
    parser.add_argument('--apply', action='store_true', help='Execute restore; default is dry-run')
    parser.add_argument('--audit-log', help='Optional local private JSONL audit log, OUTSIDE Git')
    args = parser.parse_args()
    global AUDIT_PATH
    try:
        if args.audit_log:
            audit_candidate = Path(args.audit_log).expanduser().absolute()
            confirm_outside_git(audit_candidate)
            _, _roots = homes(args)
            confirm_outside_profile(audit_candidate, _roots)
            AUDIT_PATH = audit_candidate
        if args.command in ('backup', 'verify', 'restore') and not args.dir:
            parser.error('--dir required')
        if args.command == 'version':
            event('version', 'PASS', homeport=VERSION)
        elif args.command == 'backup':
            backup(args)
        elif args.command == 'verify':
            obj = verify_dir(Path(args.dir).expanduser().absolute())
            event('verify', 'PASS', files=len(obj['files']))
        elif args.command == 'restore':
            restore(args)
        else:
            _, roots = homes(args)
            event('status', 'PASS', codex_home=str(roots['codex']), file_count=len(candidates(roots)), codex_cli=shutil.which('codex') or 'NOT_FOUND')
    except (ValueError, OSError, KeyError, TypeError, json.JSONDecodeError) as exc:
        event(args.command, 'FAIL', error=str(exc))
        sys.exit(1)

if __name__ == '__main__':
    main()
