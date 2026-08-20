# Opcional: ajudar mais gente a achar este projeto

Se você deu fork neste repo (ou quer melhorar o SEO de qualquer repositório seu no GitHub), existe uma ferramenta separada pra isso: [repo-seo-toolkit](https://github.com/maxh33/repo-seo-toolkit).

```bash
git clone https://github.com/maxh33/repo-seo-toolkit
cd repo-seo-toolkit
gh auth login
python -m repo_seo suggest <seu-usuario>/<seu-fork>
```

Ela sugere topics e descrição pro GitHub com base no conteúdo do repositório. Revise a sugestão e aplique com `python -m repo_seo apply` (veja o README daquele projeto). Totalmente opcional — não tem nada a ver com o funcionamento da VPN.
