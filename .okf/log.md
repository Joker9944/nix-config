# Update Log

An index of bundle changes, not a narrative — one line per change, in the form `CLAUDE.md` rule 3 sets.

## 2026-11-06

- Public SSH closed on the edge; the `openssh` mixin's `openFirewall` default was publishing 22 there — [hosts/wopr](/hosts/wopr.md)
- Prometheus scrapes node-exporter over the ingress tunnel, `mkAllowFrom` scoping 9100 to the spokes; why the wildcard bind stays — [hosts/wopr](/hosts/wopr.md)

## 2026-11-05

- The `nix` MCP server and the `mcp` mixin are gone; a global `nix-packages` skill answers from the pin — [decisions/nix-lookup-not-mcp](/decisions/nix-lookup-not-mcp.md)
- Canonical minimal mixin is now `wiremix.nix`; the cited `mcp.nix` is deleted — [architecture/mixin-pattern](/architecture/mixin-pattern.md)
- The lock's `nixpkgs` node is a dependency's; `.version` is not an existence check — [decisions/nix-lookup-not-mcp](/decisions/nix-lookup-not-mcp.md)

## 2026-11-04

- `mother` schedules SMART self-tests and pushes smartd warnings to Gotify; the mixin is also what puts `smartctl` on `PATH` — [workflows/diagnose-disk-faults](/workflows/diagnose-disk-faults.md), [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- Pool members map by WWN, not partuuid; the `sdg`/`sdh` ↔ `ata7`/`ata8` example was stale — [workflows/diagnose-disk-faults](/workflows/diagnose-disk-faults.md)
- A program belongs to the profile, not the user module, which lands on headless hosts too — [architecture/entry-points](/architecture/entry-points.md)
- `wopr` takes a chosen v6 address out of its routed `/64` and serves `:443` on both families — [hosts/wopr](/hosts/wopr.md)

## 2026-11-03

- Public ingress moved off the tailnet onto a dedicated WireGuard tunnel; failover is the nginx upstream, not router election — [decisions/edge-not-a-cluster-node](/decisions/edge-not-a-cluster-node.md)
- `wopr` is the tunnel hub and now a plain tailnet leaf; `allowedUDPPorts` joins its firewall exception — [hosts/wopr](/hosts/wopr.md)
- Servers are spokes behind the `k3s` mixin's `isServer` gate; `wg0` is deliberately not a trusted interface — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- Probing a node from the tunnel hub drops `6443`/`10250`/`9100`, unlike the tailnet path — [decisions/firewall-source-scoping](/decisions/firewall-source-scoping.md)
- A NodePort is DNATed ahead of `nixos-fw`, so its allow rule is a no-op and `trustedIPs` is the control — [decisions/firewall-source-scoping](/decisions/firewall-source-scoping.md)
- MetalLB removed: the `7946` rules, the `192.168.1.128/25` advertisement and `mother`'s subnet-router role are gone — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- Internal services are tailnet services from the Tailscale operator, so the `hosts` mixin is deleted — [hosts/nyx-cluster](/hosts/nyx-cluster.md), [hosts/wintermute](/hosts/wintermute.md)
- The operator is rejected for public ingress on certificates alone, and deepens the headscale coupling it was partly meant to avoid — [decisions/edge-not-a-cluster-node](/decisions/edge-not-a-cluster-node.md)
- wopr's backend is Traefik's sole `websecure` entrypoint; no second header-less entrypoint is needed — [hosts/wopr](/hosts/wopr.md)
- Renumbering no longer touches any host outside the cluster — [workflows/renumber-nodes](/workflows/renumber-nodes.md)
- Spokes carry `vonarx.online/ingress-spoke=true` for the Traefik DaemonSet — [hosts/nyx-cluster](/hosts/nyx-cluster.md), [workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md)
- Tunnel keys split across two sops rules so neither side can decrypt the other's — [workflows/secrets](/workflows/secrets.md)
- `wopr` addressing is static v4+v6 with RAs off on `ens3`; the provider serves no DHCP — [hosts/wopr](/hosts/wopr.md)
- `wopr` runs the qemu guest agent as a host delta; it is the only VM — [hosts/wopr](/hosts/wopr.md)
- A switch replays no udev events, so a udev-only service stays dead until reboot — [workflows/rebuild](/workflows/rebuild.md)
- A VM's harvested hardware config imports `qemu-guest.nix`, not `not-detected.nix` — [workflows/install-nixos](/workflows/install-nixos.md)

## 2026-11-02

- `wopr` added: an L4 `:443` splice to the cluster Traefik over the tailnet, PROXY protocol onto a dedicated `:8443` entrypoint — [hosts/wopr](/hosts/wopr.md)
- Why the ingress edge is not a k3s node, a hand-rolled tunnel, a DNAT, or the Tailscale operator — [decisions/edge-not-a-cluster-node](/decisions/edge-not-a-cluster-node.md)
- `allowedTCPPorts` has one legitimate use: a host whose peer set is every source — [decisions/firewall-source-scoping](/decisions/firewall-source-scoping.md)

- `amdCpu`/`intelCpu` own vendor microcode and kvm; `thermalThrottling` derives thermald from them — [architecture/mixin-pattern](/architecture/mixin-pattern.md)
- Generated hardware configs trimmed to what is actually scanned — [workflows/install-nixos](/workflows/install-nixos.md)
- Nodes, VIP and MetalLB pool moved into 192.168.1.0/24; `mother` pins `eno1`, case/kipp glob — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- Renumbering a node: widen the allow-set, then roll, updating each etcd peer URL ahead of its node — [workflows/renumber-nodes](/workflows/renumber-nodes.md)
- `dm_crypt` joins the Longhorn node prerequisites in the `k3s` mixin — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- The four-machine rollout is complete, so its playbook is deprecated — [workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md)

## 2026-10-26

- `mkAppWorkspace` launches from `workspace.created`; `on_created_empty` is deprecated upstream — [architecture/hyprland-lua-config](/architecture/hyprland-lua-config.md)
- Lid close is `suspend-then-hibernate`; the `HibernateLocation` EFI var replaces `boot.resumeDevice` — [hosts/wintermute](/hosts/wintermute.md)
- `eDP-1` is declared so the lid binds derive their restore spec from it — [hosts/wintermute](/hosts/wintermute.md)
- TLP replaces power-profiles-daemon; its ThinkPad charge thresholds are a host delta — [hosts/wintermute](/hosts/wintermute.md)
- `ollama` moved from the shared user config to HAL9000's host file — [hosts/wintermute](/hosts/wintermute.md)
- `mixins.hardware.intelCpu` takes microcode and thermald; a capability names one hardware axis — [architecture/mixin-pattern](/architecture/mixin-pattern.md)

## 2026-10-19

- `mixins.hardware.battery` added; upower moves behind it and the yas mixin reads it — [workflows/add-mixin](/workflows/add-mixin.md)
- The hyprland mixin names its system services instead of `gnome.core-os-services` — [decisions/gnome-keyring-not-core-os-services](/decisions/gnome-keyring-not-core-os-services.md)
- `nvidiaCuda` carries no `nixpkgs.config.cudaSupport`; consumers opt in per package — [decisions/cuda-opt-in](/decisions/cuda-opt-in.md)

## 2026-10-12

- nx workspace tooling removed; excludes list trimmed to `.envrc` — [workflows/formatting-and-cspell](/workflows/formatting-and-cspell.md)

## 2026-10-04

- The `hosts` mixin holds only labels missing from public DNS; the tailnet uses the MetalLB pool — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- Autostart entries are declared; a self-registered one records the binary behind the Nix wrapper — [decisions/declared-autostart](/decisions/declared-autostart.md)
- `xdg.desktopEntries` overrides via a `hiPrio` profile collision, not `$XDG_DATA_HOME` — [decisions/declared-autostart](/decisions/declared-autostart.md)
- Single-instance handoff needs one identity per launch context; opencloud keys on `XDG_SESSION_ID` — [decisions/declared-autostart](/decisions/declared-autostart.md)
- A user service is preferred over an XDG autostart entry; new public `services.opencloud-desktop` — [decisions/declared-autostart](/decisions/declared-autostart.md)
- Autostart units and bind scopes carry `XDG_SESSION_ID`; the manager env and user services do not — [architecture/uwsm-session](/architecture/uwsm-session.md)
- uwsm's autostart drop-in supplies the graphical slice as well as the session environment — [architecture/uwsm-session](/architecture/uwsm-session.md)

## 2026-09-27

- Hyprland helpers sit at a `lib` level on the option path; two conditions send one to a lib instead — [architecture/custom-lib](/architecture/custom-lib.md)

## 2026-09-25

- Backporting a single home-manager module across a release gap, via an in-mixin `builtins.fetchGit` — [workflows/release-upgrade](/workflows/release-upgrade.md)

## 2026-09-24

- `checks.evalConfigurations` forces every host and home `drvPath`, gating both trees' evaluation — [workflows/rebuild](/workflows/rebuild.md)
- Modifier semantics across shortcut standards: CUA, GNOME/KDE/macOS HIG, i3, terminals — [reference/shortcut-standards](/reference/shortcut-standards.md)
- Modifier layers, Super-tier semantics, and the composition rules for keybindings — [architecture/shortcut-scheme](/architecture/shortcut-scheme.md)

## 2026-09-20

- `layer_rule` cannot override a layer surface's input region; `hyprctl keyword` refuses under lua — [architecture/hyprland-lua-config](/architecture/hyprland-lua-config.md)
- App summon composes through `cfg.mkAppWorkspace`; `layout_opts` keys are consumer-validated — [architecture/hyprland-lua-config](/architecture/hyprland-lua-config.md)
- Bind form — mods interpolation, descriptions, flags, launch wrapping — lives here — [architecture/hyprland-lua-config](/architecture/hyprland-lua-config.md)
- `on_created_empty` is a third spawn path needing uwsm wrapping, beside binds and rofi — [architecture/uwsm-session](/architecture/uwsm-session.md)
- Four Super tiers: main, `SHIFT` variant, `ALT` alternative (resize), `CTRL` app; utility dropped — [architecture/shortcut-scheme](/architecture/shortcut-scheme.md)
- "Earn the chord" leads the composition rules; the launcher absorbs rare actions — [architecture/shortcut-scheme](/architecture/shortcut-scheme.md)
- `H`/`J`/`K`/`L` are reserved for direction in every namespace they appear in — [architecture/shortcut-scheme](/architecture/shortcut-scheme.md)
- Bare Alt is conditionally the app's — menu navigation (GUIs) or Meta (terminals) — [architecture/shortcut-scheme](/architecture/shortcut-scheme.md)
- Rule 4 scoped to the action tiers; the app tier keys letters to app initials — [architecture/shortcut-scheme](/architecture/shortcut-scheme.md)
- Rules hold per layer; the GUI, terminal and TUI layers get authoring guidance — [architecture/shortcut-scheme](/architecture/shortcut-scheme.md)
- Prefer the WM's window management over apps' built-in tabs, splits and layouts — [architecture/shortcut-scheme](/architecture/shortcut-scheme.md)
- Alt-as-Meta: the `ESC`-prefix encoding makes Alt the TUI world's one free modifier — [reference/shortcut-standards](/reference/shortcut-standards.md)

## 2026-09-16

- Cluster ports are scoped to their peers via `extraCommands`, not opened to every source — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- Why source scoping stays on the iptables backend, and why the pod CIDR is in the allow-set — [decisions/firewall-source-scoping](/decisions/firewall-source-scoping.md)
- tailscaled's `ts-input` preempts `nixos-fw`; bind addresses are the only control on the tailnet — [decisions/firewall-source-scoping](/decisions/firewall-source-scoping.md)
- `flake.lib.network` holds `mkAllowFrom` and the `nyxNodes` address map — [architecture/custom-lib](/architecture/custom-lib.md)
- `mother` owns its NFS firewall rule and export ACL; the `nfs` mixin opens no port — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- Corrected the per-host NIC names behind the unset `vip_interface` — [hosts/nyx-cluster](/hosts/nyx-cluster.md)

## 2026-09-11

- `modules/home/mixins/programs/mcp.nix` is the canonical minimal mixin — [architecture/mixin-pattern](/architecture/mixin-pattern.md)

## 2026-09-10

- Qt apps on the gtk3 platform theme need GSettings schemas `wrapQtAppsHook` does not supply — [reference/gtk-theming](/reference/gtk-theming.md)

## 2026-09-09

- Host metrics ports need explicit firewall holes; kube-proxy needs `metrics-bind-address=0.0.0.0` — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- ZED alerts Gotify natively; the app token is a `zed.rc` substitution, as zed keeps only `TZ` — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- Longhorn needs `openiscsi`/`mount.nfs` in the `k3s` mixin and host tools at `/usr/bin` — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- `mother` serves NFSv4 only; port 111 is closed, so `showmount` misreports a healthy server — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- All four nyx nodes installed; TrueNAS retired — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- `mother`'s label and taint are contracts k8s-config keys on; changing either fails silently — [workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md)
- `mother`'s GPU reaches pods through CDI; the toolkit on the unit `PATH` yields `nvidia-cdi` — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- `services.k3s.containerdConfigTemplate` downgrades containerd off config v3 — [hosts/nyx-cluster](/hosts/nyx-cluster.md)

## 2026-09-08

- `chronos` has no encrypted datasets and mounts at `/chronos/*`, not TrueNAS's `/mnt` altroot — [workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md)
- Only the `vonarx.online/*` labels are left to resolve on the machines — [workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md), [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- mother boots legacy BIOS under TrueNAS; systemd-boot and the disko ESP need UEFI selected first — [workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md)
- Node labels reduced to `mother`'s `nfs-host`; capacity is node status, not a label — [workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md)
- `mother` taints itself `reserved=storage:NoSchedule`; labels and taints apply at registration only — [workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md)
- `k3s agent` rejects `--disable`; the mixin gates it on `role == "server"` — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- Rebuilding another host: `--target-host`/`--build-host`, and why `sudo` elevation is required — [workflows/rebuild](/workflows/rebuild.md)
- `nvidia` mixin split: driver and `hardware.graphics` in `nvidia`, `cudaSupport` as `nvidiaCuda` — [hosts/HAL9000](/hosts/HAL9000.md)

## 2026-09-07

- Servers advertise the VIP as a tailnet subnet route; approval and unadvertising sit outside nix — [hosts/nyx-cluster](/hosts/nyx-cluster.md), [hosts/wintermute](/hosts/wintermute.md)
- `tars`, `case` and `kipp` are installed; the outstanding `TODO` facts are `mother`'s alone — [hosts/nyx-cluster](/hosts/nyx-cluster.md), [workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md)
- Servers pass `--tls-san` for the VIP per host; k3s does not reissue the cert when SANs change — [hosts/nyx-cluster](/hosts/nyx-cluster.md), [workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md)
- kube-vip's `vip_interface` is unset on purpose; one DaemonSet spans nodes whose NICs differ in name — [hosts/nyx-cluster](/hosts/nyx-cluster.md), [workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md)
- `tars` names one interface; an `en*` glob catches its uncabled second NIC and hangs wait-online — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- chronos is raidz2 plus an Optane log vdev; the OS SSD is by-id, mother having two NVMe — [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- The counter/SMART/link-speed ladder for telling a failing drive from a failing cable — [workflows/diagnose-disk-faults](/workflows/diagnose-disk-faults.md)
- The seed tree also carries the user's password hash; without it a new host is created locked — [workflows/install-nixos](/workflows/install-nixos.md)

## 2026-09-05

- Install a host once: harvest hardware facts, seed the host key, then `nixos-anywhere` — [workflows/install-nixos](/workflows/install-nixos.md)
- Rollout order and per-host `TODO` facts for the four cluster machines — [workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md)
- System-level sops decrypts at activation via the host SSH key; per-secret `sopsFile` in the mixin — [workflows/secrets](/workflows/secrets.md)
- Sops payloads go in `secrets/`, not `files/`, and only inside a leaf module folder — [architecture/module-layout](/architecture/module-layout.md)
- `conform` gates commit messages at the commit-msg stage; types and scopes live in `.conform.yaml` — [workflows/formatting-and-cspell](/workflows/formatting-and-cspell.md)
- A `pkgs/` subdir may hold a single package whose script lives under `files/` — [architecture/packages](/architecture/packages.md)
- The `server` profile and four headless hosts; cluster roles are mixins, not a second profile — [architecture/profiles](/architecture/profiles.md), [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- The `server-longhorn-v1` disko template and `mkDiskoLayout`'s `longhorn` size default — [hosts/nyx-cluster](/hosts/nyx-cluster.md)

## 2026-09-04

- The module trees live under `modules/{home,nixos}/`; flake outputs are flat `mkModules` keys — [architecture/entry-points](/architecture/entry-points.md), [architecture/auto-discovery](/architecture/auto-discovery.md)
- The theme's per-tree halves sit in one auto-discovered `compat.nix` behind `mkClassModule` — [decisions/dual-class-modules](/decisions/dual-class-modules.md)
- `mixins.programs.steam.resolution` is the second non-enable mixin surface beside hyprland's — [architecture/mixin-pattern](/architecture/mixin-pattern.md)
- The two option-lookup skills' `SKILL.md` files are the sole authority — [architecture/packages](/architecture/packages.md)

## 2026-09-01

- `schemes.spicetify` recolours Spotify via spicetify-nix's `customColorScheme` — [decisions/scheme-model](/decisions/scheme-model.md)
- `mkVariantModules` generates one scheme module per browser and editor, each with its own `enable` — [architecture/custom-lib](/architecture/custom-lib.md), [decisions/scheme-model](/decisions/scheme-model.md)
- An installed Firefox theme never updates: sideload change detection is mtime-or-path, Nix pins both — [reference/firefox-theming](/reference/firefox-theming.md)
- `schemes.librewolf` renders through FirefoxColor's `storage.local`, not a static theme xpi — [reference/firefox-theming](/reference/firefox-theming.md), [decisions/scheme-model](/decisions/scheme-model.md)
- `schemes.vscode` generates a theme extension; slots follow tinted-vscode's `base24.mustache` — [reference/base24](/reference/base24.md), [decisions/scheme-model](/decisions/scheme-model.md)
- `inputs.tinted-vscode` stays an input, not vendored; a test pins the theme's delta against it — [decisions/vendored-schemes](/decisions/vendored-schemes.md)

## 2026-08-31

- Modules take `flake`/`inputs`/`libUtil`/`libMath` as `importApply` args; only `osConfig` is special — [architecture/entry-points](/architecture/entry-points.md)

## 2026-08-28

- The theme is one dual-class `modules/theme/` dispatching on `_class`; `modules/global/` is gone — [architecture/module-layout](/architecture/module-layout.md), [decisions/dual-class-modules](/decisions/dual-class-modules.md)
- A theme is picked by `custom.themes.<name>.enable` via a local `mkThemeModule`, outside `mixins.` — [architecture/module-layout](/architecture/module-layout.md), [architecture/mixin-pattern](/architecture/mixin-pattern.md)
- `mkClassModule` selects by `_class`; a missing class key is a no-op, an unknown key throws — [architecture/custom-lib](/architecture/custom-lib.md)
- corrected: nix-schemes' shared modules arrive via `<class>Modules.default` imports in the glue — [architecture/module-layout](/architecture/module-layout.md)
- `meta.slug`: vendored for a tinted source, `libUtil.strings.slugify` of the name for a custom one — [decisions/scheme-model](/decisions/scheme-model.md)
- `overrides.palette` applies before the upcast, so a derived slot follows the slot it comes from — [decisions/scheme-model](/decisions/scheme-model.md)

## 2026-08-24

- The scheme is a total derived model; the transformer API and `requireKey` are gone — [decisions/scheme-model](/decisions/scheme-model.md)
- Per-scheme deviation is `schemes.overrides.<view>.<path>`, a palette slot name or a hex string — [decisions/scheme-model](/decisions/scheme-model.md)
- Sources: `schemes.source.tinted`/`.custom`; `generateScheme` yields a source, `mkScheme` the scheme — [architecture/custom-lib](/architecture/custom-lib.md)
- base16 upcasts to base24 unconditionally, so no consumer branches on `meta.system` — [reference/base24](/reference/base24.md)
- `named`, `status`, `ansi` are always-present views; colour words carry `normal`/`bright` — [reference/base24](/reference/base24.md)
- `schemes.accent` carries the accent; `custom.theme.gtk.accent` selects GNOME's nine only — [architecture/module-layout](/architecture/module-layout.md)
- Cursor slots are declared options with derived defaults; `accentAlt` is the accent −120° — [reference/cursor-theming](/reference/cursor-theming.md)
- corrected: on a dark scheme `fill` is `base00` and `outline` is `base06`, not the reverse — [reference/cursor-theming](/reference/cursor-theming.md)

## 2026-08-23

- Cursor themes compile Breeze SVGs to XCursor/`cursors_scalable`/hyprcursor — no recolouring hook — [reference/cursor-theming](/reference/cursor-theming.md)
- `schemes.cursors` owns the cursor theme; `name` is derived rather than configured — [reference/cursor-theming](/reference/cursor-theming.md)
- Python lints with flake8 + ruff-format at 79 columns; sandboxed flake8 needs no `flakeIgnore` — [workflows/formatting-and-cspell](/workflows/formatting-and-cspell.md)
- A python app takes `writePython3Bin` with `makeWrapperArgs` and carries no shebang — [architecture/module-layout](/architecture/module-layout.md)
- The `breeze` input pins a tag; its vendored templates are regenerated by hand — [workflows/dependency-updates](/workflows/dependency-updates.md)

## 2026-08-22

- `schemes.icons` exposes the recoloured pack read-only to both trees — [reference/gtk-theming](/reference/gtk-theming.md)
- `mkIconTheme` recolours Plasma `ColorScheme-*` stylesheets; GTK recolours only by filename suffix — [reference/gtk-theming](/reference/gtk-theming.md)
- corrected: a nix-schemes library module *may* read a transformer-added key, through `requireKey` — [architecture/module-layout](/architecture/module-layout.md)

## 2026-08-21

- `exclude` keeps a value sibling like `tidy/timer.nix` out of auto-discovery — [architecture/auto-discovery](/architecture/auto-discovery.md)
- IFD is disabled machine-wide and in the CI `nix_conf`; recovery is per-invocation `--option` — [decisions/no-ifd](/decisions/no-ifd.md)
- `pkgs-unstable` is the second escape hatch from the stable-only pin — [decisions/release-policy](/decisions/release-policy.md)
- Desktop-file contents are read by derivations, never at evaluation; `[Added Associations]` is gone — [decisions/desktop-files-at-build-time](/decisions/desktop-files-at-build-time.md)
- `requireDesktopFile` checks entries at build time; `lookupDesktopFiles` reads `desktopItems` — [architecture/custom-lib](/architecture/custom-lib.md)
- Shell bodies over 400 chars move to `files/<name>.sh`; nix values pass as env via `runtimeEnv` — [architecture/module-layout](/architecture/module-layout.md)
- `git` is taken from the ambient PATH rather than declared in `runtimeInputs`, except under systemd — [architecture/module-layout](/architecture/module-layout.md)

## 2026-08-20

- `generateScheme` reads a vendored Nix tree instead of parsing YAML; `fromYaml` and its IFD are gone — [decisions/vendored-schemes](/decisions/vendored-schemes.md)
- Vendored schemes refresh via monthly `nix-schemes-update.yaml`; `spec-0.11` is a branch, not a tag — [workflows/dependency-updates](/workflows/dependency-updates.md)
- `flake.schemes.<system>.<slug>` is the scheme itself; `generateScheme` lives in `lib/` — [architecture/custom-lib](/architecture/custom-lib.md)
- Colour primitives and WCAG metrics live under `libSchemes.color` — [architecture/custom-lib](/architecture/custom-lib.md)
- The image-based scheme source (`schemes.source.picture`, `base24-gen`) is gone — [architecture/custom-lib](/architecture/custom-lib.md)
- GTK CSS: `_defaults.scss` takes palette literals; `settings/_colors.scss` toolkit-branched forms — [reference/gtk-theming](/reference/gtk-theming.md)
- `mkGtkThemeCss` consumers `@import` the store path; per-variant entries, multi-root `SASS_PATH` — [reference/gtk-theming](/reference/gtk-theming.md)

## 2026-08-19

- adw-gtk3 is mandatory; stock stylesheets are flat-compiled, GTK4 applies it via the user sheet — [reference/gtk-theming](/reference/gtk-theming.md)
- `mkGtkThemeCss` compiles SCSS: Nix resolves colours, SCSS owns structure — [reference/gtk-theming](/reference/gtk-theming.md)
- `color.relativeLuminance` / `color.contrastRatio` added; GTK foreground picks use WCAG contrast — [reference/base24](/reference/base24.md)
- `home.file` aborts on a pre-existing unmanaged target without `backupFileExtension` — [workflows/rebuild](/workflows/rebuild.md)
- The `nix-schemes` sub-flake exports modules by hand; a new one needs registering twice — [architecture/auto-discovery](/architecture/auto-discovery.md)
- vicinae wraps its own launches in `uwsm-app`; its `Terminal=true` path needs `xdg-terminals.list` — [architecture/uwsm-session](/architecture/uwsm-session.md)
- The five ANSI assignments base16 and base24 disagree on, and which each consumer follows — [reference/base24](/reference/base24.md)
- Scheme non-standard keys come from `schemes.transformers`, read with `libSchemes.requireKey` — [architecture/custom-lib](/architecture/custom-lib.md)
- kitty home module added; follows base24 ANSI via the scheme's `ansi` attribute — [reference/base24](/reference/base24.md)
- corrected: base24 spec source is tinted-theming; the fork's four divergent ANSI slots were wrong — [reference/base24](/reference/base24.md)
- `warning` is `base09` (not spec's `base0F`) as a deliberate deviation; `success` added — [reference/base24](/reference/base24.md)

## 2026-08-17

- Unit switched to `X-Restart-Triggers`; the reload form silently no-ops without `ExecReload` — [apps/yas](/apps/yas.md)
- Popup timers only for `expireTimeout <= 0`; the daemon resolves the rest — [apps/yas](/apps/yas.md)
- No destructuring live GObject properties; explicit `onCleanup` destroy; `GError` calls throw — [apps/yas](/apps/yas.md)
- The home module installs the `astal-notifd` CLI, the only way to reach do-not-disturb — [apps/yas](/apps/yas.md)
- `npm run types` produces `@girs/` and `tsconfig.json`, which is untracked and loses `lib` on regen — [workflows/develop-yas](/workflows/develop-yas.md)
- A new source file is invisible to `nix build` until it is `git add`ed — [workflows/develop-yas](/workflows/develop-yas.md)
- `notify-send` corpus covering both body branches and visual resolution — [workflows/develop-yas](/workflows/develop-yas.md)

## 2026-08-16

- `apps/yas` documented: runtime shape, lazy-accessor convention, styling and nix integration — [apps/yas](/apps/yas.md), [apps/](/apps/index.md)
- yas dev loop: ags CLI scripts, `@girs` regeneration; a prettier hook cannot cover `apps/yas` — [workflows/develop-yas](/workflows/develop-yas.md)
- wintermute's home-manager deltas recorded (`wayvnc`, yas battery) — [hosts/wintermute](/hosts/wintermute.md)
- Log rewritten to rule 3's form: one line per change, no commit SHAs
- Hyprland is pinned to an upstream tag, not the default branch — [architecture/hyprland-lua-config](/architecture/hyprland-lua-config.md), [decisions/release-policy](/decisions/release-policy.md)
- Sibling modules are auto-discovered; only `tmux`, `waybar` and `rofi` import siblings explicitly — [architecture/module-layout](/architecture/module-layout.md)
- Theme owns the `monospace` and `emoji` fontconfig generics in the home tree — [architecture/module-layout](/architecture/module-layout.md)
- Themes became a `mixins.theme.<name>` category in `modules/global/`; accent split out — [architecture/mixin-pattern](/architecture/mixin-pattern.md), [architecture/module-layout](/architecture/module-layout.md)

## 2026-08-15

- `lib/` split: general-purpose helpers to the `apps/util-lib` flake as `libUtil` — [decisions/util-lib-split](/decisions/util-lib-split.md), [architecture/custom-lib](/architecture/custom-lib.md)
- `apps/nix-schemes` adopted `libUtil` and the lib conventions — [architecture/custom-lib](/architecture/custom-lib.md)

## 2026-08-14

- Bind- and rofi-launched apps routed through `uwsm-app` for their own systemd unit — [architecture/uwsm-session](/architecture/uwsm-session.md), [architecture/custom-lib](/architecture/custom-lib.md)

## 2026-08-13

- `nixos-options` skill added as the system-level counterpart to `hm-options` — [architecture/packages](/architecture/packages.md)

## 2026-08-12

- Upstream blockers tracked by krank; the four comment markers recorded — [workflows/track-upstream-blockers](/workflows/track-upstream-blockers.md), [architecture/comment-markers](/architecture/comment-markers.md)
- The vendored `autoUpgrade` module recorded as deliberate, not debt — [decisions/vendored-auto-upgrade](/decisions/vendored-auto-upgrade.md)
- `nh` adopted as the interactive rebuild front-end — [workflows/rebuild](/workflows/rebuild.md)
- `custom.command-collection` and the `helpers/` mixin category deleted as code rot — [architecture/mixin-pattern](/architecture/mixin-pattern.md)
- CI Nix moved to `nix-quick-install-action` + `cache-nix-action` — [decisions/ci-nix-installer](/decisions/ci-nix-installer.md)
- Renovate's nix manager rejected again; update channels returned to the workflows — [decisions/renovate-scope](/decisions/renovate-scope.md), [workflows/dependency-updates](/workflows/dependency-updates.md)
- CI signing moved to a GitHub App token; update skeleton extracted to a composite — [decisions/ci-identity](/decisions/ci-identity.md), [workflows/dependency-updates](/workflows/dependency-updates.md)

## 2026-08-10

- HDR on DP-2 on demand via `bitdepth = 10`; `hyprctl eval` replaces the absent `keyword` — [hosts/HAL9000](/hosts/HAL9000.md), [architecture/hyprland-lua-config](/architecture/hyprland-lua-config.md)
- The `configType = "lua"` shape; YouTube PWA exempted from translucency — [architecture/hyprland-lua-config](/architecture/hyprland-lua-config.md)
- Rejected: a hyprland MCP server and a pinned `hypr-rules` lookup tool

## 2026-07-29

- `users/joker9944/nixos` made server-safe; desktop extras gated per owning mixin — [architecture/entry-points](/architecture/entry-points.md)
- Profiles added as a role layer above mixins; hosts reduced to deltas — [architecture/profiles](/architecture/profiles.md), [decisions/host-profiles](/decisions/host-profiles.md)
- Mixins returned to binary `enable`; files renamed to kebab-case matching their options — [architecture/mixin-pattern](/architecture/mixin-pattern.md), [decisions/enable-flag-mixins](/decisions/enable-flag-mixins.md), [architecture/module-layout](/architecture/module-layout.md)
- `lib/` doc-string convention (RFC 145) recorded — [architecture/custom-lib](/architecture/custom-lib.md)
- Bundle migrated to OKF v0.2 and stripped of change-narrative

## 2026-07-27

- cspell dropped from the git hook; dictionaries submodule replaced by a plain clone — [workflows/formatting-and-cspell](/workflows/formatting-and-cspell.md)

## 2026-07-24

- New workflow: `UPGRADE(<release>)` markers for deferred release work — [workflows/release-upgrade](/workflows/release-upgrade.md)
- Anti-pattern: look for an upstream home-manager module before hand-rolling config — [workflows/add-mixin](/workflows/add-mixin.md)
- regreet's hyprland config ported from hyprlang to lua

## 2026-07-23

- Option lookup became a nix factory baking `options.json` into the query binaries — [architecture/packages](/architecture/packages.md)

## 2026-07-22

- `hosts/mixins/` converted to `mkMixinModule` sugar — [architecture/mixin-pattern](/architecture/mixin-pattern.md)

## 2026-07-20

- `mkMixinModule` / `mkMixinsModule` added, removing per-leaf boilerplate — [architecture/mixin-pattern](/architecture/mixin-pattern.md)

## 2026-07-19

- New concept: folder and `files/` conventions for every module, not just mixins — [architecture/module-layout](/architecture/module-layout.md)

## 2026-07-17

- Bundle bootstrapped; release policy extracted from the overview — [decisions/release-policy](/decisions/release-policy.md)
