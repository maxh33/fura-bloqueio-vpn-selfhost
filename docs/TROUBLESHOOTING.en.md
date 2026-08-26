*[Português](TROUBLESHOOTING.md) | English*

# Common problems

**`bootstrap.sh` failed partway through**
Run `./bootstrap.sh` again — it's idempotent, it skips what's already done and picks up where it left off.

**I can't SSH in anymore after hardening**
If you have access to the provider's web console (AWS/Oracle/GCP offer a "serial console"), get in through there and revert: `rm /etc/ssh/sshd_config.d/99-hardening.conf && systemctl reload sshd`.

**Firewall seems to "reset" itself after a reboot, or port 1194 closes out of nowhere**
Some VPS images (Oracle's official Ubuntu image is the most common case) already ship with a pre-configured `iptables`, independent of `ufw`. If `bootstrap.sh` ran and enabled `ufw` on top of that existing firewall, the two can load in different orders on boot and one overwrites the other. See step 0.5 of [GUIA-COMPLETO.en.md](GUIA-COMPLETO.en.md) — fix this BEFORE running `bootstrap.sh`, not after.

**`git clone` gives `bash: git: command not found`**
Minimal VPS image doesn't ship with `git`. Install it first: `sudo apt update && sudo apt install -y git`. See step 0.5 of [GUIA-COMPLETO.en.md](GUIA-COMPLETO.en.md).

**`bootstrap.sh` stops at step 6 with `Failed to reload sshd.service: Unit sshd.service not found`**
Some Ubuntu images name the service `ssh`, not `sshd`. The hardening file was already written by this point, it just needs to be applied. Run `sudo systemctl reload ssh`, then `git pull && sudo ./bootstrap.sh` again to continue from step 7 onward.

**`docker compose up -d` doesn't bring the container up**
Check `docker compose logs openvpn`. Common error: port 1194/UDP already in use, or the provider's external firewall (not the VPS's `ufw`) blocking the port — see step 5 of [ESCOLHER-VPS.en.md](ESCOLHER-VPS.en.md).

**Container stuck `Restarting` with `iptables v1.8.4 (legacy): can't initialize iptables table 'nat'`**
The `kylemanna/openvpn` image uses legacy iptables, which breaks on hosts with an nftables backend (common on newer kernels — Ubuntu 22.04+/24.04, regardless of CPU architecture). `docker-compose.yml` now forces the container to use `iptables-nft` before starting OpenVPN. If you had an older version of this project (or tried the host-side NAT workaround — doesn't work reliably, the host has no route to the VPN's subnet, causing flaky connections/intermittent DNS failures), update and recreate:
```bash
git pull
sudo docker compose up -d --force-recreate
```
If you manually edited `/etc/ufw/before.rules` adding a `# fura-bloqueio-nat` block, remove it and run `sudo ufw reload` — it conflicts with the correct NAT (now done inside the container).

**`./novo-cliente.sh` or `./revogar-cliente.sh` says "Docker isn't running or you don't have permission to use it"**
`bootstrap.sh` adds you to the `docker` group, but that only takes effect in a new SSH session. Log out and back in (`exit` + reconnect), or run the command with `sudo` for now.

**The `.ovpn` client won't connect**
Confirm that 1194/UDP is open both in the VPS's `ufw` and in the provider's firewall. Test with `docker compose exec openvpn ovpn_listclients` to see if the client exists.

**`croc` isn't installed on the VPS or on the receiving computer**
`curl https://getcroc.schollz.com | bash` (Linux/Mac) or download the binary from https://github.com/schollz/croc/releases (Windows). Or use the `scp` fallback that `novo-cliente.sh` prints.

## If none of this fixes it: ask an AI agent for help

Paste the full error into a command-line agent (if you have Claude Code or Codex CLI installed):

```
claude "bootstrap.sh failed at step X with this error: <paste the error here>"
```

This is entirely optional — the installer works on its own without any AI. It's just a shortcut for diagnosing something out of the ordinary.
