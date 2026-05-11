#!/usr/bin/env bash
set -euo pipefail

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f flake.nix ]] || fail "run from repo root"

grep -q 'cemu = pkgs.callPackage ./packages/cemu/rocknix-package.nix' flake.nix \
  || fail "root flake must expose packages.cemu from packages/cemu"
grep -q 'default = cemu' flake.nix \
  || fail "default package must alias cemu"
grep -q 'cemu-rocknix-package = cemu' flake.nix \
  || fail "compatibility alias must remain available for current ROCKNIX scripts"

grep -q 'exec "\$cemu_wrapper_dir/Cemu"' packages/cemu/rocknix-package.nix \
  || fail "package wrapper must exec real Cemu binary"
grep -q 'vulkan_loader_lib_path=' packages/cemu/rocknix-package.nix \
  || fail "package wrapper must own Vulkan loader path"
grep -q 'SDL_VIDEO_ALLOW_SCREENSAVER' packages/cemu/rocknix-package.nix \
  || fail "package wrapper must own SDL screensaver guard"

! grep -q 'CEMU_VULKAN_LOADER_LIB_PATH\|LD_LIBRARY_PATH' integrations/rocknix/launchers/start_cemu_guest.sh \
  || fail "ROCKNIX launcher must not own Vulkan loader setup"
grep -q 'cemu-storage-adapter.sh' integrations/rocknix/launchers/start_cemu_guest.sh \
  || fail "ROCKNIX launcher must delegate storage layout"
grep -q 'profile/bin/cemu' integrations/rocknix/launchers/remote-cemu-promote.sh \
  || fail "promotion helper must promote package-owned bin/cemu"

for script in integrations/rocknix/launchers/*.sh; do
  bash -n "$script" || fail "syntax error in $script"
done
