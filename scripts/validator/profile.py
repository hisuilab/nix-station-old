"""TOML User Profile validator for nix-station Application Service.

Validates a <name>.toml against the User Profile schema and returns a
normalized Python dict. Used by the CLI and Wizard (not the Nix build).

Usage:
    nix run nixpkgs#python3 -- scripts/validator/profile.py <profile.toml>
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
            "Run via: nix run nixpkgs#python3 -- scripts/validator/profile.py"
        ) from exc

SCHEMA_VERSION = "1"


class ProfileValidationError(ValueError):
    pass


def validate(raw: dict, profile_name: str) -> dict:
    """Validate a parsed profile TOML dict and return a normalized dict.

    Normalized output uses camelCase for Nix compatibility:
      git.user_name  -> git.userName
      git.user_email -> git.userEmail
    """
    errors: list[str] = []

    version = raw.get("schema_version")
    if version != SCHEMA_VERSION:
        errors.append(f"schema_version must be '{SCHEMA_VERSION}', got {version!r}")

    username = raw.get("username", "")
    if not isinstance(username, str) or not username:
        errors.append("username: must be a non-empty string")

    git = raw.get("git", {})
    if not isinstance(git, dict):
        errors.append("git: must be a table")
        git = {}

    user_name = git.get("user_name", "")
    if not isinstance(user_name, str) or not user_name:
        errors.append("git.user_name: must be a non-empty string")

    user_email = git.get("user_email", "")
    if not isinstance(user_email, str) or not user_email:
        errors.append("git.user_email: must be a non-empty string")

    description = raw.get("description")
    if description is not None and not isinstance(description, str):
        errors.append("description: must be a string when provided")

    if errors:
        lines = "\n  ".join(errors)
        raise ProfileValidationError(
            f"Profile '{profile_name}' validation failed:\n  {lines}"
        )

    return {
        "schema_version": version,
        "username": username,
        "description": description,
        "git": {
            "userName": user_name,
            "userEmail": user_email,
        },
    }


def load(toml_path: Path) -> tuple[dict, str]:
    """Read and parse a profile TOML file. Returns (raw_dict, profile_name)."""
    profile_name = toml_path.stem
    with open(toml_path, "rb") as f:
        raw = tomllib.load(f)
    return raw, profile_name


def main() -> None:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <profile.toml>", file=sys.stderr)
        sys.exit(1)

    path = Path(sys.argv[1])
    if not path.exists():
        print(f"Error: file not found: {path}", file=sys.stderr)
        sys.exit(1)

    try:
        raw, profile_name = load(path)
        result = validate(raw, profile_name)
        print(f"OK: profile '{result['username']}' ({result['git']['userEmail']})")
    except ProfileValidationError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
