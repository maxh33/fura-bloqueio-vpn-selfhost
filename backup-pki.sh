#!/bin/bash
# Faz backup do volume openvpn-data (contém a CA — perder isso derruba todos os clientes).
# Rode manualmente de vez em quando, ou agende via cron se quiser.
set -e

cd "$(dirname "$0")"
source lib/common.sh

require_docker

mkdir -p backups
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
FILE="backups/openvpn-data-$TIMESTAMP.tar.gz"

log "fazendo backup do volume openvpn-data..."
docker run --rm \
  -v fura-bloqueio_openvpn-data:/source:ro \
  -v "$(pwd)/backups":/backup \
  alpine tar -czf "/backup/openvpn-data-$TIMESTAMP.tar.gz" -C /source .

log "backup salvo em $FILE"
echo "Copie esse arquivo pra fora da VPS de vez em quando (seu computador, outro storage) —"
echo "se a VPS morrer sem esse backup, você perde a CA e precisa recriar TODOS os clientes."
