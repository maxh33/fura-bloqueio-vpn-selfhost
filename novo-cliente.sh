#!/bin/bash
# Gera um certificado de cliente e entrega o .ovpn via croc (código de uso único, sem porta aberta).
set -e

cd "$(dirname "$0")"
source lib/common.sh

if [ -z "$1" ]; then
  echo "Uso: $0 <nome-do-cliente>"
  echo "Exemplo: $0 joao"
  exit 1
fi
CLIENT_NAME="$1"

require_docker
require_container_running

log "gerando certificado pra $CLIENT_NAME..."
docker compose run --rm openvpn easyrsa build-client-full "$CLIENT_NAME" nopass < /dev/null

mkdir -p clientes
docker compose run --rm openvpn ovpn_getclient "$CLIENT_NAME" < /dev/null > "clientes/$CLIENT_NAME.ovpn"
log "arquivo gerado: clientes/$CLIENT_NAME.ovpn"

if command -v croc > /dev/null 2>&1; then
  echo
  log "entregando via croc:"
  echo "  No computador (Windows/Mac/Linux): instale o croc e rode 'croc <código>' — https://github.com/schollz/croc#install"
  echo "  No celular: aponte a câmera pro QR abaixo (abre getcroc.com no navegador, sem instalar nada)"
  echo
  croc send --qr "clientes/$CLIENT_NAME.ovpn"
else
  warn "croc não instalado nesta VPS."
  echo "  Instale com: curl https://getcroc.schollz.com | bash"
  echo "  Ou use o fallback scp a partir do seu computador:"
  echo "    scp usuario@$(hostname -I | awk '{print $1}'):$(pwd)/clientes/$CLIENT_NAME.ovpn ."
fi

echo
echo "Depois: instale o app OpenVPN Connect (openvpn.net/client) e importe o arquivo .ovpn."
