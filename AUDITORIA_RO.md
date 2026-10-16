# Rondônia — recuperação verificável dos votos legislativos

O arquivo partidário congelado informa **zero voto nominal válido** para deputados de RO, embora o detalhe oficial registre os totais válidos. Isso era uma lacuna do arquivo utilizado, não ausência de votação.

## Fontes oficiais complementares

- Votação por seção: https://cdn.tse.jus.br/estatistica/sead/odsele/votacao_secao/votacao_secao_2026_RO.zip
- Cadastro de candidatos e partido: https://cdn.tse.jus.br/estatistica/sead/odsele/consulta_cand/consulta_cand_2026.zip
- Destinação dos votos: https://cdn.tse.jus.br/estatistica/sead/odsele/consulta_cand_complementar/consulta_cand_complementar_2026.zip
- Legenda válida e total independente: arquivos originais de votação por partido e detalhe, preservados em `dados/brutos`.

Os ZIPs têm metadados com URL, momento da coleta e SHA-256. Não foi alterada a coleta anterior. Não exportamos CPF, contatos ou outros dados pessoais do cadastro.

## Procedimento

`scripts/reconstruir_ro.py` filtra eleição ordinária de 2026, primeiro turno, RO, cargos 6 e 7. Cruza **CD_ELEICAO + SQ_CANDIDATO** entre voto por seção, cadastro e complemento; confere número de candidatura e cargo. O partido vem de `SG_PARTIDO` do cadastro oficial, não é inferido pelo prefixo do número eleitoral.

Somente votos com `NM_TIPO_DESTINACAO_VOTOS = Válido` entram na soma nominal. Anulados, anulados sub judice e nulos técnicos ficam excluídos e auditados. Somam-se as legendas válidas do arquivo partidário, que não precisam ser reconstruídas.

| Cargo | Nominais válidos recuperados | Legenda válida | Total reconstruído = total oficial |
|---|---:|---:|---:|
| Federal | 904.018 | 28.921 | 932.939 |
| Estadual | 896.601 | 45.420 | 942.021 |

A igualdade dos dois totais é exigida pelo coletor e novamente pelo R. Não há ajuste proporcional nem distribuição de diferenças entre partidos. Candidatos sem destinação interpretável causam falha, não inclusão presumida.

## Rastreabilidade

- `dados/entrada/ro_votos_reconstruidos.csv`: votos por cargo/partido, nominais e legenda separados.
- `dados/entrada/ro_nominais_excluidos.json`: quantidades nominais excluídas por destinação.
- `dados/entrada/votos_partido_uf_original.csv` e `auditoria_eleitoral_original.csv`: fonte anterior, ainda com as duas divergências.
- `dados/entrada/auditoria_eleitoral.csv`: auditoria após substituição somente dos dois cargos de RO; **135/135 totais conciliados**.
- `testes/testar_recuperacao_ro.R`: confere totais, preservação da auditoria original e dos dados das demais UFs.

Para reconstruir do zero: executar a coleta original (`python scripts/baixar_tse.py`), `Rscript executar.R analisar` para produzir os totais de referência, `python scripts/reconstruir_ro.py` e novamente `Rscript executar.R analisar`. Depois, regenerar as figuras e o painel. O código mantém a proteção de índice ausente se alguma fonte futura não conciliar.
