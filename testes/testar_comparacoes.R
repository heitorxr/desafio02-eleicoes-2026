# As cinco demonstrações devem usar o renderer real, em uma janela padronizada.
source("R/geometria.R", encoding = "UTF-8")
source("R/visualizar.R", encoding = "UTF-8")
stopifnot("apenas" %in% names(formals(desenhar_face)),
          exists("desenhar_comparacao_aspecto", mode = "function"))
indices_aspectos <- read.csv("resultados/indices_uf_cargo.csv", fileEncoding = "UTF-8")
prova_aspectos <- tempfile(tmpdir = "C:/Users/heito/AppData/Local/hermes/cache/scratch", fileext = ".svg")
svg(prova_aspectos, width = 7.5, height = 2.2, bg = "#FCFBF8")
tryCatch({
  for (cargo_aspecto in names(nomes_cargos)) {
    exemplos_aspecto <- desenhar_comparacao_aspecto(indices_aspectos, cargo_aspecto)
    reais_aspecto <- indices_aspectos[indices_aspectos$cargo == cargo_aspecto & is.finite(indices_aspectos$nota), ]
    reais_aspecto <- reais_aspecto[order(reais_aspecto$nota, reais_aspecto$uf), ]
    esperado_aspecto <- reais_aspecto[c(1, ceiling(nrow(reais_aspecto) / 2), nrow(reais_aspecto)), c("uf", "nota")]
    stopifnot(identical(exemplos_aspecto, esperado_aspecto))
    plot.new(); plot.window(c(-2, 2), c(-2, 2), asp = 1)
    notas_aspecto <- setNames(rep(5, 5), names(nomes_cargos))
    completo_aspecto <- desenhar_face(notas = notas_aspecto)
    parcial_aspecto <- desenhar_face(notas = notas_aspecto, apenas = cargo_aspecto)
    stopifnot(identical(completo_aspecto, parcial_aspecto))
  }
}, finally = { dev.off(); unlink(prova_aspectos) })
cat("OK: cinco componentes usam a geometria real e mínimo/mediana/máximo de cada cargo.\n")
