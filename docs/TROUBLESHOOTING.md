# Problemas comuns

**`bootstrap.sh` falhou no meio do caminho**
Rode `./bootstrap.sh` de novo — ele é idempotente, pula o que já foi feito e continua de onde parou.

**Não consigo mais entrar por SSH depois do hardening**
Se você tem acesso ao console web do provedor (AWS/Oracle/GCP oferecem um "console serial"), entre por ali e reverta: `rm /etc/ssh/sshd_config.d/99-hardening.conf && systemctl reload sshd`.

**`docker compose up -d` não sobe o container**
Confira `docker compose logs openvpn`. Erro comum: porta 1194/UDP já em uso, ou o firewall externo do provedor (não o `ufw` da VPS) bloqueando a porta — veja o passo 5 de [ESCOLHER-VPS.md](ESCOLHER-VPS.md).

**Cliente `.ovpn` não conecta**
Confirme que 1194/UDP está liberado tanto no `ufw` da VPS quanto no firewall do provedor. Teste com `docker compose exec openvpn ovpn_listclients` pra ver se o cliente existe.

**`croc` não está instalado na VPS ou no computador de destino**
`curl https://getcroc.schollz.com | bash` (Linux/Mac) ou baixe o binário em https://github.com/schollz/croc/releases (Windows). Ou use o fallback `scp` que o `novo-cliente.sh` imprime.

## Se nada disso resolver: peça ajuda a um agente de IA

Cole o erro completo num agente de linha de comando (se você tiver Claude Code ou Codex CLI instalado):

```
claude "o bootstrap.sh falhou no passo X com este erro: <cole o erro aqui>"
```

Isso é totalmente opcional — o instalador funciona sozinho sem nenhuma IA. É só um atalho pra diagnosticar problema fora do comum.
