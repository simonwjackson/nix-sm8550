# nix-sm8550

Nix package monorepo for SM8550 handheld emulator work.

The first package is the direct ROCKNIX Cemu package replica that restored
host/Nix performance parity on the AYN Thor / SM8550 Layer 14 guest. Future
custom emulator packages should live beside it under `packages/<emu>/` and use
this repository's root flake as the stable package surface.

## Packages

```sh
nix build .#cemu --print-build-logs
# equivalent compatibility surfaces:
nix build .#default
nix build .#cemu-rocknix-package
```

Current package outputs:

| Package | Purpose |
| --- | --- |
| `cemu` | Direct Cemu package replica of ROCKNIX `cemu-sa`, with package-owned `bin/cemu` wrapper. |
| `default` | Alias to `cemu`. |
| `cemu-rocknix-package` | Transitional compatibility alias for existing ROCKNIX Layer 14 scripts/docs. |

## Layout

```text
packages/cemu/                  Cemu derivation, manifest, patches, SM8550 settings
integrations/rocknix/launchers/  ROCKNIX guest adapters and promotion helpers
docs/validation/                 Field validation notes from Thor/Fuji work
scripts/static-checks.sh         Cheap invariants for package/adapter boundaries
```

## Boundary model

The package owns emulator-generic runtime setup:

- Nix Vulkan loader visibility in `bin/cemu`
- SDL screensaver guard in `bin/cemu`
- Cemu runtime data and SM8550 default settings under `$out/share/Cemu`
- build evidence under `$out/nix-support/rocknix-cemu-build`

ROCKNIX integration adapters own device/session concerns:

- stable profile promotion to `/nix/var/nix/profiles/per-user/root/cemu-promoted`
- `/storage` compatibility layout via `cemu-storage-adapter.sh`
- SM8550 CPU/GPU/affinity policy via `cemu-sm8550-performance.sh`
- BOTW/live validation orchestration outside the generic package

## Adding future emulators

1. Add `packages/<emu>/package.nix` plus a data-only manifest when useful.
2. Expose `packages.${system}.<emu>` in `flake.nix`.
3. Keep device/session launch policy outside generic package derivations.
4. Add integration helpers under `integrations/rocknix/` only when they are
   ROCKNIX-specific.
5. Extend `scripts/static-checks.sh` with any new package-boundary invariants.
