*[Português](GUIA-COMPLETO.md) | English*

# Full guide

## Detailed step-by-step

### 0. Choose and create your VPS

See [ESCOLHER-VPS.en.md](ESCOLHER-VPS.en.md) — we recommend Oracle Cloud (free forever). Needs to be Ubuntu 22.04/24.04.

### 0.5. Prepare the VPS (before cloning)

This varies quite a bit between providers (Oracle, AWS, GCP, Hetzner, etc). `bootstrap.sh` handles most of it, but a few steps need to happen manually BEFORE it, in the right order:

1. Update the system and make sure `git` is installed — minimal VPS images (Oracle's Ubuntu included) often ship without it:
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo apt install -y git
   ```
2. Add your public SSH key to the `authorized_keys` of the user you'll be using — `bootstrap.sh` only disables password login if it finds a key already configured, otherwise it silently skips SSH hardening (just a warning):
   ```bash
   mkdir -p ~/.ssh && chmod 700 ~/.ssh
   echo "YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```
   Test key-based login in a new session before continuing (don't close the current session until you confirm).
3. Check whether the VPS already ships with a firewall preconfigured outside of `ufw` — common on official images from some providers (e.g. Oracle, see the gotcha in [ESCOLHER-VPS.en.md](ESCOLHER-VPS.en.md)):
   ```bash
   sudo iptables -L -n -v
   ```
   If rules beyond the basics show up (loopback/established/ICMP), resolve the conflict before letting `bootstrap.sh` configure `ufw` on top — the two fighting each other means an unpredictable firewall after a reboot.
4. Confirm that ports 22/TCP and 1194/UDP are already open in the **provider's** firewall (outside the VPS) — step 5 of [ESCOLHER-VPS.en.md](ESCOLHER-VPS.en.md). Without this, traffic never reaches the VPS even with `ufw`/`iptables` open on the inside.

Once that's done, move on to step 1.

### 1. Connect to the VPS and clone this repo

```bash
ssh user@YOUR_IP
git clone https://github.com/maxh33/fura-bloqueio-vpn-selfhost.git
cd fura-bloqueio-vpn-selfhost
```

### 2. Run the bootstrap (command 1)

```bash
sudo ./bootstrap.sh
```

Sets up the whole VPS by itself: firewall (`ufw`), intrusion protection (`fail2ban`), automatic security updates, installs Docker, and brings up the OpenVPN server. Takes a few minutes. At the end, it asks for your VPS's public IP/domain.

Doesn't depend on any AI — it's a plain bash script, you can read the whole thing before running it.

### 3. Generate your certificate and get the file (command 2)

```bash
./novo-cliente.sh YOUR_NAME
```

Generates the `.ovpn` file and delivers it via [croc](https://github.com/schollz/croc) — a short code shows up on screen. On your computer (Windows, Mac, or Linux), install croc and type that code to receive the file, no need to know scp or SSH.

### 4. Connect

Install [OpenVPN Connect](https://openvpn.net/client/), import the `.ovpn` file you received, hit connect.

## Other commands

- `./revogar-cliente.sh NAME` — revokes someone's access (lost their phone, done using it, etc).
- `./backup-pki.sh` — backs up the server's master key (keep it outside the VPS — if it's lost, everyone loses access and you have to rebuild everything).

## Deliberate trade-offs

- Client certificates are generated without their own password (`nopass`) — simpler for day-to-day use, fine for personal/family use. If you want more security, you can add a password manually (see [kylemanna/openvpn](https://github.com/kylemanna/docker-openvpn)'s docs).
- Officially supported only on Ubuntu/Debian.
- `croc` is this project's only external dependency (not a standard `apt`/`docker` tool) — chosen because it solves exactly the problem of "getting a file off the VPS without leaving a port open," without reinventing that.

## Ran into a problem?

See [TROUBLESHOOTING.en.md](TROUBLESHOOTING.en.md).

## Legal notice

See [AVISO-LEGAL.en.md](AVISO-LEGAL.en.md).

## Optional bonus

Want to help more people find this project (or improve your own GitHub repos)? See [SEO-OPCIONAL.md](SEO-OPCIONAL.md) (Portuguese-only — it's about Brazilian search-engine reach).
