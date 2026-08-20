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
6. Conecte via SSH e siga o [README principal](../README.md).
