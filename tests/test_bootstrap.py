"""Synthetic, isolated tests for public profile bootstrap."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BOOT = ROOT / "scripts/bootstrap.py"

class BootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.profile = Path(self.temp.name) / "codex-profile"
        self.env = dict(os.environ, CODEX_HOME=str(self.profile))

    def run_setup(self, *args, ok=True):
        r = subprocess.run([sys.executable, str(BOOT), *args],
                           env=self.env, text=True, capture_output=True)
        if ok:
            self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        else:
            self.assertNotEqual(r.returncode, 0)
        return [json.loads(x) for x in r.stdout.splitlines() if x]

    def test_dry_run_creates_nothing(self):
        rows = self.run_setup()
        self.assertTrue(any(x["status"] == "WOULD_CREATE" for x in rows))
        self.assertFalse(self.profile.exists())

    def test_apply_creates_reusable_defaults(self):
        rows = self.run_setup("--apply")
        self.assertTrue(any(x["status"] == "CREATED" for x in rows))
        self.assertTrue((self.profile / "config.toml").is_file())
        self.assertTrue((self.profile / "AGENTS.md").is_file())
        self.assertTrue((self.profile / "skills/homeport-recovery/SKILL.md").is_file())
        self.assertTrue((self.profile / "skills/homeport-diagnostics/SKILL.md").is_file())
        self.assertTrue((self.profile / "skills/homeport-review/SKILL.md").is_file())

    def test_existing_profile_remains_unchanged(self):
        self.profile.mkdir()
        (self.profile / "AGENTS.md").write_text("my private instructions")
        (self.profile / "config.toml").write_text('model = "mine"')
        self.run_setup("--apply")
        self.assertEqual((self.profile / "AGENTS.md").read_text(), "my private instructions")
        self.assertEqual((self.profile / "config.toml").read_text(), 'model = "mine"')
        rows = self.run_setup("--apply")
        self.assertFalse(any(x["status"] == "CREATED" for x in rows))

    @unittest.skipUnless(hasattr(os, "symlink"), "symlinks unavailable")
    def test_symlink_destination_refused_without_changes(self):
        outside = Path(self.temp.name) / "outside"
        outside.mkdir()
        try:
            self.profile.symlink_to(outside, target_is_directory=True)
        except (OSError, NotImplementedError):
            self.skipTest("OS does not allow symlinks")
        self.run_setup("--apply", ok=False)
        self.assertEqual(list(outside.iterdir()), [])

    def test_explicit_home_supported(self):
        other = Path(self.temp.name) / "alternative"
        self.run_setup("--apply", "--codex-home", str(other))
        self.assertTrue((other / "AGENTS.md").exists())
        self.assertFalse(self.profile.exists())

if __name__ == "__main__":
    unittest.main()
