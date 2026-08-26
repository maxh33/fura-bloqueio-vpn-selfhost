*Português | [English](CHANGELOG.en.md)*

# Changelog

## 2026-08-26 — testes de ponta a ponta em VPS real (Oracle Ampere A1, arm64)

Primeira validação completa do fluxo (clonar → `bootstrap.sh` → gerar cliente → conectar → revogar) numa VPS de verdade. Vários bugs foram encontrados e corrigidos — documentados aqui pra quem cair no mesmo problema numa versão antiga do projeto.

### Corrigido

- **`git` ausente**: imagens mínimas de VPS (Oracle Ubuntu inclusive) não vêm com `git` instalado, quebrando o primeiro `git clone`. `bootstrap.sh` (passo 0.5 do guia) agora garante isso antes de clonar.
- **Bit executável não commitado**: os scripts `.sh` estavam commitados como `100644` em vez de `100755` — `sudo ./bootstrap.sh` dava "Permission denied"/"command not found" num clone novo. Corrigido no repositório.
- **`systemctl reload sshd` falha em algumas imagens Ubuntu**: o serviço se chama `ssh`, não `sshd`, dependendo da imagem — travava o hardening de SSH no meio do bootstrap. Agora tenta os dois nomes.
- **NAT do container falha em host arm64 (Oracle Ampere A1 e outros ARM free-tier)**: a imagem `kylemanna/openvpn` só existe em amd64, rodando via emulação QEMU em ARM. Nem iptables legacy (`can't initialize iptables table nat`) nem nftables (`Protocol not supported`) funcionam dentro do container emulado — limitação da própria emulação, não do projeto. Fix: NAT passou a ser feito no **host**, com o container recebendo IP fixo (`172.28.0.2`) pra dar rota estável de volta pra rede da VPN, persistida via `systemd` (sobrevive a reboot).
- **`docker compose run` conflitava com o IP fixo do container**: depois do fix acima, `novo-cliente.sh`/`revogar-cliente.sh` usavam `docker compose run` (cria container novo, tenta usar o mesmo IP fixo do servidor já rodando → "Address already in use"). Trocado por `docker compose exec` (roda dentro do container já existente).
- **`redirect-gateway` nunca era empurrado ao cliente** — bug pré-existente do projeto, não ligado a ARM/Oracle. Sem essa diretiva, a VPN conecta mas só roteia a própria rede interna (`192.168.255.0/24`); todo o resto do tráfego do cliente seguia fora do túnel, sem aviso nenhum. `ovpn_genconfig` agora roda com `-p "redirect-gateway def1"`.

### Isso te afeta?

Se você rodou o `bootstrap.sh` antes de 2026-08-26, seu servidor provavelmente **não estava roteando o tráfego dos clientes de verdade** (só parecia conectado). Dê um `git pull`, rode `sudo ./bootstrap.sh` de novo (idempotente, não quebra o que já funciona) e confirme com o teste abaixo.

### Como verificar que a VPN está funcionando de verdade

Depois de conectar, abra um site tipo "qual meu ip" no dispositivo conectado. Se o IP mostrado for o da sua VPS (não o da sua operadora/rede local), o roteamento tá correto. Se continuar mostrando seu IP normal, o `redirect-gateway` não foi aplicado — veja [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).
