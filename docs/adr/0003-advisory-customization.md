# ADR-0003: Advisory customization templates

Status: Accepted | 2026-11-01

## Decision

Publish general customization guidance and sanitized examples, while leaving installation and application of personal settings to the user through native Codex mechanisms. Model recommendations remain advisory; do not silently change a selected model, reasoning, approval, sandbox, authentication, or MCP configuration. Do not encode owner-specific allowance percentages as universal thresholds.

## Rationale

Model catalogs, account access, allowance reporting, MCP dependencies, and project instructions vary by user and change over time. A static preset cannot establish compatibility or authorization. Homeport already provides verified backup, dry-run, explicit apply, and rollback for its supported files; a new profile-import/merge mechanism would increase the risk of conflicts and partial writes without a validated need.

## Consequences

Templates remain examples, must be reviewed before adoption, and never represent an installed profile. MCP commands may add a registration but do not install or authorize an external service. Live profile values, credentials, third-party skill content, and local recovery state remain outside public Git.
