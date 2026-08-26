#!/bin/bash
# Revoga o certificado de um cliente — ele para de conseguir conectar na VPN.
set -e

cd "$(dirname "$0")"
source lib/common.sh

if [ -z "$1" ]; then
  echo "Uso: $0 <nome-do-cliente>"
  exit 1
fi
CLIENT_NAME="$1"

require_docker
require_container_running

if ! docker compose exec -T openvpn ovpn_listclients < /dev/null | grep -q "^$CLIENT_NAME,"; then
  err "cliente '$CLIENT_NAME' não existe."
  echo "Clientes disponíveis:"
  docker compose exec -T openvpn ovpn_listclients < /dev/null
  exit 1
fi

read -p "Tem certeza que quer revogar '$CLIENT_NAME'? (y/n) " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] || { echo "Cancelado."; exit 0; }

log "revogando $CLIENT_NAME..."
# ovpn_revokeclient já regenera e copia o CRL sozinho — não existe um ovpn_getcrl separado nesta imagem
docker compose exec -T -e EASYRSA_BATCH=1 openvpn ovpn_revokeclient "$CLIENT_NAME" < /dev/null

rm -f "clientes/$CLIENT_NAME.ovpn"
log "$CLIENT_NAME revogado. Ele não consegue mais conectar."
