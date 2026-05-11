#!/usr/bin/env bash
set -euo pipefail

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f flake.nix ]] || fail "run from repo root"

grep -q 'cemu = pkgs.callPackage ./packages/cemu/package.nix' flake.nix \
  || fail "root flake must expose packages.cemu from packages/cemu"
grep -q 'default = cemu' flake.nix \
  || fail "default package must alias cemu"
grep -q 'cemu-rocknix-package = cemu' flake.nix \
  || fail "compatibility alias must remain available for current consumers"
grep -q 'steam = pkgs.callPackage ./packages/steam/package.nix' flake.nix \
  || fail "root flake must expose packages.steam from packages/steam"
grep -q 'steam = steam' flake.nix \
  || fail "packages.steam must be exposed"

grep -q 'exec "\\$cemu_wrapper_dir/Cemu"' packages/cemu/package.nix \
  || fail "package wrapper must exec real Cemu binary"
grep -q 'vulkan_loader_lib_path=' packages/cemu/package.nix \
  || fail "package wrapper must own Vulkan loader path"
grep -q 'SDL_VIDEO_ALLOW_SCREENSAVER' packages/cemu/package.nix \
  || fail "package wrapper must own SDL screensaver guard"

grep -q 'ROCKNIX cemu-sa package contract' packages/cemu/manifest.nix \
  || fail "Cemu manifest must document ROCKNIX package contract source"

grep -q 'ROCKNIX Steam ARM64 guest-native package contract' packages/steam/manifest.nix \
  || fail "Steam manifest must document ROCKNIX package contract source"
grep -q 'rev = "[0-9a-f]\{40\}"' packages/steam/manifest.nix \
  || fail "Steam manifest must record pinned ROCKNIX source revision"
grep -q 'guest-native-steam-target=true' packages/steam/package.nix \
  || fail "Steam package evidence must target guest-native Steam"
grep -q 'host-steam-fallback=false' packages/steam/package.nix \
  || fail "Steam package must not fall back to host Steam"
grep -q 'immutable-nix-store-valve-arm64-seed-artifacts=false' packages/steam/package.nix \
  || fail "Steam v1 package must not claim immutable Nix-store Valve ARM64 seed artifacts"
grep -q 'steam-arm64-bootstrap' packages/steam/package.nix \
  || fail "Steam package must install bootstrap helper"
grep -q 'steam-arm64-seed' packages/steam/package.nix \
  || fail "Steam package must install ARM64 seed helper"
grep -q 'steam-guest-native' packages/steam/package.nix \
  || fail "Steam package must install guest-native launcher helper"
grep -q 'STEAM_HOME' packages/steam/scripts/steam-arm64-bootstrap \
  || fail "Steam bootstrap helper must require explicit STEAM_HOME"
grep -q 'STEAM_GAMES_ROOT' packages/steam/scripts/steam-arm64-bootstrap \
  || fail "Steam bootstrap helper must require explicit STEAM_GAMES_ROOT"
grep -q 'STEAM_DOT' packages/steam/scripts/steam-arm64-bootstrap \
  || fail "Steam bootstrap helper must require explicit STEAM_DOT"
grep -q -- '--dry-run' packages/steam/scripts/steam-arm64-bootstrap \
  || fail "Steam bootstrap helper must support dry-run mode"
grep -q 'steam` | ROCKNIX-informed guest-native Steam ARM64 package helpers' README.md \
  || fail "root README must document Steam package as guest-native helpers"
grep -q 'STEAM_MANIFEST_URL' packages/steam/scripts/steam-arm64-seed \
  || fail "Steam seed helper must know the ARM64 client manifest endpoint"
grep -q 'steamrtarm64/steam' packages/steam/scripts/steam-guest-native \
  || fail "Steam guest-native helper must execute the ARM64 Steam client"
grep -q 'NIX_LD' packages/steam/scripts/steam-guest-native \
  || fail "Steam guest-native helper must preflight NixOS dynamic linker strategy"

for resource in compatibilitytool.vdf registry.vdf toolmanifest.vdf; do
  [[ -f "packages/steam/resources/${resource}" ]] \
    || fail "Steam resource missing: ${resource}"
done

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck packages/steam/scripts/steam-arm64-bootstrap \
    packages/steam/scripts/steam-arm64-seed \
    packages/steam/scripts/steam-guest-native
fi

! grep -R 'systemctl\|swaymsg\|FEXRootFSFetcher\|gamescope\|/storage' \
  packages/steam/package.nix packages/steam/scripts >/tmp/nix-sm8550-steam-boundary-grep.$$ \
  || { cat /tmp/nix-sm8550-steam-boundary-grep.$$ >&2; rm -f /tmp/nix-sm8550-steam-boundary-grep.$$; fail "Steam package executable logic must not own ROCKNIX host/session/storage policy"; }
rm -f /tmp/nix-sm8550-steam-boundary-grep.$$

! find . -path './.git' -prune -o -path './integrations/*' -print | grep -q . \
  || fail "package-only repo must not include integration adapters yet"
! grep -R 'host-tune\|remote-cemu-promote\|start_cemu_guest\|cemu-storage-adapter' \
  --exclude-dir=.git \
  --exclude='static-checks.sh' \
  . >/tmp/nix-sm8550-integration-grep.$$ \
  || { cat /tmp/nix-sm8550-integration-grep.$$ >&2; rm -f /tmp/nix-sm8550-integration-grep.$$; fail "package-only repo must not reference ROCKNIX integration scripts"; }
rm -f /tmp/nix-sm8550-integration-grep.$$
