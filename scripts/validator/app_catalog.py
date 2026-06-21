"""TOML App Catalog validator for nix-station Application Service.

Validates an apps.toml against the App Catalog schema. Used by the CLI
and Wizard (not the Nix build).

Usage:
    nix run nixpkgs#python3 -- scripts/validator/app_catalog.py <apps.toml>
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
            "Run via: nix run nixpkgs#python3 -- scripts/validator/app_catalog.py"
        ) from exc

SCHEMA_VERSION = "1"

VALID_INSTALL_TYPES = {"homebrew-cask", "mas", "system", "manual"}

# install types that require the package field
PACKAGE_REQUIRED = {"homebrew-cask", "mas"}

# install types that require mas_id
MAS_ID_REQUIRED = {"mas"}

# install types that require macos_path
MACOS_PATH_REQUIRED = {"system"}

# install types that require manual_steps
MANUAL_STEPS_REQUIRED = {"manual"}


class AppCatalogValidationError(ValueError):
    pass


def validate_entry(app_id: str, entry: dict) -> dict:
    """Validate a single app entry and return a normalized dict."""
    errors: list[str] = []

    install = entry.get("install", "")
    if install not in VALID_INSTALL_TYPES:
        errors.append(
            f"install: '{install}' is not valid. "
            f"Must be one of {sorted(VALID_INSTALL_TYPES)}"
        )
        if errors:
            raise AppCatalogValidationError(
                f"App '{app_id}':\n  " + "\n  ".join(errors)
            )

    package = entry.get("package", "")
    if install in PACKAGE_REQUIRED and (not isinstance(package, str) or not package):
        errors.append("package: must be a non-empty string")

    mas_id = entry.get("mas_id")
    if install in MAS_ID_REQUIRED:
        if mas_id is None:
            errors.append("mas_id: required for install = 'mas'")
        elif not isinstance(mas_id, int) or mas_id <= 0:
            errors.append("mas_id: must be a positive integer")

    macos_path = entry.get("macos_path")
    if install in MACOS_PATH_REQUIRED and (
        not isinstance(macos_path, str) or not macos_path
    ):
        errors.append("macos_path: required for install = 'system'")
    if macos_path is not None and not isinstance(macos_path, str):
        errors.append("macos_path: must be a string when provided")

    manual_steps = entry.get("manual_steps")
    if install in MANUAL_STEPS_REQUIRED:
        if manual_steps is None:
            errors.append("manual_steps: required for install = 'manual'")
        elif not isinstance(manual_steps, list) or not manual_steps:
            errors.append("manual_steps: must be a non-empty list of strings")
        elif not all(isinstance(s, str) for s in manual_steps):
            errors.append("manual_steps: all items must be strings")
    if manual_steps is not None and install not in MANUAL_STEPS_REQUIRED:
        errors.append("manual_steps: only valid for install = 'manual'")

    if errors:
        raise AppCatalogValidationError(f"App '{app_id}':\n  " + "\n  ".join(errors))

    return {
        "install": install,
        "package": package if package else None,
        "mas_id": mas_id,
        "macos_path": macos_path,
        "manual_steps": manual_steps,
    }


def validate(raw: dict, catalog_path: str = "") -> dict:
    """Validate a parsed App Catalog TOML dict and return a normalized dict."""
    errors: list[str] = []

    version = raw.get("schema_version")
    if version != SCHEMA_VERSION:
        errors.append(f"schema_version must be '{SCHEMA_VERSION}', got {version!r}")

    apps_raw = raw.get("apps", {})
    if not isinstance(apps_raw, dict):
        errors.append("apps: must be a table")
        raise AppCatalogValidationError(
            f"Catalog '{catalog_path}' validation failed:\n  " + "\n  ".join(errors)
        )

    if errors:
        raise AppCatalogValidationError(
            f"Catalog '{catalog_path}' validation failed:\n  " + "\n  ".join(errors)
        )

    apps: dict[str, dict] = {}
    entry_errors: list[str] = []
    for app_id, entry in apps_raw.items():
        try:
            apps[app_id] = validate_entry(app_id, entry)
        except AppCatalogValidationError as e:
            entry_errors.append(str(e))

    if entry_errors:
        raise AppCatalogValidationError(
            f"Catalog '{catalog_path}' validation failed:\n" + "\n".join(entry_errors)
        )

    return {"schema_version": version, "apps": apps}


def load(toml_path: Path) -> dict:
    """Read and parse an App Catalog TOML file."""
    with open(toml_path, "rb") as f:
        return tomllib.load(f)


def main() -> None:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <apps.toml>", file=sys.stderr)
        sys.exit(1)

    path = Path(sys.argv[1])
    if not path.exists():
        print(f"Error: file not found: {path}", file=sys.stderr)
        sys.exit(1)

    try:
        raw = load(path)
        result = validate(raw, str(path))
        app_count = len(result["apps"])
        types = {}
        for entry in result["apps"].values():
            t = entry["install"]
            types[t] = types.get(t, 0) + 1
        summary = ", ".join(f"{t}×{n}" for t, n in sorted(types.items()))
        print(f"OK: {app_count} apps ({summary})")
    except AppCatalogValidationError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
