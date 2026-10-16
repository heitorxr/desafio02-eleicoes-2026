# Os valores abaixo sao fixtures artificiais EXCLUSIVAS para testar a agregacao.
raiz <- normalizePath(getwd(), winslash = "/")
stopifnot(file.exists(file.path(raiz, "R", "dados.R")))
source(file.path(raiz, "R", "dados.R"), encoding = "UTF-8")
x <- data.frame(ANO_ELEICAO = "2026", NR_TURNO = c("1", "1", "1", "2", "1"),
  CD_TIPO_ELEICAO = "2", SG_UF = c("PR", "PR", "PR", "PR", "ZZ"),
  CD_MUNICIPIO = c("1", "1", "2", "1", "3"), NR_ZONA = "1", CD_CARGO = "1",
  NR_PARTIDO = c("10", "20", "10", "10", "10"), SG_PARTIDO = c("A", "B", "A", "A", "A"),
  ST_VOTO_EM_TRANSITO = "N", QT_VOTOS_NOMINAIS_VALIDOS = c("10", "20", "5", "900", "900"),
  QT_TOTAL_VOTOS_LEG_VALIDOS = "0", stringsAsFactors = FALSE)
x$TP_AGREMIACAO <- "Partido isolado"
x$NR_FEDERACAO <- "-1"
x$SQ_COLIGACAO <- "1"
v <- somar_votos_partidos(x)
stopifnot(nrow(v) == 2L, sum(v$votos) == 35, all(v$uf == "PR"),
          v$votos[v$sigla == "A"] == 15)
falhou <- try(somar_votos_partidos(rbind(x, x[1, ])), silent = TRUE)
stopifnot(inherits(falhou, "try-error"))
outra_agremiacao <- x[1, ]
outra_agremiacao$SQ_COLIGACAO <- "2"
stopifnot(sum(somar_votos_partidos(rbind(x, outra_agremiacao))$votos) == sum(v$votos) + 10)
ideologia <- data.frame(sigla = "A", nota = 2, ano_fonte = 2022)
i <- calcular_indices(v, ideologia)
stopifnot(i$nota == 2, i$votos_validos == 35, i$votos_classificados == 15,
          abs(i$cobertura - 15 / 35) < 1e-12)
i <- calcular_indices(v, data.frame(sigla = "C", nota = 9, ano_fonte = 2022))
stopifnot(is.na(i$nota), i$cobertura == 0)
conhecido <- calcular_indices(v, ideologia)
auditoria <- data.frame(uf = "PR", cargo = "presidente", QT_TOTAL_VOTOS_VALIDOS = 40,
                       diferenca = -5)
verificado <- aplicar_auditoria(conhecido, auditoria)
stopifnot(is.na(verificado$nota), !verificado$integro,
          verificado$votos_validos == 40, verificado$cobertura == 15 / 40)
cat("OK: turno, exterior, duplicatas, pesos e ausencia de classificacao tratados corretamente.\n")
