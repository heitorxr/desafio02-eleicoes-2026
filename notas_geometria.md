# Geometria dos rostos e velocímetros

Material técnico de apoio aos colegas que explicarão a implementação no vídeo; não integra o painel ou o PDF principal.

Módulo independente em R base (`graphics` e `grDevices`), sem pacotes de desenho e sem dados eleitorais. As notas continuam sendo números reais: os complexos são apenas uma representação compacta de **posições no plano**.

## Contas

- Normalização: `t = (nota - minimo)/(maximo - minimo)`. O intervalo padrão é 0–10; valores externos, infinitos e limites degenerados são rejeitados, sem truncamento silencioso. `NA` permanece ausente.
- Ângulo: `theta = pi * (1 - nota/10)`. Assim, 0 aponta à esquerda (`pi`), 5 para cima (`pi/2`) e 10 à direita (`0`). Ângulos em radianos.
- Posição: `z = centro + raio * exp(1i * theta)`, pela identidade `exp(i*theta) = cos(theta) + i*sin(theta)`. Portanto `x = Re(z)` e `y = Im(z)`. O módulo `Mod(z-centro)` é o raio. Alterar o raio não altera o ângulo.
- `coordenadas_ponteiro()` recebe centro real `c(x,y)` e devolve `list(x,y,z,theta)`; para nota ausente todos os elementos são `NA`. `ponto_complexo()` recebe centro complexo e aceita um vetor de ângulos.
- Cores: interpolação linear RGB pela paleta `#BF4D45` → `#F2E9D8` → `#43866A`, nas notas 0, 5 e 10. Ausência usa cinza `#B8B8B8`, nunca a cor central.

## Rostos Chernoff, traços pronunciados e independentes

Para cada nota normalizada `t`, as dimensões abaixo são frações do raio:

| Cargo | Canal | Fórmula |
|---|---|---|
| presidente | preenchimento da face | interpolação RGB |
| governador | semiabertura vertical dos olhos | `0.02 + 0.25*t` |
| senador | abertura vertical do sorriso | `0.01 + 0.22*t` |
| federal | largura do nariz arredondado central | `0.12 + 0.58*t` |
| estadual | altura das sobrancelhas | `0.58 + 0.25*t` |

Olhos e sorriso preservam as fórmulas anteriores; sobrancelhas têm comprimento fixo 0,36 e altura variável. O nariz central usa `x = largura_nariz/2 * sin(theta)*(1-0.35*cos(theta))` e `y = -0.08 + 0.12*cos(theta)`, para theta entre 0 e 2*pi. A base arredondada é mais larga que o topo, com altura fixa 0,24 e preenchimento claro. A largura cresce com a nota, sem projeção lateral. Coordenadas são multiplicadas pelo raio e transladadas ao centro da face. Cada ausência omite somente seu traço; não há inferência de personalidade ou aprovação política.

## Integração

```r
source("R/geometria.R", encoding = "UTF-8")
# O chamador abre o dispositivo gráfico desejado.
# 'notas_reais' deve vir da agregação de dados feita fora deste módulo.
# nomes: presidente, governador, senador, federal, estadual (qualquer ordem).
plot.new()
plot.window(c(-1.2, 1.2), c(-1.2, 1.2), asp = 1)
# desenhar_face(notas = notas_reais)
# desenhar_velocimetro(nota_real, titulo = "Título", subtitulo = "Fonte")
```

`desenhar_face()` acrescenta elementos à janela existente, apropriado para cartogramas. `desenhar_velocimetro()` inicia sua própria janela no dispositivo atual; não abre nem fecha dispositivos. Ambos retornam geometria invisivelmente para inspeção. Parâmetros `col` e `cex` controlam traços/texto; `...` é repassado ao contorno da face ou ao segmento do ponteiro. Para fontes, o chamador pode usar `par(family = "sans")`. Valores ausentes no velocímetro mostram **Sem classificação**, sem ponteiro ou zero substituto.

## Testes e TDD

Executar na raiz do projeto:

```bash
"D:/Program Files/R/R-4.5.2/bin/Rscript.exe" testes/testar_geometria.R
```

Testes cobrem extremos, centro, simetria, módulo complexo, translação, raio, entradas inválidas, ausências e independência dos cinco canais. Campos retornados são exigidos explicitamente: um campo ausente não pode passar por produzir vetor lógico vazio. Todas as entradas são **fixtures matemáticas**, não registros eleitorais.

As provas PNG/PDF são criadas exclusivamente em `C:/Users/heito/AppData/Local/hermes/cache/scratch`, verificadas por assinatura e tamanho, e excluídas automaticamente, inclusive em falha. O teste transforma avisos de desenho em erros. Nenhum pacote externo é necessário.
