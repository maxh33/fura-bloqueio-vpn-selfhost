# FuraBloqueio

VPN pessoal fácil de instalar numa VPS grátis. Feito pra quem não é dev, mas sabe mexer em terminal e seguir um passo a passo — pra ter uma conexão sua, fora do controle de terceiros, diante da censura crescente no Brasil.

Sem mensalidade de provedor de VPN, sem log de terceiros: a VPN roda numa VPS que é sua, num free tier (AWS, Oracle Cloud, Google Cloud).

## O que você vai ter no final

Um arquivo `.ovpn` que você importa no app **OpenVPN Connect** (Windows, Mac, Linux, iOS, Android). No dia a dia é só abrir o app e apertar conectar/desconectar.

## Passo a passo

### 0. Escolha e crie sua VPS

Veja [docs/ESCOLHER-VPS.md](docs/ESCOLHER-VPS.md) — recomendamos Oracle Cloud (grátis pra sempre). Precisa ser Ubuntu 22.04/24.04.

### 1. Conecte na VPS e clone este repo

```bash
ssh usuario@SEU_IP
git clone https://github.com/maxh33/fura-bloqueio.git
cd fura-bloqueio
```

### 2. Rode o bootstrap (comando 1)

```bash
sudo ./bootstrap.sh
```

Isso prepara a VPS inteira sozinho: firewall, proteção contra tentativa de invasão, atualizações automáticas de segurança, instala o Docker e sobe o servidor OpenVPN. Leva alguns minutos. No final, pergunta o IP/domínio público da sua VPS.

Não depende de nenhuma IA — é um script bash comum, pode ler ele inteiro antes de rodar.

### 3. Gere seu certificado e receba o arquivo (comando 2)

```bash
./novo-cliente.sh SEU_NOME
```

Isso gera o arquivo `.ovpn` e entrega ele via [croc](https://github.com/schollz/croc) — aparece um código curto na tela. No seu computador (Windows, Mac ou Linux), instale o croc e digite esse código pra receber o arquivo, sem precisar saber usar scp ou SSH.

### 4. Conecte

Instale o [OpenVPN Connect](https://openvpn.net/client/), importe o arquivo `.ovpn` recebido, aperte conectar.

## Outros comandos

- `./revogar-cliente.sh NOME` — revoga acesso de alguém (perdeu o celular, terminou de usar, etc).
- `./backup-pki.sh` — faz backup da chave-mestra do servidor (guarde fora da VPS — se ela se perder, todo mundo perde acesso e você tem que recriar tudo).

## Deu problema?

Veja [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

## Decisões conscientes (trade-offs)

- Certificados de cliente são gerados sem senha própria (`nopass`) — mais simples de usar no dia a dia, adequado pra uso pessoal/familiar. Se quiser mais segurança, é possível adicionar senha manualmente (veja a documentação do [kylemanna/openvpn](https://github.com/kylemanna/docker-openvpn)).
- Suporte oficial só pra Ubuntu/Debian.
- `croc` é a única dependência externa deste projeto (não é `apt`/`docker` padrão) — escolhido porque resolve exatamente o problema de "tirar um arquivo da VPS sem deixar porta aberta", sem reinventar isso.

## Bônus opcional

Quer ajudar mais gente a achar este projeto (ou melhorar seus próprios repositórios no GitHub)? Veja [docs/SEO-OPCIONAL.md](docs/SEO-OPCIONAL.md).

## Licença

MIT
