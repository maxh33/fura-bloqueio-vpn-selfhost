#!/bin/bash
# Prepara uma VPS Ubuntu/Debian nova do zero: firewall, fail2ban, SSH hardening,
# swap (se pouca RAM), Docker, e sobe o OpenVPN. Idempotente — pode rodar de novo sem medo.
set -e

cd "$(dirname "$0")"
source lib/common.sh

export DEBIAN_FRONTEND=noninteractive

DRY_RUN=false
[ "$1" = "--dry-run" ] && DRY_RUN=true

run() {
  if $DRY_RUN; then
    echo "  [dry-run] $*"
  else
    "$@"
  fi
}

on_fail() {
  err "bootstrap falhou no passo: $CURRENT_STEP"
  echo "  Veja docs/TROUBLESHOOTING.md — ou cole o erro acima num agente de IA"
  echo "  (ex: claude \"o bootstrap.sh falhou no passo '$CURRENT_STEP' com este erro: ...\")"
}
trap on_fail ERR

require_root

CURRENT_STEP="detectar distro/RAM"
if ! grep -qiE 'ubuntu|debian' /etc/os-release; then
  warn "distro não testada (só Ubuntu/Debian são suportados oficialmente). Continuando mesmo assim..."
fi
RAM_MB=$(detect_ram_mb)
log "RAM detectada: ${RAM_MB}MB"

CURRENT_STEP="swap"
if [ "$RAM_MB" -lt 2048 ] && ! swapon --show | grep -q .; then
  log "RAM baixa, criando swap de 2G..."
  run fallocate -l 2G /swapfile
  run chmod 600 /swapfile
  run mkswap /swapfile
  run swapon /swapfile
  if ! grep -q '/swapfile' /etc/fstab; then
    $DRY_RUN || echo '/swapfile none swap sw 0 0' >> /etc/fstab
  fi
else
  log "swap: ok (RAM suficiente ou swap já existe)"
fi

CURRENT_STEP="unattended-upgrades"
if ! dpkg -l unattended-upgrades > /dev/null 2>&1; then
  log "instalando unattended-upgrades..."
  run apt-get update -qq
  run apt-get install -y unattended-upgrades
  run dpkg-reconfigure -f noninteractive unattended-upgrades
else
  log "unattended-upgrades: ok"
fi

CURRENT_STEP="ufw"
if ! command -v ufw > /dev/null 2>&1; then
  run apt-get install -y ufw
fi
SSH_PORT=$(grep -iE '^\s*Port\s' /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' | head -1)
SSH_PORT=${SSH_PORT:-22}
if ! command -v ufw > /dev/null 2>&1 || ! ufw status | grep -q "Status: active"; then
  log "configurando ufw (libera só SSH:$SSH_PORT e 1194/udp)..."
  run ufw default deny incoming
  run ufw default allow outgoing
  run ufw allow "$SSH_PORT"/tcp
  run ufw allow 1194/udp
  run ufw --force enable
else
  log "ufw: já ativo, garantindo regras..."
  run ufw allow "$SSH_PORT"/tcp
  run ufw allow 1194/udp
fi

CURRENT_STEP="fail2ban"
if ! dpkg -l fail2ban > /dev/null 2>&1; then
  log "instalando fail2ban..."
  run apt-get install -y fail2ban
  run systemctl enable --now fail2ban
else
  log "fail2ban: ok"
fi

CURRENT_STEP="ssh hardening"
if [ -n "$SUDO_USER" ] && [ -s "/home/$SUDO_USER/.ssh/authorized_keys" ]; then
  read -p "Desativar login SSH por senha e login root? Confirme só se você já testou login por chave SSH (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    $DRY_RUN || cat > /etc/ssh/sshd_config.d/99-hardening.conf <<'EOF'
PasswordAuthentication no
PermitRootLogin no
EOF
    run systemctl reload sshd
    log "SSH hardening aplicado."
  else
    warn "SSH hardening pulado (você pode rodar bootstrap.sh de novo depois)."
  fi
else
  warn "não achei authorized_keys pra um usuário sudo — pulando SSH hardening pra não te trancar fora."
fi

CURRENT_STEP="docker"
if ! command -v docker > /dev/null 2>&1; then
  log "instalando Docker..."
  command -v curl > /dev/null 2>&1 || run apt-get install -y curl
  run bash -c "curl -fsSL https://get.docker.com | sh"
  [ -n "$SUDO_USER" ] && run usermod -aG docker "$SUDO_USER"
else
  log "docker: ok"
fi

CURRENT_STEP="inicializar PKI"
require_docker
# Precisa rodar ANTES do "up -d": sem PKI, o container principal entra em crash-loop
# (ovpn_run espera /etc/openvpn/ovpn_env.sh, que só existe depois do ovpn_genconfig).
if [ -z "$(docker compose run --rm openvpn sh -c 'ls /etc/openvpn/pki 2>/dev/null' < /dev/null)" ]; then
  [ -f .env ] || cp .env.example .env
  # shellcheck disable=SC1091
  source .env
  if [ -z "$SERVER_ADDR" ] || [ "$SERVER_ADDR" = "seu-ip-ou-dominio-aqui" ]; then
    read -r -p "IP público ou domínio desta VPS: " SERVER_ADDR
  fi
  run docker compose run --rm openvpn ovpn_genconfig -u "udp://$SERVER_ADDR" < /dev/null
  # EASYRSA_BATCH evita prompt interativo de Common Name (não tem TTY aqui)
  run docker compose run --rm -e EASYRSA_BATCH=1 -e EASYRSA_REQ_CN="$SERVER_ADDR" openvpn ovpn_initpki nopass < /dev/null
else
  log "PKI: já inicializado."
fi

CURRENT_STEP="subir docker compose"
run docker compose up -d

CURRENT_STEP="self-test"
$DRY_RUN || docker compose ps
$DRY_RUN || ufw status verbose

log "PRONTO — próximo passo: ./novo-cliente.sh SEU_NOME"
