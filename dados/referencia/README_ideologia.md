# Ideologia dos partidos: medição acadêmica de 2022, não de 2026

Consulta: 16/10/2026. Foram recuperadas **32 médias partidárias reais da onda 2022**, na Tabela 1 do artigo original de Bolognesi, Ribeiro, Codato e Silva. O CSV tem 33 registros: esses 32 partidos e uma linha adicional `MISSÃO,NA`, explicitamente acrescentada como lacuna a partir da sigla informada pelo usuário no arquivo TSE2026; não é uma observação do survey.[1]

## Fonte exata e acesso

**BOLOGNESI, Bruno; RIBEIRO, Ednaldo; CODATO, Adriano; SILVA, Bruno Fernando da. O desaparecimento do centro ideológico no sistema partidário brasileiro: a classificação mais atualizada dos experts. Opinião Pública, v. 31, e31120, ano editorial 2025. DOI: 10.1590/1807-0191202531120.** O SciELO informa publicação eletrônica em **23/01/2026**. Não confundir essas datas de publicação com o **ano de medição: 2022**.[1]

A fonte numérica é **Tabela 1, “Descritivas da ideologia média dos partidos políticos brasileiros 2018-2022”, coluna `2022 (média)`**. O HTML integral foi efetivamente baixado com HTTP 200 de [1]; suas linhas foram extraídas por programa. A página editorial [2] também foi recuperada com HTTP 200 e confirma autoria e referência. O artigo vincula explicitamente seus dados de apoio ao DOI **10.7910/DVN/MFIXKW** em sua seção de disponibilidade de dados e bibliografia.[1]

A página de citação do Dataverse [3] e sua API pública [4] retornaram **HTTP 403** nesta execução. Portanto, **não foi baixada nem inspecionada a base bruta do Dataverse**, nem seu questionário, dicionário, versão ou microdados. A alternativa pública legítima utilizada foi a **tabela publicada pelos próprios autores**, não uma reconstrução a partir de terceiros. Resultados de busca serviram apenas para localização, não para transcrever notas.[1]

## Escala, coluna escolhida e incerteza

- `nota`: média publicada para 2022, escala **0 = esquerda e 10 = direita**, onze posições. Nenhum valor foi inferido de um rótulo categórico, interpolado ou projetado para 2026.[1]
- `ano_fonte`: 2022 nas 32 observações; vazio na lacuna MISSÃO.
- `fonte`: DOI do artigo e identificação da coluna exata; `sigla_fonte` preserva a grafia original da tabela.
- `nr_2022`: coluna NR 2022, **número de não respondentes**, não tamanho da amostra válida. Não usar como peso dos partidos.[1]
- `cv_2022`: coeficiente de variação publicado, razão desvio-padrão/média, conservado como razão (não convertido para porcentagem). **Não é erro-padrão nem intervalo de confiança**. Valores elevados para médias próximas de zero exigem cautela.[1]
- Ausência: literal `NA`, nunca 0 ou 5. Ler com valores ausentes reconhecidos; MISSÃO não tem ano de observação nem estimativa de incerteza.

A mesma tabela contém `2018 (média)` e uma coluna distinta, `Média ponderada`. **Nenhuma dessas duas foi usada como nota.** Os autores ajustam comparações históricas para fusões, inclusive construindo o valor de 2018 do União Brasil pela média de DEM e PSL. Para evitar confundir observação com harmonização retrospectiva, o CSV entrega somente a coluna observada de 2022. A coluna acadêmica `Média ponderada` descreve ajuste temporal dos autores; **não é ponderação por votos TSE**.[1]

A onda 2022 foi a mais recente localizada e verificável nesta pesquisa. Não foi localizada uma medição acadêmica de 2026 nesta mesma série; o uso com votos de 2026 deve ser rotulado como **“votos de 2026 × posição partidária medida em 2022”**, não como “ideologia medida em 2026”.

## Identidade das legendas e lacunas

A coluna `sigla` contém convenções textuais para cruzamento. Foram expandidas apenas abreviações de nomes da tabela: `SDD -> SOLIDARIEDADE`, `CDD -> CIDADANIA`, `PROGRE -> PP`, `REP -> REPUBLICANOS`, `UNIAO -> UNIÃO`, `PATRI -> PATRIOTA`. As formas originais permanecem em `sigla_fonte`. Isso não significa validação da situação jurídica de cada legenda em 2026. O corpo do artigo explicita “Cidadania (CDD)”; resultados de busca da página oficial TSE [5] confirmaram as formas PP/Progressistas, PODE/Podemos, Republicanos e Solidariedade, mas a página integral TSE retornou 403 e **não foi utilizada como tabela numérica**.[1][5]

