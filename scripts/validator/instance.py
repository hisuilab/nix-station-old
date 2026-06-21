"""TOML Instance validator for nix-station Application Service.

Validates an instance.toml against the Instance schema. Used by the CLI
and Wizard (not the Nix build).

Usage:
    nix run nixpkgs#python3 -- scripts/validator/instance.py <instance.toml>
"""

from __future__ import annotations

import sys
from pathlib import Path

try:
    import tomllib  # Python 3.11+
except ImportError:
    try:
        import tomli as tomllib  # type: ignore[no-redef]
    except ImportError as exc:
        raise ImportError(
            "tomllib (Python 3.11+) or tomli package required. "
            "Run via: nix run nixpkgs#python3 -- scripts/validator/instance.py"
        ) from exc

SCHEMA_VERSION = "1"


class InstanceValidationError(ValueError):
    pass


def validate(raw: dict, valid_host_ids: set[str] | None = None) -> dict:
    """Validate a parsed instance TOML dict and return a normalized dict.

    valid_host_ids: when provided, host_id is checked for membership.
    Pass the result of discover_hosts() from the Wizard for dynamic validation.
    """
    errors: list[str] = []

    version = raw.get("schema_version")
    if version != SCHEMA_VERSION:
        errors.append(f"schema_version must be '{SCHEMA_VERSION}', got {version!r}")

    hostname = raw.get("hostname", "")
    if not isinstance(hostname, str) or not hostname:
        errors.append("hostname: must be a non-empty string")

    host_id = raw.get("host_id", "")
    if not isinstance(host_id, str) or not host_id:
        errors.append("host_id: must be a non-empty string")
    elif valid_host_ids is not None and host_id not in valid_host_ids:
        errors.append(
            f"host_id: '{host_id}' is not a registered host. "
            f"Valid values: {sorted(valid_host_ids)}"
        )

    profile = raw.get("profile", "")
    if not isinstance(profile, str) or not profile:
        errors.append("profile: must be a non-empty string")

    if errors:
        lines = "\n  ".join(errors)
        raise InstanceValidationError(f"Instance validation failed:\n  {lines}")

    return {
        "schema_version": version,
        "hostname": hostname,
        "host_id": host_id,
        "profile": profile,
    }


def load(toml_path: Path) -> dict:
    """Read and parse an instance TOML file."""
    with open(toml_path, "rb") as f:
        return tomllib.load(f)


def main() -> None:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <instance.toml>", file=sys.stderr)
        sys.exit(1)

    path = Path(sys.argv[1])
    if not path.exists():
        print(f"Error: file not found: {path}", file=sys.stderr)
        sys.exit(1)

    try:
        raw = load(path)
        result = validate(raw)  # standalone: no host_id membership check
        print(
            f"OK: instance '{result['hostname']}' "
            f"(host={result['host_id']}, profile={result['profile']})"
        )
    except InstanceValidationError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
