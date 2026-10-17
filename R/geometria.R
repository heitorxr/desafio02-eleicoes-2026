# Geometria em R base; números complexos representam posições, não ideologia.
normalizar_nota <- function(x, minimo = 0, maximo = 10) {
  if (is.logical(x) && all(is.na(x))) x <- as.numeric(x)
  if (length(minimo) != 1L || length(maximo) != 1L ||
      !is.finite(minimo) || !is.finite(maximo) || maximo <= minimo)
    stop("A escala deve ter limites finitos e máximo maior que mínimo.")
  if (!is.numeric(x) || any(!is.na(x) & (!is.finite(x) | x < minimo | x > maximo)))
    stop("Notas devem ser numéricas, dentro da escala, ou NA.")
  (x - minimo) / (maximo - minimo)
}

ponto_complexo <- function(theta, raio = 1, centro = 0 + 0i) {
  if (!is.numeric(raio) || length(raio) != 1L || !is.finite(raio) || raio < 0 ||
      length(centro) != 1L || !is.finite(centro))
    stop("Raio não negativo e centro finito são obrigatórios.")
  centro + raio * exp(1i * theta)
}

cor_politica <- function(nota) {
  proporcao <- normalizar_nota(nota)
  cores <- rep("#B8B8B8", length(nota))
  presentes <- !is.na(proporcao)
  rampa <- grDevices::colorRamp(c("#BF4D45", "#F2E9D8", "#43866A"))
  if (any(presentes)) {
    rgb <- rampa(proporcao[presentes])
    cores[presentes] <- grDevices::rgb(rgb[, 1], rgb[, 2], rgb[, 3], maxColorValue = 255)
  }
  cores
}

angulo_ponteiro <- function(nota) pi * (1 - normalizar_nota(nota))

coordenadas_ponteiro <- function(nota, raio = 1, centro = c(0, 0)) {
  if (length(nota) != 1L || !is.numeric(centro) || length(centro) != 2L ||
      any(!is.finite(centro))) stop("Informe uma nota e um centro (x, y) finito.")
  theta <- angulo_ponteiro(nota)
  z <- ponto_complexo(theta, raio, centro[1] + 1i * centro[2])
  list(x = Re(z), y = Im(z), z = z, theta = theta)
}

# Cria somente a janela do velocímetro, no dispositivo já aberto pelo chamador.
desenhar_velocimetro <- function(nota, titulo = "", subtitulo = "",
                                col = "#263238", cex = 1, ...) {
  ponteiro <- coordenadas_ponteiro(nota, raio = .78)
  graphics::plot.new()
  graphics::plot.window(c(-1.22, 1.22), c(-.30, 1.63), asp = 1)
  intervalos <- seq(0, 10, length.out = 121)
  for (j in seq_len(length(intervalos) - 1L)) {
    limites <- angulo_ponteiro(intervalos[c(j, j + 1L)])
    fora <- ponto_complexo(limites)
    dentro <- ponto_complexo(rev(limites), .84)
    cor <- cor_politica(mean(intervalos[c(j, j + 1L)]))
    graphics::polygon(Re(c(fora, dentro)), Im(c(fora, dentro)),
                      col = cor, border = cor, lwd = .3)
  }
  marcas <- ponto_complexo(angulo_ponteiro(seq(0, 10, 2)), 1.12)
  graphics::text(Re(marcas), Im(marcas), labels = seq(0, 10, 2), col = col, cex = .8 * cex)
  if (is.na(nota)) {
    graphics::text(0, .38, "Sem classificação", col = col, cex = .85 * cex)
  } else {
    graphics::segments(0, 0, ponteiro$x, ponteiro$y, col = col, lwd = 2.5, ...)
    graphics::points(0, 0, pch = 21, bg = col, col = col, cex = .9 * cex)
    graphics::text(0, -.18, formatC(nota, digits = 1, format = "f", decimal.mark = ","),
                   col = col, cex = cex)
  }
  graphics::text(0, 1.50, titulo, col = col, font = 2, cex = cex)
  graphics::text(0, 1.29, subtitulo, col = col, cex = .7 * cex)
  invisible(ponteiro)
}

