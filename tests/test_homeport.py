import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

APP = Path(__file__).resolve().parents[1] / 'scripts' / 'homeport.py'

class HomeportTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='homeport-test-')
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        self.home = self.base / 'profile'
        (self.home / '.codex' / 'skills' / 'useful').mkdir(parents=True)
        (self.home / '.codex' / 'config.toml').write_text('model = "selected-model"\n')
        (self.home / '.codex' / 'AGENTS.md').write_text('Original user guidance')
        (self.home / '.codex' / 'skills' / 'useful' / 'SKILL.md').write_text('Skill content')
        (self.home / '.codex' / 'skills' / 'useful' / 'auth.json').write_text('SECRET')
        (self.home / '.codex' / 'auth.json').write_text('AUTH SECRET')
        (self.home / '.codex' / 'history.jsonl').write_text('private history')
        (self.home / '.codex' / 'state_5.sqlite').write_text('private database')
        (self.home / '.codex' / 'sessions').mkdir()
        (self.home / '.codex' / 'sessions' / 'recent.txt').write_text('session')
        (self.home / '.agents' / 'skills' / 'sample').mkdir(parents=True)
        (self.home / '.agents' / 'skills' / 'sample' / 'SKILL.md').write_text('agent skill')
        self.dest = self.base / 'backups' / 'b1'

    def run_cli(self, command, *args, good=True, home=None):
        cmd = [sys.executable, str(APP), command, '--home', str(home or self.home), *map(str, args)]
        p = subprocess.run(cmd, capture_output=True, text=True)
        if good:
            self.assertEqual(p.returncode, 0, p.stdout + '\n' + p.stderr)
        else:
            self.assertNotEqual(p.returncode, 0, p.stdout + '\n' + p.stderr)
        try:
            return json.loads(p.stdout.strip().splitlines()[-1])
        except (IndexError, json.JSONDecodeError):
            return {'raw': p.stdout}

    def make(self):
        return self.run_cli('backup', '--dir', self.dest)

    def test_backup_manifest_allowlist_no_private_data(self):
        result = self.make()
        self.assertEqual(result['status'], 'PASS')
        rows = json.loads((self.dest / 'manifest.json').read_text())['files']
        paths = {r['path'] for r in rows}
        self.assertIn('codex/config.toml', paths)
        self.assertIn('codex/AGENTS.md', paths)
        self.assertIn('codex/skills/useful/SKILL.md', paths)
        self.assertIn('agents/skills/sample/SKILL.md', paths)
        self.assertNotIn('codex/auth.json', paths)
        self.assertNotIn('codex/history.jsonl', paths)
        self.assertNotIn('codex/skills/useful/auth.json', paths)
        self.assertEqual(self.run_cli('verify','--dir',self.dest)['status'],'PASS')
        if os.name == 'posix':
            self.assertEqual(self.dest.stat().st_mode & 0o777, 0o700)
            self.assertEqual((self.dest / 'manifest.json').stat().st_mode & 0o777, 0o600)

    def test_restore_dry_run_apply_and_rollback_copy(self):
        self.make()
        (self.home / '.codex' / 'config.toml').write_text('changed on target')
        (self.home / '.codex' / 'new-local.txt').write_text('untouched')
        plan = self.run_cli('restore','--dir',self.dest)
        self.assertEqual(plan['status'],'DRY_RUN')
        self.assertEqual((self.home / '.codex' / 'config.toml').read_text(),'changed on target')
        result = self.run_cli('restore','--dir',self.dest,'--apply')
        self.assertEqual(result['status'],'PASS')
        self.assertEqual((self.home / '.codex' / 'config.toml').read_text(),'model = "selected-model"\n')
        self.assertEqual((self.home / '.codex' / 'new-local.txt').read_text(),'untouched')
        self.assertEqual((Path(result['rollback']) / 'old' / 'codex' / 'config.toml').read_text(),'changed on target')

    def test_checksum_tampering_fails_closed(self):
        self.make()
        (self.dest / 'data' / 'codex' / 'AGENTS.md').write_text('tampered')
        self.run_cli('verify','--dir',self.dest,good=False)
        self.run_cli('restore','--dir',self.dest,'--apply',good=False)
        self.assertEqual((self.home / '.codex' / 'config.toml').read_text(),'model = "selected-model"\n')

    def test_traversal_manifest_fails_closed(self):
        self.make()
        manifest = self.dest / 'manifest.json'
        d = json.loads(manifest.read_text())
        d['files'][0]['path'] = 'codex/skills/../../auth.json'
        manifest.write_text(json.dumps(d))
        self.run_cli('restore','--dir',self.dest,'--apply',good=False)

    def test_refuses_git_worktree_backup(self):
        (self.base / 'repo' / '.git').mkdir(parents=True)
        self.run_cli('backup','--dir',self.base / 'repo' / 'private',good=False)

    def test_symlink_source_and_destination_protected(self):
        outside = self.base / 'outside'
        outside.write_text('outside')
        try:
            (self.home / '.codex' / 'skills' / 'useful' / 'slink').symlink_to(outside)
        except (NotImplementedError, OSError):
            self.skipTest('symlinks unavailable')
        self.make()
        self.assertFalse((self.dest / 'data' / 'codex' / 'skills' / 'useful' / 'slink').exists())
        (self.home / '.codex' / 'AGENTS.md').unlink()
        (self.home / '.codex' / 'AGENTS.md').symlink_to(outside)
        self.run_cli('restore','--dir',self.dest,'--apply',good=False)
        self.assertEqual(outside.read_text(),'outside')

    def test_reject_repeated_snapshot_path(self):
        self.make()
        self.run_cli('backup','--dir',self.dest,good=False)

    def test_private_dotenv_and_key_exclusion(self):
        (self.home / '.codex' / 'skills' / 'useful' / '.env.production').write_text('PASSWORD')
        (self.home / '.codex' / 'skills' / 'useful' / 'private.pem').write_text('KEY')
        self.make()
        self.assertFalse((self.dest / 'data' / 'codex' / 'skills' / 'useful' / '.env.production').exists())
        self.assertFalse((self.dest / 'data' / 'codex' / 'skills' / 'useful' / 'private.pem').exists())

    def test_reject_duplicate_manifest_rows(self):
        self.make()
        f = self.dest / 'manifest.json'
        manifest = json.loads(f.read_text())
        manifest['files'].append(manifest['files'][0].copy())
        f.write_text(json.dumps(manifest))
        self.run_cli('verify', '--dir', self.dest, good=False)

    def test_audit_log_outside_git_with_per_file_rows(self):
        logfile = self.base / 'audit' / 'events.jsonl'
        result = self.run_cli('backup', '--dir', self.dest, '--audit-log', logfile)
        self.assertEqual(result['status'], 'PASS')
        rows = [json.loads(x) for x in logfile.read_text().splitlines()]
        self.assertTrue(any(x['action'] == 'backup' and x['status'] == 'FILE' for x in rows))
        self.assertTrue(any(x['action'] == 'backup' and x['status'] == 'PASS' for x in rows))
        self.assertFalse(any('AUTH SECRET' in x for x in logfile.read_text().splitlines()))

    def test_custom_codex_home(self):
        other = self.base / 'another_codex'
        other.mkdir()
        (other / 'config.toml').write_text('custom = true')
        d = self.base / 'custom-backup'
        result = self.run_cli('backup','--codex-home',other,'--dir',d)
        self.assertEqual(result['status'],'PASS')
        self.assertEqual((d / 'data' / 'codex' / 'config.toml').read_text(),'custom = true')

if __name__ == '__main__':
    unittest.main()
