# Roteiro de apoio — aproximadamente 5 minutos

Material para os colegas prepararem a apresentação de Visualização de Dados Aplicada/UFPR. **Não é um vídeo produzido ou gravado.** Distribuir os blocos entre os participantes conforme a equipe; ensaiar as falas e usar o tempo restante de cada bloco para apontar os elementos na tela.

| Intervalo | Duração | Assunto |
|---|---:|---|
| 00:00–00:25 | 25 s | Pergunta e proposta |
| 00:25–01:10 | 45 s | Duas fontes, duas datas |
| 01:10–02:05 | 55 s | Média e cobertura |
| 02:05–03:00 | 55 s | Leitura das faces |
| 03:00–03:50 | 50 s | Geometria complexa |
| 03:50–04:35 | 45 s | Organização e reprodução |
| 04:35–05:00 | 25 s | Limites e encerramento |

**Total planejado: 300 segundos.** Os tempos incluem navegação e pausas, não somente leitura.

## 00:00–00:25 — Pergunta e proposta

**Tela:** cartograma completo, na aba Explorar do painel offline; alternativa: `resultados/cartograma_brasil.svg`.

**Fala-base:**
> Como comparar cinco dimensões do voto sem abrir um mapa para cada cargo? Nosso projeto usa faces de Chernoff para reunir cinco índices por unidade da Federação. O desenho lembra o Brasil e inclui os 26 estados e o Distrito Federal. Cada rosto resume dados, não representa a aparência nem a personalidade de ninguém.

## 00:25–01:10 — Duas fontes, duas datas

**Tela:** aba Fontes; destacar o ano da eleição e o ano da medição acadêmica.

**Fala-base:**
> Os votos vêm dos arquivos oficiais do primeiro turno de 2026 do TSE. As notas dos partidos vêm de outra fonte: a Tabela 1 do artigo de Bolognesi, Ribeiro, Codato e Silva, com posições nacionais atribuídas por especialistas e medidas em 2022. São 32 notas publicadas, de zero, esquerda, a dez, direita. A MISSÃO aparece como lacuna, sem nota. Não transferimos notas de partidos antigos para novos. Por isso, o rótulo correto é votos de 2026 combinados com posições partidárias de 2022, e não ideologia atual de cada eleitor.

## 01:10–02:05 — Média e cobertura

**Tela:** detalhe PR/Presidência; apontar o valor e a cobertura separadamente. A fórmula está no guia técnico de apoio, não no painel principal.

**Fala-base:**
> Em cada estado e cargo, multiplicamos a nota de cada partido pelos seus votos e dividimos a soma pelos votos dos partidos classificados. Não é uma média simples entre partidos. No Paraná, para Presidência, o índice é aproximadamente 6,700. Foram classificados 6.406.847 dos 6.585.243 votos válidos oficiais: cobertura de 97,29%. Votos sem nota continuam no total da cobertura, mas não recebem nota inventada na média. Brancos e nulos não entram nesse cálculo. Também conciliamos a soma partidária com o total oficial: das 135 combinações, 133 têm índice disponível. Para deputados federais e estaduais de Rondônia, a fonte está incompleta e o índice permanece ausente.

**Pausa visual:** mostrar RO e a indicação de fonte incompleta; não apresentar esses casos como posições centrais ou apenas como baixa cobertura acadêmica.

## 02:05–03:00 — Leitura das faces

**Tela:** aba Como Ler e retorno a um detalhe de UF, mantendo a legenda visível.

**Fala-base:**
> A cor representa somente a Presidência: vermelho no extremo esquerdo e verde no direito, com escala numérica. A largura dos olhos representa o governo estadual; a largura do sorriso, o Senado; o comprimento do nariz, deputados federais; e o comprimento das sobrancelhas, estaduais ou distritais. As dimensões aumentam com a nota. Os sorrisos mantêm altura e orientação constantes: nenhum lado vira tristeza ou felicidade por posição política. Um ponto de interrogação indica traço indisponível; a cor ausente seria cinza. Os velocímetros ajudam a conferir os valores e a cobertura. E esse é um cartograma esquemático: cada UF tem espaço igual, sem representar sua área ou distância geográfica real.

**Pausa visual:** apontar os cinco canais em uma única face, sem tentar deduzir valores exatos pela aparência.

## 03:00–03:50 — Geometria complexa

**Tela de apoio ao vídeo, separada do painel:** `resultados/contas_complexas.svg`; destacar a projeção horizontal e a vertical. A explicação será feita pelos colegas e não integra a apresentação principal dos gráficos.

**Fala-base:**
> Para transformar a nota em direção, usamos theta igual a pi vezes um menos a nota dividida por dez. Assim, zero aponta à esquerda, cinco para cima e dez à direita. Depois calculamos z igual ao raio vezes a exponencial de i theta. Em R, escrevemos `exp(1i * theta)`: a parte real vira x e a imaginária vira y. No exemplo real do Paraná, com raio 0,9, theta é aproximadamente 1,037 radiano e o ponto fica em x igual a 0,458 e y igual a 0,775. O complexo só organiza coordenadas. Nos velocímetros o raio do ponteiro é 0,78: muda o comprimento, não o índice.

## 03:50–04:35 — Organização e reprodução

**Tela:** árvore dos arquivos e trecho curto do `GUIA_DO_CODIGO.md`; evitar percorrer código linha a linha.

**Fala-base:**
> O trabalho está separado em três módulos R. `dados.R` filtra, soma, calcula a média e aplica a auditoria. `geometria.R` converte notas em cores e coordenadas e desenha os elementos. `visualizar.R` monta o cartograma e os detalhes. O ponto de entrada é `executar.R`: a ação analisar recalcula os índices; figuras exporta os desenhos; e painel empacota o HTML para consulta offline. Python é usado para baixar e empacotar, não para fazer a estatística ou desenhar. O guia traz um exemplo executado com as entradas reais do Paraná. A ação testar reúne os testes R do projeto.

**Demonstração preparada:** preferir mostrar as figuras já geradas e o exemplo curto; não gastar o bloco inteiro reprocessando os arquivos brutos.

## 04:35–05:00 — Limites e encerramento

**Tela:** cartograma e referências; manter os avisos de ano e cobertura legíveis.

**Fala-base:**
> O resultado permite comparar cargos e estados, mas uma média perto de cinco não prova consenso: posições distintas podem se compensar. Não medimos a opinião individual nem atualizamos automaticamente a ideologia dos partidos para 2026. As fontes, as ausências e a cobertura fazem parte da leitura. O painel e o código permitem conferir como cada representação foi construída.

## Checklist antes da gravação pelos colegas

- Abrir o painel local e testar as abas Explorar, Como Ler e Fontes; para explicar os complexos no vídeo, usar separadamente o guia e o diagrama técnico. Se o painel não estiver disponível, usar os SVGs indicados e os documentos locais de referência.
- Manter a mesma escala, o exemplo PR/Presidência com raio 0,9 e as ausências legislativas de RO em todas as falas.
- Usar `dados/referencia/README_ideologia.md` e `README_layout.md` para a referência acadêmica e a grade; o DOI do artigo é `10.1590/1807-0191202531120`. Não inventar links ou notas partidárias.
- Informar o uso de IA como apoio à programação e revisão, conforme registrado no README.
- Definir apresentadores e ensaiar a duração. Acrescentar nomes da equipe e eventual link da gravação apenas quando existirem.
- Tratar `resultados/Figuras_desafio02.pdf` como apoio visual, não como entrega final completa com autoria e link do vídeo. Este roteiro não substitui a gravação.
