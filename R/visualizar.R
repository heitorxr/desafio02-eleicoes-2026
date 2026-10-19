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
    desenhar_face(x, y, raio = .42, notas = notas_uf(indices, uf), cex = .9)
    text(x, y - .51, uf, font = 2, cex = .88)
    centros <- rbind(centros, data.frame(uf = uf,
      x = 100 * grconvertX(x, from = "user", to = "ndc"),
      y = 100 * (1 - grconvertY(y, from = "user", to = "ndc")),
      raio = 100 * (grconvertX(x + .45, "user", "ndc") - grconvertX(x, "user", "ndc"))))
  }
  desenhar_gradiente_linear()
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

legenda_pdf <- function(indices, sobrepor = FALSE) {
  preparar_pagina()
  if (sobrepor) par(new = TRUE)
  plot.new()
  plot.window(c(0, 1), c(0, 1))
  linhas <- c("FACES DO VOTO", "Votos de 2026 × posições partidárias de 2022", "Autor: Heitor Cardoso Fernandes",
    "Cor da face       Presidência", "Abertura dos olhos Governo estadual",
    "Abertura do sorriso Senado", "Formato do nariz Deputados federais",
    "Altura das sobrancelhas Estaduais / distritais", "",
    "Nota maior: mais abertura, nariz redondo, sobrancelhas altas.", "Estudo acadêmico, sem posicionamento político.", "",
    "Índice = soma(votos × nota) / votos classificados", "Notas ausentes não recebem zero nem cinco.",
    "? indica atributo indisponível.", "",
    paste0(sum(indices$integro), " de ", nrow(indices), " totais UF/cargo conciliados."),
    "RO recuperado: seção e cadastro; totais conferidos.", "",
    "Fontes: TSE e Bolognesi et al. (medição 2022).", "Disposição: geofacet / br_states_grid1.",
    "Cartograma esquemático: não representa áreas.")
  for (j in seq_along(linhas)) text(.02, .94 - (j - 1) * .039, linhas[j], adj = 0,
                                  cex = if (j == 1) 1.6 else 1.1, font = if (j == 1) 2 else 1)
}

enquadramento_comparacao <- function(cargo) {
  stopifnot(length(cargo) == 1L, cargo %in% names(nomes_cargos))
  raios <- c(presidente = .48, governador = 1.6, senador = 2.5, federal = 2.5, estadual = .48)
  alturas <- c(presidente = .26, governador = -.2, senador = 1.1, federal = .35, estadual = .26)
  list(raio = unname(raios[cargo]), y = unname(alturas[cargo]))
}

desenhar_comparacao_aspecto <- function(indices, cargo) {
  stopifnot(length(cargo) == 1L, cargo %in% names(nomes_cargos))
  preparar_pagina()
  par(cex = 1)
  plot.new()
  plot.window(c(0, 7.5), c(-.8, 1.4), asp = 1, xaxs = "i", yaxs = "i")
  valores <- indices[indices$cargo == cargo & is.finite(indices$nota), ]
  valores <- valores[order(valores$nota, valores$uf), ]
  if (!nrow(valores)) {
    text(3.75, .3, "Sem índices disponíveis para este cargo")
    return(invisible(valores[c("uf", "nota")]))
  }
  exemplos <- valores[c(1, ceiling(nrow(valores) / 2), nrow(valores)), ]
  quadro <- enquadramento_comparacao(cargo)
  for (j in 1:3) {
    centro <- c(1.25, 3.75, 6.25)[j]
    notas <- setNames(rep(5, length(nomes_cargos)), names(nomes_cargos))
    notas[cargo] <- exemplos$nota[j]
    if (cargo == "estadual") {
      rosto <- ponto_complexo(seq(0, 2 * pi, length.out = 121), quadro$raio, centro + 1i * quadro$y)
      polygon(Re(rosto), Im(rosto), col = "#FCFBF8", border = "#263238", lwd = 1.5)
      referencia <- quadro$y + .58 * quadro$raio
      segments(centro - .30, referencia, centro + .30, referencia, col = "#B5BBB6", lty = 3, lwd = 1)
    }
    desenhar_face(x = centro, y = quadro$y, raio = quadro$raio,
                  notas = notas, apenas = cargo)
    text(centro, 1.06, paste0(exemplos$uf[j], " · ",
      formatC(exemplos$nota[j], format = "f", digits = 2, decimal.mark = ",")), font = 2, cex = 1.05)
    text(centro, -.60, c("Menor na amostra", "Mediano na amostra", "Maior na amostra")[j], cex = .82)
  }
  invisible(exemplos[c("uf", "nota")])
}

desenhar_comparacao_narizes <- function(indices) desenhar_comparacao_aspecto(indices, "federal")

gerar_figuras <- function(raiz, indices, grade) {
  saida <- file.path(raiz, "resultados")
  dir.create(file.path(saida, "detalhes"), recursive = TRUE, showWarnings = FALSE)
  exportar_gradiente_angular(file.path(saida, "gradiente_angular.png"))
  svg(file.path(saida, "cartograma_brasil.svg"), width = 7.5, height = 9.5, bg = "#FCFBF8")
  centros <- desenhar_cartograma(indices, grade)
  dev.off()
  write.csv(centros, file.path(saida, "centros_cartograma.csv"), row.names = FALSE)
  png(file.path(saida, "cartograma_brasil.png"), width = 1200, height = 1520, type = "cairo", bg = "#FCFBF8")
  desenhar_cartograma(indices, grade)
  dev.off()
  svg(file.path(saida, "comparacao_narizes.svg"), width = 7.5, height = 2.2, bg = "#FCFBF8")
  exemplos_nariz <- desenhar_comparacao_narizes(indices)
  dev.off()
  write.csv(exemplos_nariz, file.path(saida, "comparacao_narizes.csv"), row.names = FALSE)
  png(file.path(saida, "comparacao_narizes.png"), width = 1080, height = 317, res = 144, type = "cairo", bg = "#FCFBF8")
  desenhar_comparacao_narizes(indices)
  dev.off()
  for (cargo in names(nomes_cargos)) {
    svg(file.path(saida, paste0("comparacao_", cargo, ".svg")), width = 7.5, height = 2.2, bg = "#FCFBF8")
    exemplos <- desenhar_comparacao_aspecto(indices, cargo)
    dev.off()
    write.csv(exemplos, file.path(saida, paste0("comparacao_", cargo, ".csv")), row.names = FALSE)
    png(file.path(saida, paste0("comparacao_", cargo, ".png")), width = 1080, height = 317,
        res = 144, type = "cairo", bg = "#FCFBF8")
    desenhar_comparacao_aspecto(indices, cargo)
    dev.off()
  }
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
  legenda_pdf(indices, sobrepor = TRUE)
  par(fig = c(0, 1, 0, 1), new = FALSE)
  par(oma = c(0, 0, 3, 0))
  painel_velocimetros(indices, "PR")
  mtext("Paraná / PR — índices por cargo", side = 3, outer = TRUE, line = 1,
        cex = 1.5, font = 2)
  dev.off()
  invisible(centros)
}
