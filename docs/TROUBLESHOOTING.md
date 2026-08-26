*Português | [English](TROUBLESHOOTING.en.md)*

# Problemas comuns

**`bootstrap.sh` falhou no meio do caminho**
Rode `./bootstrap.sh` de novo — ele é idempotente, pula o que já foi feito e continua de onde parou.

**Não consigo mais entrar por SSH depois do hardening**
Se você tem acesso ao console web do provedor (AWS/Oracle/GCP oferecem um "console serial"), entre por ali e reverta: `rm /etc/ssh/sshd_config.d/99-hardening.conf && systemctl reload sshd`.

**Firewall parece "resetar" sozinho depois de um reboot, ou porta 1194 fecha do nada**
Algumas imagens de VPS (a Ubuntu oficial da Oracle é o caso mais comum) já vêm com um `iptables` pré-configurado, independente do `ufw`. Se o `bootstrap.sh` rodou e ativou o `ufw` por cima desse firewall já existente, os dois podem carregar em ordens diferentes no boot e um sobrescrever o outro. Veja o passo 0.5 do [GUIA-COMPLETO.md](GUIA-COMPLETO.md) — resolva isso ANTES de rodar `bootstrap.sh`, não depois.

**`git clone` dá `bash: git: command not found`**
Imagem mínima da VPS não vem com `git`. Instale antes: `sudo apt update && sudo apt install -y git`. Veja o passo 0.5 do [GUIA-COMPLETO.md](GUIA-COMPLETO.md).

**`bootstrap.sh` para no passo 6 com `Failed to reload sshd.service: Unit sshd.service not found`**
Algumas imagens Ubuntu chamam o serviço de `ssh`, não `sshd`. O arquivo de hardening já foi escrito nesse ponto, só falta aplicar. Rode `sudo systemctl reload ssh` e depois `git pull && sudo ./bootstrap.sh` de novo pra continuar do passo 7 em diante.

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
