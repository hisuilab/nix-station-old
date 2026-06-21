"""Setup Wizard for nix-station.

Interactively creates ~/.config/nix-station/ configuration files:
  - instance.toml
  - profiles/<name>.toml
  - flake.nix  (copied from lib/templates/deploy-flake.nix)
  - generated/Brewfile  (via generate_brewfile.py)

Usage:
    nix run nixpkgs#python3 -- scripts/service/wizard.py [--config-dir DIR]
"""

from __future__ import annotations

import getpass
import os
import platform
import shutil
import socket
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent.parent
DEFAULT_CONFIG_DIR = Path.home() / ".config" / "nix-station"

sys.path.insert(0, str(REPO_ROOT / "scripts" / "validator"))
from host_template import ValidationError as TemplateValidationError  # noqa: E402
from host_template import load as load_template  # noqa: E402
from instance import InstanceValidationError  # noqa: E402
from instance import validate as validate_instance  # noqa: E402
from profile import ProfileValidationError  # noqa: E402
from profile import validate as validate_profile  # noqa: E402


# ─── OS Detection ─────────────────────────────────────────────────────────────


def detect_os() -> tuple[str, str]:
    """Return (os_type, arch). os_type: 'macos' | 'linux' | 'wsl' | 'unknown'."""
    system = platform.system()
    machine = platform.machine()
    if system == "Darwin":
        return "macos", machine
    if system == "Linux":
        try:
            proc = Path("/proc/version").read_text()
            if "microsoft" in proc.lower():
                return "wsl", machine
        except OSError:
            pass
        return "linux", machine
    return "unknown", machine


# ─── Doctor ───────────────────────────────────────────────────────────────────


def check_nix() -> str:
    result = subprocess.run(
        ["nix", "--version"], capture_output=True, text=True, timeout=10
    )
    if result.returncode != 0:
        raise EnvironmentError("Nix is not installed or not in PATH.")
    return result.stdout.strip()


def run_doctor(os_type: str, arch: str) -> None:
    print("\n[1/6] Checking prerequisites...")
    try:
        nix_ver = check_nix()
    except EnvironmentError as e:
        print(f"  ✗ {e}", file=sys.stderr)
        sys.exit(1)
    print(f"  ✓ OS: {os_type} ({arch})")
    print(f"  ✓ Nix: {nix_ver}")
    if os_type == "unknown":
        print("  ! Unsupported OS. Setup may not work correctly.")


# ─── Host Discovery ───────────────────────────────────────────────────────────

_OS_FILTER: dict[str, set[str]] = {
    "macos": {"macos"},
    "linux": {"ubuntu", "raspberry-pi-os"},
    "wsl": {"ubuntu"},
}


def discover_hosts(hosts_dir: Path, os_type: str) -> list[tuple[str, dict]]:
    """Return [(host_id, meta), ...] filtered by current OS."""
    allowed = _OS_FILTER.get(os_type)
    result = []
    for d in sorted(hosts_dir.iterdir()):
        if not d.is_dir() or not (d / "template.toml").exists():
            continue
        try:
            raw, host_id = load_template(d / "template.toml")
        except (TemplateValidationError, Exception):
            continue
        meta = raw.get("meta", {})
        if allowed is not None and meta.get("os") not in allowed:
            continue
        result.append((host_id, meta))
    return result


# ─── Input Helpers ────────────────────────────────────────────────────────────


def prompt(msg: str, default: str = "") -> str:
    suffix = f" [{default}]" if default else ""
    try:
        value = input(f"  {msg}{suffix}: ").strip()
    except (EOFError, KeyboardInterrupt):
        print("\nAborted.")
        sys.exit(0)
    return value if value else default


def confirm(msg: str) -> bool:
    try:
        return input(f"  {msg} [y/N]: ").strip().lower() == "y"
    except (EOFError, KeyboardInterrupt):
        print("\nAborted.")
        sys.exit(0)


# ─── Atomic Write ─────────────────────────────────────────────────────────────


def atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_name = tempfile.mkstemp(dir=path.parent, suffix=".tmp")
    try:
        with os.fdopen(fd, "w") as f:
            f.write(content)
        os.replace(tmp_name, path)
    except Exception:
        try:
            os.unlink(tmp_name)
        except OSError:
            pass
        raise


# ─── File Templates ───────────────────────────────────────────────────────────

_INSTANCE_TOML = """\
schema_version = "1"
hostname = {hostname!r}
host_id  = {host_id!r}
profile  = {profile!r}
"""

_PROFILE_TOML = """\
schema_version = "1"
username    = {username!r}
description = {description!r}
[git]
user_name  = {user_name!r}
user_email = {user_email!r}
"""

_APPLY_CMD: dict[str, str] = {
    "macos": "sudo darwin-rebuild switch --flake .#{hostname}",
    "linux": "home-manager switch --flake .#{hostname}",
    "wsl": "home-manager switch --flake .#{hostname}",
}


# ─── Wizard ───────────────────────────────────────────────────────────────────


