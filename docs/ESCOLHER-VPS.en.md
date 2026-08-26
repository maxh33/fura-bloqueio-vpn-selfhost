*[Português](ESCOLHER-VPS.md) | English*

# Choosing a free-tier VPS

| Provider | Plan | RAM | vCPU | Duration | Notes |
|---|---|---|---|---|---|
| **Oracle Cloud** | Always Free Ampere A1 | up to 24GB | up to 4 | **forever**, no credit card expiring | **Recommended** — genuinely free, by far the most RAM. Signup can throw a "capacity unavailable" error — try again at a different time/region if it happens. |
| **AWS EC2** | t2.micro / t3.micro | 1GB | 1 | 12 months, then billed | Low RAM triggers `bootstrap.sh`'s automatic swapfile. Set up a billing alarm so you don't get charged by surprise after the 12 months. |
| **Google Cloud** | e2-micro | 1GB | shared | Always free, only in some US regions | Latency from Brazil is real, but works fine for browsing/text. |

## Basic step-by-step (any provider)

1. Create an account with the provider you picked.
2. Create an instance/VM with a **Ubuntu 22.04 or 24.04 LTS** image.
3. Note down the instance's public IP.
4. Download/save the SSH key the provider generates — that's how you'll access the VPS.
5. Open port 1194/UDP in the provider's own firewall (security group on AWS, "Security List"/"Network Security Group" on Oracle) — besides what `bootstrap.sh` configures inside the VPS, the provider also has its own external firewall.
   - **On Oracle**: Compute → Instances → your instance → VNIC → Subnet → Security List → **Add Ingress Rules** → Source CIDR `0.0.0.0/0`, IP Protocol **UDP**, Destination Port Range `1194`. The `22/TCP` rule usually comes open by default.
6. **Oracle gotcha (`bootstrap.sh` already handles this)**: Oracle's official Ubuntu image already ships with a pre-configured `iptables` (default-deny + SSH allowed, outside of `ufw`). Tested on a real VPS: installing `ufw` makes `apt` remove that old firewall (`iptables-persistent`/`netfilter-persistent`) on its own, no manual step needed. Only if something looks off after bootstrap (port closing on its own, firewall "resetting"), check and fix it manually:
   ```bash
   sudo iptables -L -n -v
   sudo systemctl disable --now netfilter-persistent 2>/dev/null || true
   sudo iptables -F && sudo iptables -P INPUT ACCEPT
   sudo ufw reload
   ```
7. Connect via SSH and follow the [main README](../README.en.md).

## Want to host outside Brazil?

See the jurisdiction considerations in [AVISO-LEGAL.en.md](AVISO-LEGAL.en.md). Practical note: Oracle Cloud locks your account's "home" region at creation — to host in a different country you normally need to create a **new account** (new tenancy), you can't just move an instance to another region within the same existing free tier account. The same limitation usually applies to AWS/GCP depending on the plan.
