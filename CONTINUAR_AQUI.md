# Checkpoint para retomada — 16/10/2026

ESTADO VIGENTE DO NARIZ: modelo único de traçado aberto inspirado no original. Altura e início fixos; nota federal controla largura e arredondamento da ponta: esquerda = fino, direita = arredondado. Ponte cúbica + meia elipse, sem preenchimento. Outros traços e dados preservados. As descrições abaixo registram estilos anteriores, não o estado vigente.

ESTADO VIGENTE: somente o nariz foi restaurado ao traçado original do commit `6872ba2`, imediatamente anterior ao primeiro triângulo. Comprimento `0.13 + 0.18*t`, linha aberta sem preenchimento. Olhos, boca, cor, altura das sobrancelhas e dados atuais preservados. Não restaurar todo o commit antigo. Os estilos de nariz descritos abaixo são históricos e foram substituídos.

Último refinamento estético: nariz ainda triangular e com variação de largura/altura preservada, mas cantos suavizados por curvas quadráticas, preenchimento bege quente e contorno mais fino. Não alterar sobrancelhas ou dados. Esta descrição substitui os estilos históricos abaixo.

Estado mais recente: a pedido do autor, nariz TRIANGULAR restaurado, com base ampliada (`0.06 + 0.64*t`) e altura também variável (`0.08 + 0.26*t`), preenchimento claro e contorno reforçado. Sobrancelhas continuam variando na altura. Dados preservados.

Correção mais recente: nariz substituído por forma CENTRAL, simétrica e arredondada, com preenchimento claro e largura variável (`0.12 + 0.58*t`), altura fixa 0,24. A projeção lateral foi removida. Sobrancelhas continuam variando em altura. Dados não alterados.

Última correção aplicada imediatamente: Estadual/distrital controla ALTURA das sobrancelhas (comprimento fixo 0,36); Federal controla extensão HORIZONTAL do nariz (`0.04 + 0.62*t`), com ponta marcada. Dados e índices comprovadamente inalterados. Figuras/legendas regeneradas e testes R, painel, PDF e navegador aprovados; inspeção visual feita. Temporizador da conversa cancelado por antecipação do pedido; cron separado permanece pausado.

O autor pediu preservar tudo preventivamente para eventual esgotamento da cota da API. Não presumir acesso ao percentual de créditos nem esperar chegar a zero para salvar.

## Última atualização — Rondônia recuperada e traços reforçados

`AUDITORIA_RO.md` e `scripts/reconstruir_ro.py` documentam o cruzamento de votação por seção, cadastro e destinação oficial. Recuperados 904.018 nominais federais e 896.601 estaduais; somadas as legendas, os totais são exatamente 932.939 e 942.021. Anulados/sub judice/nulos técnicos excluídos. Auditoria original preservada. **135/135 índices conciliados**, demais UFs inalteradas.

Faces maiores, olhos com abertura variável, sorriso com abertura variável, nariz triangular maior e sobrancelhas reforçadas. Escala absoluta 0–10 preservada. Legenda dos cinco traços adicionada abaixo do mapa. Código completo `executar.R tudo` e todas as suítes R, fontes/hashes, painel, PDF e navegador passaram. Inspeção visual confirmou as novas faces e legenda.

## Projeto e escopo

- Pasta: `D:/heito/Documentos/Desafio02_Eleicoes_2026`; Git local, branch `main`; nenhum remoto solicitado.
- Enunciado original: `C:/Users/heito/AppData/Local/hermes/attachments/D2.pdf`.
- R: `D:/Program Files/R/R-4.5.2/bin/Rscript.exe`.
- Trabalho: 27 faces de Chernoff num cartograma esquemático do Brasil. Presidente/cor, Senador/abertura do sorriso, Governador/abertura dos olhos, Federal/tamanho do nariz, Estadual-distrital/comprimento das sobrancelhas. Sem inversão do sorriso ou juízo político.
- Votos oficiais do primeiro turno de 2026 cruzados com posições partidárias acadêmicas medidas em 2022; não chamar isso de opinião individual ou nova medição ideológica de 2026.
- Vídeo de aproximadamente cinco minutos será preparado pelos colegas, não produzir agora. PDF final da disciplina exige nomes, link do vídeo e referências: ainda não é a entrega final.

## Já produzido e executado