def main() -> None:
    config_dir = DEFAULT_CONFIG_DIR
    if "--config-dir" in sys.argv:
        idx = sys.argv.index("--config-dir")
        try:
            config_dir = Path(sys.argv[idx + 1])
        except IndexError:
            print("Error: --config-dir requires a path argument.", file=sys.stderr)
            sys.exit(1)

    print("=" * 50)
    print(" nix-station Setup Wizard")
    print("=" * 50)

    # ── Step 1: Doctor ──────────────────────────────────────────────────────
    os_type, arch = detect_os()
    run_doctor(os_type, arch)

    # ── Step 2: Host selection ──────────────────────────────────────────────
    hosts = discover_hosts(REPO_ROOT / "hosts", os_type)
    if not hosts:
        print(
            f"\nNo Host Templates found for OS '{os_type}'. "
            "Add a template.toml to hosts/<host-id>/ first.",
            file=sys.stderr,
        )
        sys.exit(1)

    valid_host_ids = {hid for hid, _ in hosts}
    print("\n[2/6] Available Host Templates:")
    for i, (hid, meta) in enumerate(hosts, 1):
        print(
            f"  {i}. {hid}"
            f"  ({meta.get('os', '?')}, {meta.get('builder', '?')}, {meta.get('environment', '?')})"
        )

    host_id = ""
    while host_id not in valid_host_ids:
        if len(hosts) == 1:
            host_id = hosts[0][0]
            print(f"  Auto-selected: {host_id}")
        else:
            try:
                raw_choice = input(f"\n  Select host [1-{len(hosts)}]: ").strip()
            except (EOFError, KeyboardInterrupt):
                print("\nAborted.")
                sys.exit(0)
            try:
                host_id = hosts[int(raw_choice) - 1][0]
            except (ValueError, IndexError):
                print(f"  Invalid choice. Enter a number between 1 and {len(hosts)}.")
                host_id = ""

    # ── Step 3: Hostname ────────────────────────────────────────────────────
    print("\n[3/6] Device Configuration:")
    hostname = prompt("Hostname", socket.gethostname())
    if not hostname:
        print("  ✗ Hostname cannot be empty.", file=sys.stderr)
        sys.exit(1)

    # ── Step 4: Profile ─────────────────────────────────────────────────────
    print("\n[4/6] User Profile:")
    profile_name = prompt("Profile name", getpass.getuser())
    if not profile_name:
        print("  ✗ Profile name cannot be empty.", file=sys.stderr)
        sys.exit(1)

    user_name = prompt("Git name")
    if not user_name:
        print("  ✗ Git name cannot be empty.", file=sys.stderr)
        sys.exit(1)

    user_email = prompt("Git email")
    if not user_email:
        print("  ✗ Git email cannot be empty.", file=sys.stderr)
        sys.exit(1)

    description = prompt("Description (optional)")

    # Validate collected input before writing anything
    try:
        validate_instance(
            {
                "schema_version": "1",
                "hostname": hostname,
                "host_id": host_id,
                "profile": profile_name,
            },
            valid_host_ids=valid_host_ids,
        )
        validate_profile(
            {
                "schema_version": "1",
                "username": profile_name,
                "description": description or None,
                "git": {"user_name": user_name, "user_email": user_email},
            },
            profile_name,
        )
    except (InstanceValidationError, ProfileValidationError) as e:
        print(f"\n  ✗ Validation failed: {e}", file=sys.stderr)
        sys.exit(1)

    # ── Step 5: Generate files ──────────────────────────────────────────────
    print("\n[5/6] Generating files...")

    if config_dir.exists() and (config_dir / "instance.toml").exists():
        print(f"  ! Existing config found at {config_dir}")
        if not confirm("Overwrite existing configuration?"):
            print("  Aborted by user.")
            sys.exit(0)

    try:
        atomic_write(
            config_dir / "instance.toml",
            _INSTANCE_TOML.format(
                hostname=hostname, host_id=host_id, profile=profile_name
            ),
        )
        print(f"  ✓ {config_dir / 'instance.toml'}")

        atomic_write(
            config_dir / "profiles" / f"{profile_name}.toml",
            _PROFILE_TOML.format(
                username=profile_name,
                description=description or "",
                user_name=user_name,
                user_email=user_email,
            ),
        )
        print(f"  ✓ {config_dir / 'profiles' / f'{profile_name}.toml'}")

        flake_template = REPO_ROOT / "lib" / "templates" / "deploy-flake.nix"
        dest_flake = config_dir / "flake.nix"
        config_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(flake_template, dest_flake)
        print(f"  ✓ {dest_flake}")

    except OSError as e:
        print(f"\n  ✗ File error: {e}", file=sys.stderr)
        sys.exit(1)

    # Generate Brewfile via existing service script
    brewfile_result = subprocess.run(
        [
            sys.executable,
            str(REPO_ROOT / "scripts" / "service" / "generate_brewfile.py"),
            host_id,
        ],
        capture_output=True,
        text=True,
    )
    if brewfile_result.returncode == 0:
        print(f"  ✓ {config_dir / 'generated' / 'Brewfile'}")
    else:
        print(f"  ! Brewfile generation skipped: no apps.toml for '{host_id}'")

    # ── Step 6: Completion ──────────────────────────────────────────────────
    apply_cmd = _APPLY_CMD.get(os_type, "# see README for apply command").format(
        hostname=hostname
    )

    print(f"""
[6/6] Setup complete!

  Config directory: {config_dir}

  To apply:
    cd {config_dir}
    {apply_cmd}

  To update Brewfile after editing App Catalog:
    nix run nixpkgs#python3 -- scripts/service/generate_brewfile.py {host_id}
""")


if __name__ == "__main__":
    main()
