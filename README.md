# Desafio 02 — Faces do voto no Brasil (2026)

Projeto da disciplina Visualização de Dados Aplicada, UFPR. Um cartograma com uma face de Chernoff para cada estado e Distrito Federal e velocímetros separados para presidente, governador, senador, deputado federal e deputado estadual/distrital.

## Decisões confirmadas pelo autor

- Usar resultados oficiais do primeiro turno de 2026, não pesquisas de intenção de voto.
- Representar as 27 unidades da Federação em disposição reconhecível como Brasil.
- Faces com linguagem de emoji; vermelho para esquerda, verde para direita na dimensão presidencial, sempre com escala numérica.
- O professor autorizou ggplot posteriormente ao PDF; priorizar funções geométricas compreensíveis em R.
- Usar números complexos na geometria dos velocímetros, sem explicação matemática no painel ou PDF principal. A explicação fica no apoio técnico para os colegas apresentarem no vídeo.
- Entregar programação e notas breves para os colegas prepararem um vídeo de aproximadamente cinco minutos, não produzir o vídeo agora.
- Cada cargo controla um traço: Presidente = cor; Senador = abertura do sorriso; Governador = abertura dos olhos; Federal = tamanho do nariz triangular (largura e altura, com base ampliada); Estadual/distrital = altura das sobrancelhas, com comprimento fixo. Escala absoluta 0–10 preservada.

## Estado atualizado

Rondônia foi recuperada com votação por seção, cadastro e destinação oficial dos votos: **135/135 totais conciliados**, mantendo a auditoria original e sem alterar votos das outras UFs. Ver `AUDITORIA_RO.md`. O painel possui legenda dos cinco traços imediatamente abaixo do mapa.

## Cuidados metodológicos

Resultados de votação e posicionamento ideológico são fontes diferentes. O TSE fornece votos; a classificação dos partidos deve ter fonte acadêmica, ano explícito e tratamento documentado de partidos sem classificação. Uma média partidária ponderada por votos não mede diretamente a opinião individual nem identifica todo eleitor como pertencente a uma corrente. Não inventar resultados ou posições partidárias ausentes.

As faces são representações multivariadas, não retratos de eleitores. Não associar esquerda/direita a rosto feliz/triste ou a um julgamento de valor.

## Fonte eleitoral inicial

Portal de Dados Abertos do TSE: https://dadosabertos.tse.jus.br/dataset/resultados-2026

A disponibilidade do conjunto e da página oficial de resultados foi verificada em 16/10/2026. A coleta, os dicionários e as auditorias serão registrados no projeto; resultados só serão apresentados após execução real.

## Histórico

Repositório local com commits de etapas efetivas. Não fabricar datas, autoria ou retrospectiva de desenvolvimento. Uso de IA como apoio à programação e revisão será explicitado. Nenhum remoto foi solicitado.
