# Checkpoint para retomada — 16/10/2026

O autor pediu preservar tudo preventivamente para eventual esgotamento da cota da API. Não presumir acesso ao percentual de créditos nem esperar chegar a zero para salvar.

## Projeto e escopo

- Pasta: `D:/heito/Documentos/Desafio02_Eleicoes_2026`; Git local, branch `main`; nenhum remoto solicitado.
- Enunciado original: `C:/Users/heito/AppData/Local/hermes/attachments/D2.pdf`.
- R: `D:/Program Files/R/R-4.5.2/bin/Rscript.exe`.
- Trabalho: 27 faces de Chernoff num cartograma esquemático do Brasil, cinco cargos separados, estilo emoji neutro; vermelho = esquerda e verde = direita para Presidência.
- Votos oficiais do primeiro turno de 2026 cruzados com posições partidárias acadêmicas medidas em 2022; não chamar isso de opinião individual ou nova medição ideológica de 2026.
- Vídeo de aproximadamente cinco minutos será preparado pelos colegas, não produzir agora. PDF final da disciplina exige nomes, link do vídeo e referências: ainda não é a entrega final.

## Já produzido e executado

- `R/dados.R`: coleta congelada, agregação, índice ponderado, cobertura e auditoria. 135 combinações UF/cargo: 133 conciliadas; RO/federal e RO/estadual são NA por arquivos incompletos. Não imputar posições nem corrigir artificialmente totais.
- `dados/referencia/ideologia_partidos.csv`: 32 notas reais da coluna 2022 da publicação, conferidas no HTML SciELO preservado; MISSÃO sem nota. Fonte e aliases em `README_ideologia.md`.
- `R/geometria.R`: geometria complexa e desenhos em R base. Ângulo `pi * (1 - nota/10)`; coordenadas `Re(z)` e `Im(z)`; ausências não viram centro. Rótulos arredondados sem arredondar ponteiros.
- `R/visualizar.R`: cartograma, 27 painéis de cinco velocímetros e diagrama de contas usando PR/Presidência real. Corrigido encolhimento automático de fonte do `mfrow` e espaçamento dos títulos.
- `resultados/painel.html`: painel offline autossuficiente, com Explorar, Como ler, As contas e Fontes e limites; já aberto na prévia do Hermes.
- `resultados/cartograma_brasil.png` e `.svg`; `resultados/detalhes/*.svg`; `resultados/contas_complexas.svg`; `resultados/Figuras_desafio02.pdf` (material de apoio, não PDF final de entrega).
- `resultados/indices_uf_cargo.csv`: 135 registros reais, cobertura e duas notas indisponíveis preservadas.
- `scripts/montar_painel.py` e `interface/painel.html`: empacotamento e interface; não calculam os índices.
- `GUIA_DO_CODIGO.md` e `ROTEIRO_VIDEO.md`: produzidos por delegação; conferir conteúdo antes de apresentar como revisão final aprovada.

## Verificações efetivamente realizadas

- Testes de dados, geometria, fonte acadêmica e integridade dos ZIPs passaram.
- Teste visual das 27 UFs e artefatos passou.
- Teste de legibilidade de fonte passou após correção.
- QA real em Chrome instalado, com Playwright: 27 seleções, quatro abas, download de CSV idêntico, NA de Rondônia, responsividade em 390 px e nenhum erro JavaScript. Corrigido transbordamento dos controles móveis.
- Capturas em `C:/Users/heito/AppData/Local/hermes/cache/scratch/desafio02/painel_desktop.png`, `painel_rondonia.png`, `painel_contas.png`, `painel_mobile.png`.
- Inspeção visual feita do cartograma, painel desktop e contas. Tipografia dos velocímetros ampliada e seleção da UF ajustada para não cobrir siglas vizinhas.

## Pendências reais para retomada

1. Revisar os dois documentos da delegação e receber seu resultado final, se ainda não entregue ao contexto.
2. Executar reprodução em clone limpo, copiando os ZIPs congelados ignorados pelo Git; comparar índices e figuras. Ainda não realizado.
3. Conferir páginas do PDF de apoio visualmente e verificar contagem; ainda não auditado por ferramenta de PDF nesta etapa.
4. Consolidar referências públicas e fonte específica dos dois votos ao Senado. A pesquisa encontrou uma nota oficial do TRE-SP, mas extração direta retornou HTTP 403; não alegar que seu texto integral foi lido.
5. Atualizar README com comandos finais, conferir `executar.R tudo` (a execução conjunta completa ainda não foi validada), executar suíte completa e registrar commit final da revisão.
6. Mostrar a primeira versão ao autor e perguntar se aprova o mapeamento dos traços antes de refinamentos adicionais. Não inventar novas preferências.

## Comandos úteis

- `"D:/Program Files/R/R-4.5.2/bin/Rscript.exe" executar.R figuras`
- `"D:/Program Files/R/R-4.5.2/bin/Rscript.exe" executar.R testar`
- `python testes/testar_fontes.py`
- `python testes/testar_painel.py`
- `uv run --with playwright python testes/testar_navegador.py`

A automação padrão `browser_exec` falhou ao iniciar por bloqueio do instalador; não tentar reparar o Hermes sem autorização. A alternativa comprovada foi Playwright com o Chrome já instalado e perfil isolado. O TMPDIR real do subprocesso estava apontando para Temp do sistema; o teste foi corrigido para usar explicitamente o cache scratch do Hermes.
