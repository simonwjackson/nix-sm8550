# nix-sm8550

Nix package monorepo for SM8550 handheld emulator work.

This repo starts package-only: it provides emulator derivations and package
metadata, not device launchers, host tuning helpers, or ROCKNIX field-operation
scripts. Those integrations can be reviewed and added back separately once the
package surface is settled.

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
| `cemu-rocknix-package` | Transitional compatibility alias for existing ROCKNIX Layer 14 consumers. |

## Layout

```text
packages/cemu/           Cemu derivation, manifest, patches, SM8550 settings
scripts/static-checks.sh Cheap invariants for package boundaries
```

## Package boundary

The package owns emulator-generic runtime setup:

- Nix Vulkan loader visibility in `bin/cemu`
- SDL screensaver guard in `bin/cemu`
- Cemu runtime data and SM8550 default settings under `$out/share/Cemu`
- build evidence under `$out/nix-support/rocknix-cemu-build`

This repo intentionally does **not** own:

- ROCKNIX `/storage` compatibility layout
- SM8550 host CPU/GPU tuning helpers
- guest profile promotion/deploy scripts
- BOTW/live validation orchestration

Those belong in downstream integrations unless/until we decide they should be
shared here as separately reviewed adapter packages.

## Adding future emulators

1. Add `packages/<emu>/package.nix` plus a data-only manifest when useful.
2. Expose `packages.${system}.<emu>` in `flake.nix`.
3. Keep device/session launch policy outside generic package derivations.
4. Extend `scripts/static-checks.sh` with any new package-boundary invariants.
