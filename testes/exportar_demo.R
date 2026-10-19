# Referência de teste: casos artificiais, sem relação com resultados eleitorais.
# Executar da raiz: Rscript testes/exportar_demo.R <referencia.json> [paleta.json] [faixa.json]
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) >= 1L)
source("R/geometria.R")
json <- function(x) {
  if (is.list(x)) {
    itens <- vapply(x, json, character(1))
    if (!is.null(names(x))) {
      return(paste0("{", paste(paste0(encodeString(names(x), quote = '"'), ":", itens), collapse = ","), "}"))
    }
    return(paste0("[", paste(itens, collapse = ","), "]"))
  }
  itens <- if (is.character(x)) encodeString(x, quote = '"') else
    vapply(x, function(v) if (is.na(v)) "null" else format(v, digits = 17, scientific = TRUE, trim = TRUE), character(1))
  if (length(itens) == 1L) itens else paste0("[", paste(itens, collapse = ","), "]")
}
cargos <- c("presidente", "governador", "senador", "federal", "estadual")
casos <- lapply(c(0, .1, 2.7, 5, 7.3, 9.9, 10), function(n) setNames(rep(n, 5), cargos))
for (cargo in cargos) {
  n <- setNames(rep(5, 5), cargos)
  n[cargo] <- 10
  casos[[length(casos) + 1L]] <- n
}
casos[[length(casos) + 1L]] <- setNames(c(1.2, 8.3, 2.6, 9.4, .7), cargos)
svg(file.path(dirname(args[1]), "referencia_demo.svg"), width = 4, height = 4)
plot.new()
plot.window(c(-1.2, 1.2), c(-1.2, 1.2), asp = 1)
referencia <- lapply(casos, function(notas) {
  g <- desenhar_face(notas = notas)
  p <- coordenadas_ponteiro(notas[["presidente"]], raio = .78)
  list(notas = as.list(notas), cor = unname(cor_politica(notas[["presidente"]])),
       parametros = g[setdiff(names(g), c("notas", "nariz", "boca"))],
       nariz = g$nariz, boca = g$boca, ponteiro = list(x = p$x, y = p$y))
})
invisible(dev.off())
paleta <- vapply(0:100, function(k) cor_politica(k / 10), character(1))
intervalos <- seq(0, 10, length.out = 121)
faixa <- vapply(1:120, function(j) cor_politica(mean(intervalos[c(j, j + 1L)])), character(1))
writeLines(json(list(casos = referencia, paleta = paleta, faixa = faixa)), args[1], useBytes = TRUE)
if (length(args) >= 2L) writeLines(json(paleta), args[2], useBytes = TRUE)
if (length(args) >= 3L) writeLines(json(faixa), args[3], useBytes = TRUE)
cat("Referência real do R exportada:", length(referencia), "casos artificiais.\n")
