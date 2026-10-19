# Entrada reproduzível: Rscript executar.R [analisar|figuras|painel|tudo|testar]
argumento <- grep("^--file=", commandArgs(FALSE), value = TRUE)
raiz <- if (length(argumento)) dirname(normalizePath(sub("^--file=", "", argumento[1]), winslash = "/")) else getwd()
setwd(raiz)
source("R/dados.R", encoding = "UTF-8")
source("R/geometria.R", encoding = "UTF-8")
source("R/visualizar.R", encoding = "UTF-8")
acao <- commandArgs(TRUE)
if (!length(acao)) acao <- "tudo"
stopifnot(acao[1] %in% c("analisar", "figuras", "painel", "tudo", "testar"))
if (acao[1] %in% c("analisar", "tudo")) {
  votos <- preparar_votos(raiz)
  referencia <- read.csv("dados/referencia/ideologia_partidos.csv", fileEncoding = "UTF-8")
  auditoria <- read.csv("dados/entrada/auditoria_eleitoral.csv", fileEncoding = "UTF-8")
  indices <- aplicar_auditoria(calcular_indices(votos, referencia), auditoria)
  dir.create("resultados", showWarnings = FALSE)
  write.csv(indices, "resultados/indices_uf_cargo.csv", row.names = FALSE, fileEncoding = "UTF-8")
}
if (acao[1] %in% c("figuras", "tudo")) {
  indices <- read.csv("resultados/indices_uf_cargo.csv", fileEncoding = "UTF-8")
  grade <- read.csv("dados/referencia/layout_ufs.csv", fileEncoding = "UTF-8")
  gerar_figuras(raiz, indices, grade)
  message("Cartograma e velocímetros das 27 UFs gerados em R.")
}
if (acao[1] %in% c("painel", "tudo")) {
  python <- Sys.which("python")
  if (!nzchar(python)) stop("Python é necessário somente para empacotar o painel HTML.")
  status <- system2(python, shQuote(file.path(raiz, "scripts", "montar_painel.py")))
  if (status != 0) stop("Falha ao empacotar o painel.")
}
if (acao[1] == "testar") {
  source("testes/testar_dados.R", encoding = "UTF-8")
  source("testes/testar_geometria.R", encoding = "UTF-8")
  source("testes/testar_visual.R", encoding = "UTF-8")
  source("testes/testar_legibilidade.R", encoding = "UTF-8")
  source("testes/testar_legibilidade_nariz.R", encoding = "UTF-8")
  source("testes/testar_recuperacao_ro.R", encoding = "UTF-8")
}
