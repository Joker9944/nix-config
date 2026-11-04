---
type: Playbook
title: Diagnose a faulted disk
description: Tell a dying drive from a bad cable when ZFS faults a pool member — the counter, SMART and link-speed ladder, in that order.
tags: [workflow, zfs, smart, sata, hardware]
generated:
  by: claude-code/claude-opus-5
  at: 2026-11-04T00:00:00Z
---

# Trigger

`zpool status` reports a `FAULTED` or `DEGRADED` member, or a host logs disk I/O errors. Only [mother](/hosts/nyx-cluster.md) runs ZFS.

Work the ladder in order. Each rung narrows drive-versus-link before anything is unplugged, and the cheap fix is at the bottom.

# 1. Read the counters, not the verdict

```bash
zpool status -v <pool>
```

`too many errors` is libzfs' fault threshold, not a diagnosis. The three columns are:

| Pattern | Reading |
|---|---|
| `CKSUM` > 0 | data came back wrong — media or RAM. Suspect the drive. |
| `READ`/`WRITE` > 0, `CKSUM` 0 | the device left the bus. Suspect the link. |
| `errors: No known data errors` | nothing was lost; this is an availability problem, not an integrity one. |

# 2. Date the errors

```bash
zpool history <pool> | grep -E 'replace|clear|scrub'
```

Counters persist until `zpool clear`, so they can outlive the disk they describe — check whether a `replace` (which resets them for the new vdev) or a `clear` sits between the errors and now. The last clean scrub bounds when the damage started.

# 3. Map vdev to a serial

chronos names its members by WWN (`wwn-0x…-part1`). A member that is already gone shows its vdev GUID instead, followed by the last path it held — which still carries the WWN:

```bash
ls -l /dev/disk/by-id/wwn-0x<wwn>
lsblk -o NAME,SERIAL,MODEL -d /dev/sd?
```

`/dev/sdX` is assigned in discovery order, so it shifts whenever a device leaves the bus or a non-ATA disk appears — on mother `sdh` is a 10 GB iSCSI volume, not a pool member. The serial is the only handle that survives a reboot and identifies the drive in the chassis.

# 4. SMART: media or interface?

```bash
smartctl -a /dev/sdX
```

The `smartd` mixin puts `smartmontools` in `environment.systemPackages` — the service unit pins its own copy and exports nothing, so without the mixin `smartctl` is not on `PATH`. It also schedules a short self-test daily at 02:00 and a long one Wednesday at 03:00 (`services.smartd.defaults.autodetected`) and pushes any warning to Gotify, so a failing drive usually announces itself before a pool member faults.

| Attribute rising | Means |
|---|---|
| `Reallocated_Sector_Ct`, `Current_Pending_Sector`, `Offline_Uncorrectable` | the platters are failing. Replace the drive. |
| `UDMA_CRC_Error_Count` | corrupted frames on the SATA link. Replace the cable. |

Read it across every member, not just the accused: one drive with CRC errors while its siblings sit at zero localises the fault to that port.

# 5. Confirm with link speed

```bash
cat /sys/class/ata_link/*/sata_spd
```

libata steps a link down 6.0 → 3.0 → 1.5 Gbps as CRC errors accumulate, pinning `sata_spd_limit`. A member negotiating below its siblings is independent proof of a physical-layer fault.

To find the port:

```bash
readlink -f /sys/block/sdX | grep -oE 'ata[0-9]+'
cat /sys/class/ata_port/ata<N>/port_no
```

`port_no` counts from 1 and AHCI from 0, so `port_no N` is the Nth connector on the controller. mother's eight HDDs are all on the onboard PCH AHCI controller (`0000:00:17.0`) as `ata1`–`ata8`.

# 6. Fix, then verify

Reseat or swap the cable; moving the drive to a spare port isolates a bad connector from a bad cable. `sata_spd_limit` is runtime state, so reboot and re-read `sata_spd` — back at full speed means the link is genuinely healthy. Then `zpool clear <pool>`, let the resilver finish, and scrub.

# Gotchas

* **`UDMA_CRC_Error_Count` never resets.** It is lifetime-cumulative, so a fixed cable keeps its old value. Record the number and check it stops growing.
* **A scrub that finishes too fast did not run.** Compare the duration against the pool's size and its previous scrubs in `zpool history`; chronos takes about eight hours, so a 65-second `scrub repaired 0B` is an abort.
* **A faulted member generates no new kernel errors**, because ZFS stops sending it I/O. An empty `journalctl -k | grep ata` is not a clean bill of health.
* **smartd's `notifications.mail.mailer` is not a `-s`-style hook.** The NixOS module owns the `-M exec` slot itself and pipes an RFC822 blob plus a whole `smartctl -a` dump into `mailer -i <recipient>`. A readable push means leaving every `notifications.*` backend off — including `wall`, which defaults on — so the module's `notifyOpts` stays empty, then supplying `-m <nomailer> -M exec` in the directive and reading the `SMARTD_*` environment variables.
* **All eight members self-test together.** Staggering would need explicit `services.smartd.devices` entries, and `/dev/sdX` is not stable across boots — the same reason step 3 exists.
* **`services.zfs.trim` is off on mother** — the HDDs do not support TRIM and 3D XPoint has no NAND garbage collection for it to feed, so the Optane does not need it either — and a missing trim timer is expected, not a symptom. The btrfs root is covered by `services.fstrim`.

# Related

* [hosts/nyx-cluster](/hosts/nyx-cluster.md) — where chronos lives and what it is made of.
* [workflows/nyx-bootstrap](/workflows/nyx-bootstrap.md) — the pre-migration pool checks.
