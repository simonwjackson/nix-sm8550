#!/usr/bin/env bash
set -euo pipefail

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f flake.nix ]] || fail "run from repo root"

grep -q 'cemu = pkgs.callPackage ./packages/cemu/rocknix-package.nix' flake.nix \
  || fail "root flake must expose packages.cemu from packages/cemu"
grep -q 'default = cemu' flake.nix \
  || fail "default package must alias cemu"
grep -q 'cemu-rocknix-package = cemu' flake.nix \
  || fail "compatibility alias must remain available for current consumers"

grep -q 'exec "\\$cemu_wrapper_dir/Cemu"' packages/cemu/rocknix-package.nix \
  || fail "package wrapper must exec real Cemu binary"
grep -q 'vulkan_loader_lib_path=' packages/cemu/rocknix-package.nix \
  || fail "package wrapper must own Vulkan loader path"
grep -q 'SDL_VIDEO_ALLOW_SCREENSAVER' packages/cemu/rocknix-package.nix \
  || fail "package wrapper must own SDL screensaver guard"

grep -q 'ROCKNIX cemu-sa package contract' packages/cemu/rocknix-package-manifest.nix \
  || fail "Cemu manifest must document ROCKNIX package contract source"

! find . -path './.git' -prune -o -path './integrations/*' -print | grep -q . \
  || fail "package-only repo must not include integration adapters yet"
! grep -R 'host-tune\|remote-cemu-promote\|start_cemu_guest\|cemu-storage-adapter' \
  --exclude-dir=.git \
  --exclude='static-checks.sh' \
  . >/tmp/nix-sm8550-integration-grep.$$ \
  || { cat /tmp/nix-sm8550-integration-grep.$$ >&2; rm -f /tmp/nix-sm8550-integration-grep.$$; fail "package-only repo must not reference ROCKNIX integration scripts"; }
rm -f /tmp/nix-sm8550-integration-grep.$$
