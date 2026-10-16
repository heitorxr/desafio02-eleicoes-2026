# Composição visual: cartograma e 27 painéis de velocímetros; somente R base.
nomes_cargos <- c(presidente = "Presidência", governador = "Governo estadual", senador = "Senado",
                  federal = "Deputados federais", estadual = "Estaduais / distritais")

notas_uf <- function(indices, uf) {
  x <- indices[indices$uf == uf, ]
  notas <- x$nota[match(names(nomes_cargos), x$cargo)]
  setNames(notas, names(nomes_cargos))
}

preparar_pagina <- function() {
  par(mar = c(0, 0, 0, 0), family = "Arial", fg = "#263238", bg = "#FCFBF8")
}

# Posições aproximadas: cada UF ocupa uma célula de igual tamanho, não sua área real.
desenhar_cartograma <- function(indices, grade) {
  preparar_pagina()
  plot.new()
  plot.window(c(.4, 6.6), c(-.7, 8.85), asp = 1, xaxs = "i", yaxs = "i")
  text(.6, 8.65, "BRASIL · PRIMEIRO TURNO DE 2026", adj = 0, cex = .82, font = 2)
  centros <- data.frame()
  for (j in seq_len(nrow(grade))) {
    x <- grade$coluna[j]
    y <- 9 - grade$linha[j]
    uf <- grade$uf[j]
    desenhar_face(x, y, raio = .37, notas = notas_uf(indices, uf), cex = .9)
    text(x, y - .51, uf, font = 2, cex = .88)
    centros <- rbind(centros, data.frame(uf = uf,
      x = 100 * grconvertX(x, from = "user", to = "ndc"),
      y = 100 * (1 - grconvertY(y, from = "user", to = "ndc")),
      raio = 100 * (grconvertX(x + .45, "user", "ndc") - grconvertX(x, "user", "ndc"))))
  }
  escala <- seq(0, 10, length.out = 101)
  for (j in 1:100) rect(.9 + (j - 1) * .045, -.02, .9 + j * .045, .13,
                        col = cor_politica(mean(escala[c(j, j + 1)])), border = NA)
  text(c(.9, 3.15, 5.4), -.23, c("0 · esquerda", "5", "10 · direita"), cex = .72)
  text(3.15, -.53, "Cor: Presidência · referência partidária de 2022", cex = .70)
  invisible(centros)
}

painel_velocimetros <- function(indices, uf) {
  preparar_pagina()
  par(mfrow = c(3, 2), mar = c(.5, .5, .5, .5), cex = 1)
  for (cargo in names(nomes_cargos)) {
    x <- indices[indices$uf == uf & indices$cargo == cargo, ]
    subtitulo <- if (!x$integro) "Fonte eleitoral incompleta" else
      paste0("Cobertura: ", formatC(100 * x$cobertura, digits = 1, format = "f", decimal.mark = ","), "%")
    desenhar_velocimetro(x$nota, titulo = nomes_cargos[[cargo]], subtitulo = subtitulo, cex = 1.08)
  }
  plot.new()
  plot.window(c(0, 1), c(0, 1))
  text(.08, .87, "COMO LER", adj = 0, font = 2, cex = .9)
  text(.08, .68, "0: esquerda   ·   10: direita", adj = 0, cex = .78)
  text(.08, .49, "Só votos de partidos com nota.", adj = 0, cex = .78)
  text(.08, .30, "Cobertura não é comparecimento.", adj = 0, cex = .78)
  text(.08, .11, "Centro da escala não é consenso.", adj = 0, cex = .78)
}

