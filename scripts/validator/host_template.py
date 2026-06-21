"""TOML Host Template validator for nix-station Application Service.

Validates a template.toml against the Host Template schema and returns a
normalized Python dict. Used by the CLI and Wizard (not the Nix build).

Usage:
    nix run nixpkgs#python3 -- scripts/validator/host_template.py <template.toml>
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
            "Run via: nix run nixpkgs#python3 -- scripts/validator/host_template.py"
        ) from exc

SCHEMA_VERSION = "1"

VALID_BUILDERS = {"nix-darwin", "home-manager"}
VALID_OS = {"macos", "ubuntu", "raspberry-pi-os"}
VALID_ENVIRONMENTS = {"native", "wsl"}
VALID_SYSTEMS = {
    "aarch64-darwin",
    "x86_64-darwin",
    "aarch64-linux",
    "x86_64-linux",
}

# Tools that accept { enable, config_file } attrsets (mirrors host-registry.nix)
MANAGED_TOOLS = {"ghostty", "p10k", "starship", "tmux", "zed"}

# Tools that accept boolean values
BOOL_TOOLS = {"cli_tools", "gh", "git", "zsh"}


class ValidationError(Exception):
    pass


def validate_meta(meta: dict, host_id: str) -> None:
    for field in ("system", "builder", "os", "environment"):
        if field not in meta:
            raise ValidationError(f"host '{host_id}': meta.{field} is required")
    if meta["builder"] not in VALID_BUILDERS:
        raise ValidationError(
            f"host '{host_id}': unsupported meta.builder '{meta['builder']}'"
        )
    if meta["os"] not in VALID_OS:
        raise ValidationError(f"host '{host_id}': unsupported meta.os '{meta['os']}'")
    if meta["environment"] not in VALID_ENVIRONMENTS:
        raise ValidationError(
            f"host '{host_id}': unsupported meta.environment '{meta['environment']}'"
        )
    if meta["system"] not in VALID_SYSTEMS:
        raise ValidationError(
            f"host '{host_id}': unsupported meta.system '{meta['system']}'"
        )


def validate_home_manager(hm: dict, host_id: str) -> None:
    for key, value in hm.items():
        if key in BOOL_TOOLS:
            if not isinstance(value, bool):
                raise ValidationError(
                    f"host '{host_id}': home_manager.{key} must be a boolean"
                )
        elif key in MANAGED_TOOLS:
            if not isinstance(value, dict):
                raise ValidationError(
                    f"host '{host_id}': home_manager.{key} must be a table"
                )
            if "enable" in value and not isinstance(value["enable"], bool):
                raise ValidationError(
                    f"host '{host_id}': home_manager.{key}.enable must be a boolean"
                )
            if "config_file" in value and not isinstance(value["config_file"], str):
                raise ValidationError(
                    f"host '{host_id}': home_manager.{key}.config_file must be a string"
                )
        else:
            raise ValidationError(
                f"host '{host_id}': unknown home_manager tool '{key}'"
            )


def validate_darwin(darwin: dict, host_id: str) -> None:
    for section in ("features", "dock", "power", "homebrew"):
        if section in darwin and not isinstance(darwin[section], dict):
            raise ValidationError(f"host '{host_id}': darwin.{section} must be a table")

    for feature, value in (darwin.get("features") or {}).items():
        if not isinstance(value, bool):
            raise ValidationError(
                f"host '{host_id}': darwin.features.{feature} must be a boolean"
            )

    dock = darwin.get("dock") or {}
    if "autohide" in dock and not isinstance(dock["autohide"], bool):
        raise ValidationError(
            f"host '{host_id}': darwin.dock.autohide must be a boolean"
        )
    if "orientation" in dock and dock["orientation"] not in {"left", "right", "bottom"}:
        raise ValidationError(
            f"host '{host_id}': darwin.dock.orientation must be left/right/bottom"
        )


def validate(raw: dict, host_id: str) -> dict:
    """Validate raw TOML dict and return normalized dict on success."""
    if raw.get("schema_version") != SCHEMA_VERSION:
        raise ValidationError(
            f"host '{host_id}': schema_version must be '{SCHEMA_VERSION}'"
        )

    if "meta" not in raw:
        raise ValidationError(f"host '{host_id}': [meta] section is required")
    validate_meta(raw["meta"], host_id)

    validate_home_manager(raw.get("home_manager") or {}, host_id)

    if raw["meta"]["builder"] == "nix-darwin" and "darwin" in raw:
        validate_darwin(raw["darwin"], host_id)

    return raw


def load(toml_path: Path) -> tuple[dict, str]:
    """Load and validate a template.toml. Returns (raw_dict, host_id)."""
    host_id = toml_path.parent.name
    with toml_path.open("rb") as f:
        raw = tomllib.load(f)
    return validate(raw, host_id), host_id


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <template.toml>", file=sys.stderr)
        sys.exit(1)

    path = Path(sys.argv[1])
    try:
        data, host_id = load(path)
        print(f"✓ {host_id}: valid (schema_version={data['schema_version']})")
    except ValidationError as e:
        print(f"✗ {e}", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print(f"✗ file not found: {path}", file=sys.stderr)
        sys.exit(1)