**Não há nenhum cruzamento por número partidário.** Em particular, o usuário informou MISSÃO com número 14 em seus dados: a nota histórica do PTB (7,72) **não pode** ser atribuída à MISSÃO. O CSV explicita MISSÃO = NA. A presença de PTB histórico no CSV não significa que PTB seja legenda existente em 2026.

Também **não constam como linhas na tabela-fonte PRD e MOBILIZA**. Manter essas e quaisquer outras siglas não correspondentes como NA até haver documentação suficiente. O artigo menciona a fusão PTB/Patriota no PRD em 2023, mas não publica uma posição do PRD: não calcular média dos predecessores. Tampouco transferir automaticamente PMN para MOBILIZA; se uma continuidade meramente nominal for comprovada em pesquisa posterior, ela deve ser documentada separadamente. Essa lista de lacunas não é uma auditoria exaustiva de todas as siglas presentes no TSE2026.[1]

**UNIÃO tem nota própria observada em 2022 (8,49)** e pode ser usada nessa condição; ela não foi calculada aqui a partir de DEM/PSL. UP também tem nota própria de 2022 (1,63), embora não tenha comparação em 2018. Federações, coligações e sucessores não recebem por herança uma nota construída neste arquivo.[1]

## Contrato de integração e cobertura

1. Ler CSV UTF-8, separador vírgula, decimal ponto, `NA` como ausente.
2. Cruzar os votos pela identidade textual da sigla, conservando uma trilha de aliases, sem números de urna e sem inventar correspondências históricas.
3. Preservar todos os votos no universo da apuração, inclusive partidos sem nota; não descartar registros por junção interna.
4. Em cada UF/cargo, calcular a média ideológica apenas sobre votos com nota: `sum(votos * nota, na.rm=TRUE) / sum(votos dos partidos com nota)`. Se esse denominador for zero, resultado = NA.
5. Mostrar a cobertura separadamente: `votos dos partidos sem nota / votos totais do universo escolhido`. Informar explicitamente se o universo inclui votos nominais e de legenda; não chamar exclusão de nota de voto inválido. Não misturar cargos ou unidades geográficas no denominador.
6. A interpretação é de **posição nacional atribuída ao partido por especialistas**, não posição individual de candidato, eleitor ou diretório estadual. A defasagem até 2026 e as lacunas devem acompanhar a visualização.[1]

A pesquisa de ideologia não leu nem agregou os arquivos eleitorais de 2026. Portanto, **nenhuma porcentagem efetiva de cobertura de votos foi estimada neste arquivo**; isso depende do cruzamento pelo processamento principal.

## Verificação de integridade

Foram comparadas programaticamente, sem tolerância numérica, as 32 notas e as colunas NR/CV do CSV com as linhas da Tabela 1 baixadas da fonte. Também foram verificados unicidade das chaves, limites da escala e ausência de nota para MISSÃO. A linha repetida de cabeçalhos no meio da tabela HTML foi excluída; não é um partido.

## Fontes e estado da recuperação

[1] https://new.scielo.br/j/op/a/hv8GBg9hfCCZLwcWktfYhtC/?ilang=pt_BR&lang=pt — HTML integral recuperado, HTTP 200; Tabela 1 efetivamente extraída. DOI do artigo: 10.1590/1807-0191202531120.

[2] https://periodicos.sbu.unicamp.br/ojs/index.php/op/article/view/8682072 — página editorial recuperada, HTTP 200; metadados e referência.

[3] https://dataverse.harvard.edu/citation?persistentId=doi:10.7910/DVN/MFIXKW — endereço do repositório citado pelo artigo; tentativa direta retornou HTTP 403; não equivale a base baixada.

[4] https://dataverse.harvard.edu/api/datasets/:persistentId/?persistentId=doi:10.7910/DVN/MFIXKW — API pública consultada, HTTP 403; sem inspeção do conteúdo do conjunto.

[5] https://www.tse.jus.br/partidos/partidos-registrados-no-tse — somente metadados/excertos de resultado de busca recuperados; HTTP 403 no acesso direto; não utilizado para posições ideológicas.
