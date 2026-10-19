---
type: Decision
title: CUDA is opted into per package
description: The nvidiaCuda mixin is a capability flag consumers read, not a nixpkgs.config.cudaSupport switch, because a global flag orphans every downstream consumer of a CUDA-aware library from cache.nixos.org.
tags: [decision, nvidia, cuda, nixpkgs, caching]
generated:
  by: claude-code/claude-opus-5
  at: 2026-10-19T00:00:00Z
---

# The rule

`mixins.hardware.nvidiaCuda` sets no `nixpkgs.config.cudaSupport`. It allows the cuDNN EULA,
adds `cache.nixos-cuda.org`, and otherwise exists to be read — a consumer opts in on its own
option:

```nix
services.ollama.acceleration = lib.mkIf osConfig.mixins.hardware.nvidiaCuda.enable "cuda";
```

The gate is the mixin flag, not the presence of the driver: `mother` has an Nvidia GPU and must
not get CUDA packages, and the home mixin is shared with a host that has no GPU at all. An
explicit `acceleration` bypasses `config.cudaSupport` inside the package, so the result is the
same derivation the global flag produced.

# Why

`config.cudaSupport` is read by ~120 nixpkgs packages, and each one it flips changes hash along
with everything downstream. Hydra builds the flag off, so a global `true` buys local compilation
of that whole subtree; `cache.nixos-cuda.org` substitutes the CUDA libraries themselves, not
their consumers.

Librewolf is such a consumer, transitively: `buildMozillaMach` takes `onnxruntime` and passes
`--with-onnx-runtime` for Firefox ≥ 141. Under a global flag the browser is a local source build
on every update, with the CUDA `onnxruntime` as the sole differing input.

A global flag is also hard to attribute — nothing in the enabling mixin names what it affects.
On HAL9000 it reached only `ollama` and the `onnxruntime` → librewolf → firefoxpwa chain; the
NixOS closure evaluated hash-identical without it.

# Related

* [decisions/enable-flag-mixins](/decisions/enable-flag-mixins.md) — why the mixin carries only `enable` for a consumer to read.
* [hosts/HAL9000](/hosts/HAL9000.md) — the only host taking `nvidiaCuda`.
* [hosts/nyx-cluster](/hosts/nyx-cluster.md) — `mother`, the driver-without-CUDA case.
