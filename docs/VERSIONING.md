# Micro-versioning

The first public development baseline is `0.0.0`; changes advance one patch step (`0.0.1`, `0.0.2`, `0.0.3`, ...). Every released patch has a source Git commit, tag `vX.Y.Z`, CHANGELOG, tests and documented known limits. The previous, **untagged** 0.1.0 draft was never declared a public release; the version line was reset before initial publication, without discarding its Git history.

Changes are finished when acceptance criteria for a scoped version pass, or labeled PARTIAL with concrete remaining blockers. Never fabricate external OS validation or GitHub publication. No automatic next task after a version closes.
