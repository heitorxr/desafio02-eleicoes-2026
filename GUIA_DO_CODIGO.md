# Guia do código — Faces do voto

**Apoio técnico para os colegas do vídeo.** A explicação de números complexos não aparece no painel nem no PDF principal.

Apoio ao projeto de Visualização de Dados Aplicada/UFPR. O recorte combina **votos do primeiro turno de 2026 × posições nacionais dos partidos medidas em 2022**. Estatística e desenhos usam R base; Python serve à coleta e ao empacotamento do painel, não ao cálculo dos índices.

## 1. Onde estão as operações

| Arquivo | Responsabilidade e comandos principais |
|---|---|
| `R/dados.R` | `ler_csv_zip()` lê colunas selecionadas com `unz()` e `read.csv2()`; `selecionar_primeiro_turno()` filtra o recorte; `somar_votos_partidos()` agrega com `aggregate()`; `calcular_indices()` cruza por sigla com `merge(all.x = TRUE)`; `aplicar_auditoria()` impede divulgar índices não conciliados. |
| `R/geometria.R` | `normalizar_nota()`, `angulo_ponteiro()`, `ponto_complexo()` e `coordenadas_ponteiro()` calculam posições; `cor_politica()` interpola cores; `desenhar_face()` e `desenhar_velocimetro()` desenham com `graphics`. |
| `R/visualizar.R` | `notas_uf()` organiza as cinco notas nomeadas; `desenhar_cartograma()` e `painel_velocimetros()` compõem figuras; `desenhar_contas()` explica o exemplo do PR; `gerar_figuras()` exporta SVG, PNG e PDF. |
| `executar.R` | Carrega os módulos com `source()`, escolhe a ação via `commandArgs()` e coordena as etapas. |

Na raiz do projeto, com `Rscript` disponível no PATH:

```bash
Rscript executar.R analisar
Rscript executar.R figuras
Rscript executar.R painel
Rscript executar.R testar
```

`analisar` requer os ZIPs já coletados em `dados/brutos` e grava entradas agregadas e índices; `figuras` requer esses índices; `painel` empacota os recursos pelo script Python. `tudo` (também a ação padrão) executa análise, figuras e painel, nessa ordem. Os comandos de geração sobrescrevem saídas. Neste computador, pode-se substituir `Rscript` por `"D:/Program Files/R/R-4.5.2/bin/Rscript.exe"`.

## 2. Média ponderada e cobertura são medidas diferentes

Para uma UF e um cargo, sejam `v_p` os votos válidos do partido, `s_p` sua nota e `C` o conjunto de partidos com nota finita:

- **Índice:** `s = soma(v_p * s_p, p em C) / soma(v_p, p em C)`.
- **Cobertura final:** `soma(v_p, p em C) / total de votos válidos oficial da mesma UF/cargo`.

A junção preserva partidos sem nota. Eles não entram no denominador da média, mas seus votos continuam no total oficial usado na cobertura. Denominador classificado zero produz índice `NA`; nenhuma nota ausente recebe zero, cinco ou nota herdada de outro partido. Há 32 notas acadêmicas publicadas e uma linha adicional MISSÃO sem nota.

O total partidário é `QT_VOTOS_NOMINAIS_VALIDOS + QT_TOTAL_VOTOS_LEG_VALIDOS`: a segunda parcela já inclui nominais convertidos, que não são somados novamente. Brancos e nulos ficam na auditoria, fora do índice e do denominador de cobertura. Cobertura não mede comparecimento nem percentual de eleitores.

`calcular_indices()` produz uma cobertura preliminar; **`aplicar_auditoria()` a recalcula sobre `QT_TOTAL_VOTOS_VALIDOS`** e exige conciliação para manter a nota. Agora são **135/135 índices conciliados**. Os dois cargos legislativos de RO foram recuperados pelo voto por seção, cruzado com cadastro e destinação oficial; anulados e nulos técnicos não entram. Ver `AUDITORIA_RO.md` e `scripts/reconstruir_ro.py`. A auditoria original foi preservada.

Exemplo executável no console R, a partir das entradas já preservadas, sem gravar arquivos:

