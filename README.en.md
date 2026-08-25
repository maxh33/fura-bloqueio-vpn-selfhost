*[Português](README.md) | English*

# FuraBloqueio

Free personal VPN, on your own VPS — not a third-party company logging your browsing. Built to dodge growing internet censorship in Brazil, no monthly fee, running on a free tier (Oracle Cloud, AWS, Google Cloud).

If you know how to open a terminal and follow a step-by-step guide, you can do this. It's fast.

## What you get

A `.ovpn` file you import into the **OpenVPN Connect** app (Windows, Mac, Linux, Android, iOS). Day to day, it's just open the app and hit connect/disconnect.

## How to install

1. Create a free tier VPS — see the options in [docs/ESCOLHER-VPS.en.md](docs/ESCOLHER-VPS.en.md) (we recommend Oracle Cloud, free forever).
2. Connect via SSH and clone this repo:
   ```bash
   git clone https://github.com/maxh33/fura-bloqueio-vpn-selfhost.git
   cd fura-bloqueio-vpn-selfhost
   ```
3. Set up the whole VPS with one command (firewall, updates, Docker, VPN server):
   ```bash
   sudo ./bootstrap.sh
   ```
4. Generate your certificate and get the file onto your computer:
   ```bash
   ./novo-cliente.sh YOUR_NAME
   ```
5. Import the `.ovpn` file into [OpenVPN Connect](https://openvpn.net/client/) and connect.

Done — no monthly fee, no third party sitting in the middle of your traffic.

## Questions, other commands, security details?

See the [full guide](docs/GUIA-COMPLETO.en.md).

## License

MIT — see also the [legal notice](docs/AVISO-LEGAL.en.md).
