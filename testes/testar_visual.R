# Verificação da entrega usando somente os dados eleitorais reais preservados.
raiz <- normalizePath(getwd(), winslash = "/")
stopifnot(file.exists("R/visualizar.R"))
source("R/geometria.R", encoding = "UTF-8")
source("R/visualizar.R", encoding = "UTF-8")
i <- read.csv("resultados/indices_uf_cargo.csv", fileEncoding = "UTF-8")
g <- read.csv("dados/referencia/layout_ufs.csv", fileEncoding = "UTF-8")
stopifnot(nrow(i) == 135L, nrow(g) == 27L, !anyDuplicated(i[c("uf", "cargo")]),
          all(is.na(i$nota) | (i$nota >= 0 & i$nota <= 10)),
          all(i$cobertura >= 0 & i$cobertura <= 1), sum(is.finite(i$nota)) == 133L)
ro <- notas_uf(i, "RO")
stopifnot(is.na(ro["federal"]), is.na(ro["estadual"]), is.finite(ro["presidente"]))
for (uf in g$uf) {
  n <- notas_uf(i, uf)
  stopifnot(identical(names(n), c("presidente", "governador", "senador", "federal", "estadual")))
  arquivo <- file.path("resultados", "detalhes", paste0(uf, ".svg"))
  stopifnot(file.exists(arquivo), file.info(arquivo)$size > 1000)
}
for (arquivo in c("cartograma_brasil.svg", "cartograma_brasil.png", "contas_complexas.svg", "Figuras_desafio02.pdf")) {
  caminho <- file.path("resultados", arquivo)
  stopifnot(file.exists(caminho), file.info(caminho)$size > 1000)
}
centros <- read.csv("resultados/centros_cartograma.csv")
stopifnot(nrow(centros) == 27L, setequal(centros$uf, g$uf),
          all(centros$x > 0 & centros$x < 100), all(centros$y > 0 & centros$y < 100))
cat("OK: 27 faces, 135 cargos com ausencias preservadas, 27 paineis de velocimetros e figuras finais.\n")
