# Cemu SM8550 Layer 14 validation notes

Source context: ROCKNIX branch `feat/rocknix-layer-14-thin-host`.

## Known-good package

Promoted package during validation:

```text
/nix/store/g7k474r6a11n1ksc8wk9ggjkqnjpyjln-cemu-rocknix-package-2.999.0-rocknix-package
```

Previous known-good baseline:

```text
/nix/store/2vahrn6mc766rk5zchxk4a9601c0h648-cemu-rocknix-package-2.999.0-rocknix-package
```

## Key decisions captured in this repo

- Use a direct ROCKNIX package replica instead of `nixpkgs#cemu` override work.
- Use Nix Mesa/Freedreno as the product path; ROCKNIX Mesa passthrough remains
  diagnostic-only.
- Launch through package-owned `bin/cemu`; do not put Vulkan loader setup in the
  ROCKNIX launcher adapter.
- Keep BOTW validation logic out of the generic package.
- Keep SM8550 performance policy in integration adapters, not the package.
- Use CPU affinity `0xF8` for validated host/Nix parity.

## Validation runs

| Run | Result |
| --- | --- |
| `/storage/.guest/runs/20260510-224818-u3-mangohud-currentfile-unrestricted` | Package-owned Cemu entrypoint with MangoHud active; avg 42.83 / median 44.10 / p10 32.44 FPS at sample point. |
| `/storage/.guest/runs/20260510-225813-u5-storage-adapter-mangohud-unrestricted` | Storage adapter validated; avg 48.50 / median 45.01 / p10 44.55 FPS at sample point. |
| `/storage/.guest/runs/20260510-230455-u6-sm8550-performance-helper-mangohud` | SM8550 helper validated; avg 43.92 / median 44.96 / p10 34.67 FPS post-pin. |
| `/storage/.guest/runs/20260510-231352-u8-thin-adapter-mangohud` | Thin adapter validated; launched `cemu-promoted/bin/cemu`; avg 47.26 / median 45.00 / p10 44.47 FPS early in-game. |

## Operational constraints

- Build heavy aarch64 closures on Fuji or another builder, not Thor.
- Do not mutate `/usr`, `/flash`, `/boot`, or host `/etc` for product launch.
- Do not broad-bind `/storage/.cache`.
- Avoid host/Nix Vulkan loader mixing via launcher `LD_PRELOAD` hacks.
- Prefer live MangoHud/user-visible FPS over headless/title-only results.
- Use exact process cleanup; avoid broad command-line kills.
