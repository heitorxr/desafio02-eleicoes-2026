# Legibilidade da mesma curva: testar também os índices realmente observados.
source("R/geometria.R", encoding = "UTF-8")
stopifnot(exists("coordenadas_nariz", mode = "function"))
indices_nariz <- read.csv("resultados/indices_uf_cargo.csv", fileEncoding = "UTF-8")
federais_nariz <- indices_nariz[indices_nariz$cargo == "federal" & is.finite(indices_nariz$nota), ]
stopifnot(nrow(federais_nariz) == 27L)
menor_nariz <- coordenadas_nariz(min(federais_nariz$nota))
maior_nariz <- coordenadas_nariz(max(federais_nariz$nota))
# Referência explícita: miniatura com raio de 28 px, próxima do painel desktop.
diferenca_pixels <- (diff(range(maior_nariz$x)) - diff(range(menor_nariz$x))) * 28
stopifnot(diferenca_pixels >= 4)
for (nota_nariz in seq(0, 10, by = .5)) {
  p_nariz <- coordenadas_nariz(nota_nariz)
  stopifnot(all(is.finite(unlist(p_nariz))), max(abs(p_nariz$x)) <= .4,
            abs(p_nariz$comprimento - .29) < 1e-12,
            abs(diff(range(p_nariz$y)) - .29) < 1e-12,
            min(p_nariz$y) > -.27, p_nariz$y[1] == .06)
}
# Escala absoluta: a fórmula não depende de mínimo/máximo da amostra.
stopifnot(abs(coordenadas_nariz(0)$largura - .04) < 1e-12,
          abs(coordenadas_nariz(10)$largura - .76) < 1e-12,
          all(is.na(coordenadas_nariz(NA_real_)$x)))
cat(sprintf("OK: narizes reais diferem %.2f px na referência de 28 px de raio; curva e escala preservadas.\n", diferenca_pixels))