- `R/dados.R`: coleta congelada, agregação, índice ponderado, cobertura e auditoria. As 135 combinações conciliam após recuperação dos dois cargos de RO; auditoria original mantida em `auditoria_eleitoral_original.csv`. Não imputar posições nem ajustar artificialmente totais.
- `dados/referencia/ideologia_partidos.csv`: 32 notas reais da coluna 2022 da publicação, conferidas no HTML SciELO preservado; MISSÃO sem nota. Fonte e aliases em `README_ideologia.md`.
- `R/geometria.R`: geometria complexa e desenhos em R base. Ângulo `pi * (1 - nota/10)`; coordenadas `Re(z)` e `Im(z)`; ausências não viram centro. Rótulos arredondados sem arredondar ponteiros.
- `R/visualizar.R`: cartograma, 27 painéis de cinco velocímetros e diagrama de contas usando PR/Presidência real. Corrigido encolhimento automático de fonte do `mfrow` e espaçamento dos títulos.
- `resultados/painel.html`: painel offline autossuficiente, com Explorar, Como ler e Fontes e limites. Por correção do autor, explicação dos complexos fica somente no apoio técnico ao vídeo, não no painel ou PDF principal. O PDF de apoio mostra mapa e velocímetros, não a explicação matemática.
- `resultados/cartograma_brasil.png` e `.svg`; `resultados/detalhes/*.svg`; `resultados/contas_complexas.svg`; `resultados/Figuras_desafio02.pdf` (material de apoio, não PDF final de entrega).
- `resultados/indices_uf_cargo.csv`: 135 registros reais, todos com índice e cobertura; RO recuperado por fontes oficiais complementares.
- `scripts/montar_painel.py` e `interface/painel.html`: empacotamento e interface; não calculam os índices.
- `GUIA_DO_CODIGO.md` e `ROTEIRO_VIDEO.md`: delegação concluída e documentos lidos pelo agente principal. Corrigida a definição de cobertura no item 5 do README da referência acadêmica para coincidir com o código; nenhum dado ou gráfico foi alterado nessa correção documental.

## Verificações efetivamente realizadas

- Testes de dados, geometria, fonte acadêmica e integridade dos ZIPs passaram.
- Teste visual das 27 UFs e artefatos passou.
- Teste de legibilidade de fonte passou após correção.
- QA real em Chrome/Playwright: 27 seleções, três abas, CSV idêntico, índices recuperados de RO, legenda abaixo do mapa, tela de 390 px sem transbordamento e nenhum erro JavaScript.
- Capturas em `C:/Users/heito/AppData/Local/hermes/cache/scratch/desafio02/painel_desktop.png`, `painel_rondonia.png`, `painel_contas.png`, `painel_mobile.png`.
- Inspeção visual feita do cartograma, painel desktop e contas. Tipografia dos velocímetros ampliada e seleção da UF ajustada para não cobrir siglas vizinhas.

## Pendências reais para retomada

1. Guia e roteiro recebidos e lidos; duração planejada do roteiro conferida por cálculo. Falta a revisão final conjunta após as verificações abaixo.
2. Executar reprodução em clone limpo, copiando os ZIPs congelados ignorados pelo Git; comparar índices e figuras. Ainda não realizado.
3. PDF principal conferido automaticamente: duas páginas, mapa e legenda juntos, cinco velocímetros na segunda página e nenhuma explicação dos complexos. Corrigida quebra indevida de página na sobreposição da legenda; falta inspeção visual detalhada das páginas.
4. Consolidar referências públicas e fonte específica dos dois votos ao Senado. A pesquisa encontrou uma nota oficial do TRE-SP, mas extração direta retornou HTTP 403; não alegar que seu texto integral foi lido.
5. `executar.R tudo` e suíte completa validados com sucesso após recuperação de RO e novos traços. README e guias atualizados; preservar checkpoints em Git.
6. Mostrar a primeira versão ao autor e perguntar se aprova o mapeamento dos traços antes de refinamentos adicionais. Não inventar novas preferências.

## Comandos úteis

- `"D:/Program Files/R/R-4.5.2/bin/Rscript.exe" executar.R figuras`
- `"D:/Program Files/R/R-4.5.2/bin/Rscript.exe" executar.R testar`
- `python testes/testar_fontes.py`
- `python testes/testar_painel.py`
- `uv run --with playwright python testes/testar_navegador.py`

A automação padrão `browser_exec` falhou ao iniciar por bloqueio do instalador; não tentar reparar o Hermes sem autorização. A alternativa comprovada foi Playwright com o Chrome já instalado e perfil isolado. O TMPDIR real do subprocesso estava apontando para Temp do sistema; o teste foi corrigido para usar explicitamente o cache scratch do Hermes.
