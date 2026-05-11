# ROCKNIX integration adapters

These scripts are copied from the Layer 14 SM8550 work so the external package
monorepo carries the launch/promotion contract next to the package it serves.

They are intentionally ROCKNIX-specific and should not be folded into generic
Nix package derivations.

Key scripts:

- `launchers/start_cemu_guest.sh` — thin compatibility launcher around promoted
  `bin/cemu`.
- `launchers/cemu-storage-adapter.sh` — `/storage` Cemu compatibility layout.
- `launchers/cemu-sm8550-performance.sh` — measured SM8550 CPU/GPU/affinity
  policy.
- `launchers/remote-cemu-promote.sh` — installs an imported package output into
  the stable guest profile.
- `launchers/host-tune.sh` — temporary host-side privileged helper for policy
  controls that the guest should not own yet.
