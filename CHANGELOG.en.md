*[Português](CHANGELOG.md) | English*

# Changelog

## 2026-08-26 — end-to-end testing on a real VPS (Oracle Ampere A1, arm64)

First full validation of the flow (clone → `bootstrap.sh` → generate client → connect → revoke) on a real VPS. Several bugs were found and fixed — documented here for anyone hitting the same issue on an older version of the project.

### Fixed

- **Missing `git`**: minimal VPS images (Oracle's Ubuntu included) don't ship with `git`, breaking the first `git clone`. `bootstrap.sh` (step 0.5 of the guide) now ensures it's installed before cloning.
- **Executable bit not committed**: the `.sh` scripts were committed as `100644` instead of `100755` — `sudo ./bootstrap.sh` failed with "Permission denied"/"command not found" on a fresh clone. Fixed in the repo.
- **`systemctl reload sshd` fails on some Ubuntu images**: the service is named `ssh`, not `sshd`, depending on the image — this stalled SSH hardening mid-bootstrap. Now tries both names.
- **Container NAT fails on arm64 hosts (Oracle Ampere A1 and other free-tier ARM)**: the `kylemanna/openvpn` image only exists for amd64, running via QEMU emulation on ARM. Neither legacy iptables (`can't initialize iptables table nat`) nor nftables (`Protocol not supported`) work inside the emulated container — a limitation of the emulation itself, not the project. Fix: NAT is now done on the **host**, with the container given a fixed IP (`172.28.0.2`) so the host has a stable route back to the VPN's network, persisted via `systemd` (survives reboots).
- **`docker compose run` conflicted with the container's fixed IP**: after the fix above, `novo-cliente.sh`/`revogar-cliente.sh` used `docker compose run` (spins up a new container, tries to reuse the same fixed IP as the already-running server → "Address already in use"). Switched to `docker compose exec` (runs inside the existing container instead).
- **`redirect-gateway` was never pushed to the client** — a pre-existing bug in the project, unrelated to ARM/Oracle. Without that directive, the VPN connects but only routes its own internal network (`192.168.255.0/24`); all other client traffic silently stayed outside the tunnel. `ovpn_genconfig` now runs with `-p "redirect-gateway def1"`.

### Does this affect you?

If you ran `bootstrap.sh` before 2026-08-26, your server was likely **not actually routing client traffic** (it just looked connected). Run `git pull`, then `sudo ./bootstrap.sh` again (idempotent, won't break what already works), and confirm with the check below.

### How to verify the VPN is actually working

After connecting, open a "what's my ip" site on the connected device. If the IP shown is your VPS's (not your carrier/local network's), routing is correct. If it still shows your normal IP, `redirect-gateway` wasn't applied — see [TROUBLESHOOTING.en.md](docs/TROUBLESHOOTING.en.md).