```r
source("R/dados.R", encoding = "UTF-8")
votos <- read.csv("dados/entrada/votos_partido_uf.csv", fileEncoding = "UTF-8")
referencia <- read.csv("dados/referencia/ideologia_partidos.csv", fileEncoding = "UTF-8")
auditoria <- read.csv("dados/entrada/auditoria_eleitoral.csv", fileEncoding = "UTF-8")
indices <- aplicar_auditoria(calcular_indices(votos, referencia), auditoria)
pr <- subset(indices, uf == "PR" & cargo == "presidente")
pr[c("nota", "votos_classificados", "votos_validos", "cobertura")]
```

Resultado real: índice **6,699614**, **6.406.847** votos classificados de **6.585.243** válidos oficiais; cobertura **97,29%**. A coluna `desvio` é a dispersão ponderada das notas partidárias entre votos classificados, não erro-padrão nem incerteza dos especialistas.

## 3. Do índice ao número complexo

Para nota `s` entre 0 e 10, `theta = pi * (1 - s/10)` em radianos. Com centro na origem, `z = raio * exp(1i * theta)`; pela identidade de Euler, `x = Re(z)` e `y = Im(z)`. O complexo representa uma posição, não uma ideologia complexa.

Continuação do exemplo anterior:

```r
source("R/geometria.R", encoding = "UTF-8")
s <- pr$nota
theta <- pi * (1 - s / 10)
z <- 0.9 * exp(1i * theta)
c(theta = theta, x = Re(z), y = Im(z), raio = Mod(z))
p <- coordenadas_ponteiro(s, raio = 0.9)
stopifnot(isTRUE(all.equal(p$x, Re(z))), isTRUE(all.equal(p$y, Im(z))))
```

Saída arredondada: `theta = 1.0368467`, `x = 0.4580434`, `y = 0.7747233`, `raio = 0.9`, em acordo com `resultados/exemplo_complexo.csv`. Esse é o raio da figura `contas_complexas.svg`; o ponteiro desenhado por `desenhar_velocimetro()` usa **0,78**, enquanto `coordenadas_ponteiro()` tem raio padrão **1**. O raio muda o comprimento, não a direção: 0 aponta à esquerda, 5 para cima e 10 à direita.

`ponto_complexo(theta, raio, centro)` recebe centro complexo; `coordenadas_ponteiro(nota, raio, centro)` recebe `c(x, y)` e devolve `list(x, y, z, theta)`. `plot.window(..., asp = 1)` preserva proporções; `polygon()`, `segments()` e `text()` desenham os elementos; `svg()`/`png()`/`cairo_pdf()` abrem dispositivos e `dev.off()` os fecha. `desenhar_face()` usa uma janela existente; `desenhar_velocimetro()` inicia sua própria janela no dispositivo atual.

## 4. Como ler as faces e respeitar os limites

| Variável | Canal visual |
|---|---|
| Presidência | Cor: vermelho em 0/esquerda, tom claro em 5, verde em 10/direita. |
| Governo estadual | Abertura dos olhos: mais fechados ou mais abertos. |
| Senado | Abertura do sorriso: boca mais fechada ou mais aberta. |
| Deputados federais | Comprimento do nariz, com o traçado original anterior ao triângulo. |
| Estaduais/distritais | Altura das sobrancelhas; comprimento fixo. |

Notas maiores abrem mais olhos e boca, alongam o nariz e elevam as sobrancelhas. Somente o nariz foi restaurado ao traçado anterior à primeira versão triangular: linha aberta, sem preenchimento, com largura fixa e comprimento variável. O comprimento das sobrancelhas não muda. A escala absoluta 0–10 é preservada; cada UF tem espaço igual e os velocímetros mostram valores e cobertura.

A média não identifica a opinião individual de eleitores ou candidatos e não transforma uma posição partidária medida em 2022 em medição de 2026. Uma média perto de cinco tampouco demonstra consenso: posições diferentes podem se compensar.

**Referências locais:** `README.md` (fonte TSE), `dados/referencia/README_ideologia.md` (Bolognesi, Ribeiro, Codato e Silva, DOI `10.1590/1807-0191202531120`, Tabela 1/2022), `dados/referencia/README_layout.md` (grade `br_states_grid1`, geofacet) e `notas_geometria.md` (fórmulas).