# Triângulo de projeções do ponteiro, usando a nota presidencial efetiva do PR.
desenhar_contas <- function(nota) {
  preparar_pagina()
  plot.new()
  plot.window(c(-1.35, 1.45), c(-.40, 1.48), asp = 1)
  arco <- ponto_complexo(seq(0, pi, length.out = 181))
  lines(Re(arco), Im(arco), col = "#C7CBC8", lwd = 2)
  abline(h = 0, v = 0, col = "#E2E1DC", lwd = .7)
  p <- coordenadas_ponteiro(nota, raio = .9)
  segments(0, 0, p$x, p$y, col = "#30586A", lwd = 3)
  segments(p$x, 0, p$x, p$y, col = "#7B868C", lty = 2)
  segments(0, 0, p$x, 0, col = "#7B868C", lty = 2)
  points(p$x, p$y, pch = 21, bg = "#30586A", col = "#30586A", cex = 1.1)
  angulo <- ponto_complexo(seq(0, p$theta, length.out = 60), .25)
  lines(Re(angulo), Im(angulo), col = "#BF4D45", lwd = 2)
  text(.29, .13, "θ", col = "#BF4D45", cex = 1.4)
  text(p$x / 2, -.13, paste0("Re(z) = ", formatC(p$x, digits = 3, format = "f")), cex = .85)
  text(p$x + .13, p$y / 2, paste0("Im(z) = ", formatC(p$y, digits = 3, format = "f")), adj = 0, cex = .85)
  text(c(-1, 0, 1), c(-.30, -.30, -.30), c("0 · esquerda", "5", "10 · direita"), cex = .8)
  text(0, 1.35, "Um número complexo vira uma posição", font = 2, cex = 1.2)
  text(0, 1.17, paste0("Exemplo real: PR / Presidência · índice ", formatC(nota, digits = 3, format = "f")), cex = .85)
  invisible(data.frame(nota = nota, raio = .9, theta = p$theta, x = p$x, y = p$y))
}

legenda_pdf <- function(indices) {
  preparar_pagina()
  plot.new()
  plot.window(c(0, 1), c(0, 1))
  linhas <- c("FACES DO VOTO", "Votos de 2026 × posições partidárias de 2022", "",
    "Cor da face       Presidência", "Largura dos olhos Governo estadual",
    "Distância dos olhos Senado", "Comprimento do nariz Deputados federais",
    "Largura da boca    Estaduais / distritais", "",
    "Mais à direita = traço mais largo ou longo.", "A expressão permanece neutra; não há bom ou ruim.", "",
    "Índice = soma(votos × nota) / votos classificados", "Notas ausentes não recebem zero nem cinco.",
    "? indica atributo indisponível.", "",
    paste0(sum(indices$integro), " de ", nrow(indices), " totais UF/cargo conciliados."),
    "RO: dados legislativos incompletos nos arquivos.", "",
    "Fontes: TSE e Bolognesi et al. (medição 2022).", "Disposição: geofacet / br_states_grid1.",
    "Cartograma esquemático: não representa áreas.")
  for (j in seq_along(linhas)) text(.02, .94 - (j - 1) * .039, linhas[j], adj = 0,
                                  cex = if (j == 1) 1.6 else 1.1, font = if (j == 1) 2 else 1)
}

gerar_figuras <- function(raiz, indices, grade) {
  saida <- file.path(raiz, "resultados")
  dir.create(file.path(saida, "detalhes"), recursive = TRUE, showWarnings = FALSE)
  svg(file.path(saida, "cartograma_brasil.svg"), width = 7.5, height = 9.5, bg = "#FCFBF8")
  centros <- desenhar_cartograma(indices, grade)
  dev.off()
  write.csv(centros, file.path(saida, "centros_cartograma.csv"), row.names = FALSE)
  png(file.path(saida, "cartograma_brasil.png"), width = 1200, height = 1520, type = "cairo", bg = "#FCFBF8")
  desenhar_cartograma(indices, grade)
  dev.off()
  for (uf in grade$uf) {
    svg(file.path(saida, "detalhes", paste0(uf, ".svg")), width = 8, height = 8.1,
        pointsize = 16, bg = "#FCFBF8")
    painel_velocimetros(indices, uf)
    dev.off()
  }
  nota_exemplo <- notas_uf(indices, "PR")[["presidente"]]
  svg(file.path(saida, "contas_complexas.svg"), width = 9, height = 6, bg = "#FCFBF8")
  exemplo <- desenhar_contas(nota_exemplo)
  dev.off()
  write.csv(exemplo, file.path(saida, "exemplo_complexo.csv"), row.names = FALSE)
  cairo_pdf(file.path(saida, "Figuras_desafio02.pdf"), width = 16, height = 9, family = "Arial", onefile = TRUE)
  par(fig = c(0, .55, 0, 1))
  desenhar_cartograma(indices, grade)
  par(fig = c(.56, 1, 0, 1), new = TRUE)
  legenda_pdf(indices)
  par(fig = c(0, 1, 0, 1), new = FALSE)
  desenhar_contas(nota_exemplo)
  dev.off()
  invisible(centros)
}
