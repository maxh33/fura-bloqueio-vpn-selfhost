#!/bin/bash
# Funções compartilhadas por bootstrap.sh, novo-cliente.sh, revogar-cliente.sh e backup-pki.sh.

log()  { echo -e "\033[1;32m[fura-bloqueio]\033[0m $*"; }
warn() { echo -e "\033[1;33m[aviso]\033[0m $*"; }
err()  { echo -e "\033[1;31m[erro]\033[0m $*" >&2; }

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    err "este comando precisa rodar como root (use sudo)."
    exit 1
  fi
}

require_docker() {
  if ! docker info > /dev/null 2>&1; then
    err "Docker não está rodando ou você não tem permissão pra usá-lo."
    exit 1
  fi
}

require_container_running() {
  if ! docker ps --format '{{.Names}}' | grep -q "^fura-bloqueio-openvpn$"; then
    err "o container do OpenVPN não está rodando."
    echo "  Suba com: docker compose up -d"
    exit 1
  fi
}

detect_ram_mb() {
  awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo
}
