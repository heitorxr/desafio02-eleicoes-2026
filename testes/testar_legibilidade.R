# Painéis com três linhas não devem herdar a redução automática de fonte do R.
source("R/geometria.R", encoding = "UTF-8")
source("R/visualizar.R", encoding = "UTF-8")
indices <- read.csv("resultados/indices_uf_cargo.csv", fileEncoding = "UTF-8")
arquivo <- file.path(Sys.getenv("LOCALAPPDATA"), "hermes", "cache", "scratch", "desafio02",
                     paste0("legibilidade_", Sys.getpid(), ".svg"))
svg(arquivo, width = 8, height = 8.1, pointsize = 16)
tryCatch({
  painel_velocimetros(indices, "PR")
  stopifnot(par("cex") >= 1)
}, finally = {dev.off(); unlink(arquivo)})
cat("OK: painéis preservam tamanho de fonte, sem encolhimento automático por mfrow.\n")