# Desenha sobre uma janela existente (asp = 1 preserva as proporções).
desenhar_face <- function(x = 0, y = 0, raio = 1, notas,
                          col = "#263238", cex = 1, ...) {
  cargos <- c("presidente", "governador", "senador", "federal", "estadual")
  if (is.logical(notas) && all(is.na(notas))) storage.mode(notas) <- "double"
  if (!is.numeric(notas) || length(notas) != 5L ||
      is.null(names(notas)) || !setequal(names(notas), cargos))
    stop("Forneça exatamente as cinco notas nomeadas por cargo.")
  if (length(x) != 1L || length(y) != 1L || !is.finite(x) || !is.finite(y) ||
      length(raio) != 1L || !is.finite(raio) || raio <= 0)
    stop("Centro finito e raio positivo são obrigatórios.")
  t <- normalizar_nota(notas[cargos])
  largura_olho <- .23
  abertura_olho <- .02 + .25 * t["governador"]
  distancia_olhos <- .34
  comprimento_nariz <- .04 + .62 * t["federal"]
  largura_boca <- .76
  abertura_boca <- .01 + .22 * t["senador"]
  comprimento_sobrancelha <- .36
  altura_sobrancelha <- .58 + .25 * t["estadual"]
  contorno <- ponto_complexo(seq(0, 2 * pi, length.out = 121), raio, x + 1i * y)
  graphics::polygon(Re(contorno), Im(contorno), col = cor_politica(notas["presidente"]),
                    border = col, lwd = 1.5, ...)
  # Ausência omite o traço dependente: nunca substitui uma nota pelo centro.
  if (is.na(t["presidente"])) graphics::text(x, y + .88 * raio, "?", cex = .7 * cex, col = col)
  if (is.na(abertura_olho)) {
    graphics::text(x, y + .27 * raio, "?", cex = .8 * cex, col = col)
  } else {
    for (lado in c(-1, 1)) {
      olho <- ponto_complexo(seq(0, 2 * pi, length.out = 41))
      graphics::polygon(x + raio * (lado * distancia_olhos + largura_olho * Re(olho)),
                        y + raio * (.27 + abertura_olho * Im(olho)),
                        col = "#FFFFFF", border = col, lwd = 1.8)
      graphics::polygon(x + raio * (lado * distancia_olhos + .065 * Re(olho)),
                        y + raio * (.27 + min(.085, .65 * abertura_olho) * Im(olho)),
                        col = col, border = NA)
    }
  }
  # Projeção horizontal: comprimento diretamente visível, com ponta marcada.
  nariz <- list(x = x + raio * c(0, 0, comprimento_nariz),
                y = y + raio * c(.12, -.10, -.10))
  if (is.na(comprimento_nariz)) graphics::text(x, y - .08 * raio, "?", cex = .7 * cex, col = col)
  else {
    graphics::lines(nariz$x, nariz$y, col = col, lwd = 2.8, lend = "round")
    graphics::points(nariz$x[3], nariz$y[3], pch = 16, col = col, cex = .35 * cex)
  }
  if (is.na(altura_sobrancelha)) {
    graphics::text(x, y + .67 * raio, "?", cex = .7 * cex, col = col)
  } else {
    for (lado in c(-1, 1)) graphics::segments(
      x + raio * (lado * distancia_olhos - comprimento_sobrancelha / 2), y + altura_sobrancelha * raio,
      x + raio * (lado * distancia_olhos + comprimento_sobrancelha / 2), y + altura_sobrancelha * raio,
      col = col, lwd = 2.8)
  }
  u <- seq(-1, 1, length.out = 61)
  # Senado controla quanto o sorriso se abre, sem inversão para uma expressão triste.
  superior <- -.35 + .08 * u^2
  inferior <- superior - abertura_boca * (1 - u^2)
  boca <- list(x = x + raio * c(u, rev(u)) * largura_boca / 2,
               y = y + raio * c(superior, rev(inferior)))
  if (is.na(abertura_boca)) graphics::text(x, y - .40 * raio, "?", cex = .7 * cex, col = col)
  else graphics::polygon(boca$x, boca$y, col = col, border = col, lwd = 1.6)
  invisible(list(notas = t, largura_olho = largura_olho, abertura_olho = abertura_olho,
                 abertura_boca = abertura_boca, distancia_olhos = distancia_olhos,
                 comprimento_nariz = comprimento_nariz, largura_boca = largura_boca,
                 comprimento_sobrancelha = comprimento_sobrancelha,
                 altura_sobrancelha = altura_sobrancelha, nariz = nariz, boca = boca))
}
