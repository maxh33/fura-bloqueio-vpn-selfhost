*Português | [English](ESCOLHER-VPS.en.md)*

# Escolher uma VPS free-tier

| Provedor | Plano | RAM | vCPU | Duração | Observação |
|---|---|---|---|---|---|
| **Oracle Cloud** | Always Free Ampere A1 | até 24GB | até 4 | **pra sempre**, sem cartão de crédito expirando | **Recomendado** — genuinamente grátis, mais RAM de longe. Cadastro pode dar erro de "capacidade indisponível" — tente de novo em outro horário/região se acontecer. |
| **AWS EC2** | t2.micro / t3.micro | 1GB | 1 | 12 meses, depois cobra | RAM baixa aciona o swapfile automático do `bootstrap.sh`. Configure um alarme de faturamento pra não ser cobrado sem querer depois dos 12 meses. |
| **Google Cloud** | e2-micro | 1GB | compartilhado | Sempre grátis, só em algumas regiões dos EUA | Latência do Brasil é real, mas funciona bem pra navegação/texto. |

## Passo a passo básico (qualquer provedor)

1. Crie a conta no provedor escolhido.
2. Crie uma instância/VM com imagem **Ubuntu 22.04 ou 24.04 LTS**.
3. Anote o IP público da instância.
4. Baixe/salve a chave SSH que o provedor gerar — é como você vai acessar a VPS.
5. Libere a porta 1194/UDP no firewall do próprio provedor (grupo de segurança na AWS, "Security List"/"Network Security Group" na Oracle) — além do que o `bootstrap.sh` configura dentro da VPS, o provedor também tem seu próprio firewall externo.
   - **Na Oracle**: Compute → Instances → sua instância → VNIC → Subnet → Security List → **Add Ingress Rules** → Source CIDR `0.0.0.0/0`, IP Protocol **UDP**, Destination Port Range `1194`. A regra de `22/TCP` já costuma vir liberada por padrão.
6. **Gotcha Oracle (o `bootstrap.sh` já resolve sozinho)**: a imagem oficial Ubuntu da Oracle já sobe com um `iptables` pré-configurado (default-deny + SSH liberado, fora do `ufw`). Testado em VPS real: ao instalar o `ufw`, o `apt` remove esse firewall antigo (`iptables-persistent`/`netfilter-persistent`) sozinho, sem passo manual nenhum. Só se algo parecer errado depois do bootstrap (porta fechando sozinha, firewall "resetando"), confira e resolva manualmente:
   ```bash
   sudo iptables -L -n -v
   sudo systemctl disable --now netfilter-persistent 2>/dev/null || true
   sudo iptables -F && sudo iptables -P INPUT ACCEPT
   sudo ufw reload
   ```
7. Conecte via SSH e siga o [README principal](../README.md).

## Quer hospedar fora do Brasil?

Veja as considerações de jurisdição em [AVISO-LEGAL.md](AVISO-LEGAL.md). Ponto prático: a Oracle Cloud trava a região "home" da sua conta na criação — pra hospedar em outro país normalmente precisa criar uma **conta nova** (tenancy nova), não dá pra só trocar a região de uma instância dentro da mesma conta free tier já existente. Mesma limitação costuma valer pra AWS/GCP dependendo do plano.
