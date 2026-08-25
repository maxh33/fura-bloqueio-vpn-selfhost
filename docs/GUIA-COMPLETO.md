# Guia completo

## Passo a passo detalhado

### 0. Escolha e crie sua VPS

Veja [ESCOLHER-VPS.md](ESCOLHER-VPS.md) — recomendamos Oracle Cloud (grátis pra sempre). Precisa ser Ubuntu 22.04/24.04.

### 0.5. Prepare a VPS (antes de clonar)

Isso varia bastante entre provedores (Oracle, AWS, GCP, Hetzner, etc). O `bootstrap.sh` cuida da maior parte, mas alguns passos precisam acontecer manualmente ANTES dele, na ordem certa:

1. Atualize o sistema:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
2. Adicione sua chave SSH pública ao `authorized_keys` do usuário que você vai usar — o `bootstrap.sh` só desativa login por senha se já achar uma chave configurada, senão pula o hardening de SSH em silêncio (só um aviso):
   ```bash
   mkdir -p ~/.ssh && chmod 700 ~/.ssh
   echo "SUA_CHAVE_PUBLICA_AQUI" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```
   Teste login por chave numa sessão nova antes de continuar (não feche a sessão atual até confirmar).
3. Confira se a VPS já vem com algum firewall pré-configurado fora do `ufw` — comum em imagens oficiais de alguns provedores (ex: Oracle, veja o gotcha em [ESCOLHER-VPS.md](ESCOLHER-VPS.md)):
   ```bash
   sudo iptables -L -n -v
   ```
   Se aparecer regra além do básico (loopback/established/ICMP), resolva o conflito antes de deixar o `bootstrap.sh` configurar o `ufw` por cima — os dois brigando dá firewall imprevisível depois de um reboot.
4. Confirme que as portas 22/TCP e 1194/UDP já estão liberadas no firewall do **provedor** (fora da VPS) — passo 5 de [ESCOLHER-VPS.md](ESCOLHER-VPS.md). Sem isso, o tráfego nem chega na VPS mesmo com `ufw`/`iptables` liberados por dentro.

Feito isso, segue pro passo 1.

### 1. Conecte na VPS e clone este repo

```bash
ssh usuario@SEU_IP
git clone https://github.com/maxh33/fura-bloqueio-vpn-selfhost.git
cd fura-bloqueio-vpn-selfhost
```

### 2. Rode o bootstrap (comando 1)

```bash
sudo ./bootstrap.sh
```

Prepara a VPS inteira sozinho: firewall (`ufw`), proteção contra tentativa de invasão (`fail2ban`), atualizações automáticas de segurança, instala o Docker e sobe o servidor OpenVPN. Leva alguns minutos. No final, pergunta o IP/domínio público da sua VPS.

Não depende de nenhuma IA — é um script bash comum, dá pra ler ele inteiro antes de rodar.

### 3. Gere seu certificado e receba o arquivo (comando 2)

```bash
./novo-cliente.sh SEU_NOME
```

Gera o arquivo `.ovpn` e entrega via [croc](https://github.com/schollz/croc) — aparece um código curto na tela. No seu computador (Windows, Mac ou Linux), instale o croc e digite esse código pra receber o arquivo, sem precisar saber usar scp ou SSH.

### 4. Conecte

Instale o [OpenVPN Connect](https://openvpn.net/client/), importe o arquivo `.ovpn` recebido, aperte conectar.

## Outros comandos

- `./revogar-cliente.sh NOME` — revoga acesso de alguém (perdeu o celular, terminou de usar, etc).
- `./backup-pki.sh` — faz backup da chave-mestra do servidor (guarde fora da VPS — se ela se perder, todo mundo perde acesso e você tem que recriar tudo).

## Decisões conscientes (trade-offs)

- Certificados de cliente são gerados sem senha própria (`nopass`) — mais simples de usar no dia a dia, adequado pra uso pessoal/familiar. Se quiser mais segurança, é possível adicionar senha manualmente (veja a documentação do [kylemanna/openvpn](https://github.com/kylemanna/docker-openvpn)).
- Suporte oficial só pra Ubuntu/Debian.
- `croc` é a única dependência externa deste projeto (não é `apt`/`docker` padrão) — escolhido porque resolve exatamente o problema de "tirar um arquivo da VPS sem deixar porta aberta", sem reinventar isso.

## Deu problema?

Veja [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## Aviso legal

Veja [AVISO-LEGAL.md](AVISO-LEGAL.md).

## Bônus opcional

Quer ajudar mais gente a achar este projeto (ou melhorar seus próprios repositórios no GitHub)? Veja [SEO-OPCIONAL.md](SEO-OPCIONAL.md).
