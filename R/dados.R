# Dados oficiais: uma linha final por UF, cargo e partido; indices calculados em R.
ufs_brasil <- c("AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS",
                "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO")
codigos_cargos <- c("1" = "presidente", "3" = "governador", "5" = "senador",
                    "6" = "federal", "7" = "estadual", "8" = "estadual")

normalizar_sigla <- function(x) toupper(trimws(iconv(x, to = "ASCII//TRANSLIT")))

ler_csv_zip <- function(arquivo, membro, colunas) {
  con <- unz(arquivo, membro, open = "rt", encoding = "latin1")
  cabecalho <- scan(con, what = character(), sep = ";", nlines = 1, quiet = TRUE)
  close(con)
  stopifnot(all(colunas %in% cabecalho))
  classes <- ifelse(cabecalho %in% colunas, "character", "NULL")
  con <- unz(arquivo, membro, open = "rt", encoding = "latin1")
  on.exit(close(con))
  read.csv2(con, colClasses = classes, encoding = "latin1", check.names = FALSE,
            stringsAsFactors = FALSE, na.strings = character())
}

selecionar_primeiro_turno <- function(x) {
  x[x$ANO_ELEICAO == "2026" & x$NR_TURNO == "1" & x$CD_TIPO_ELEICAO == "2" &
      x$SG_UF %in% ufs_brasil & x$CD_CARGO %in% names(codigos_cargos), , drop = FALSE]
}

somar_votos_partidos <- function(dados) {
  x <- selecionar_primeiro_turno(dados)
  # Um partido pode ter registros de agremiacoes distintas na mesma zona.
  chave <- x[c("SG_UF", "CD_MUNICIPIO", "NR_ZONA", "CD_CARGO", "NR_PARTIDO",
               "ST_VOTO_EM_TRANSITO", "TP_AGREMIACAO", "NR_FEDERACAO", "SQ_COLIGACAO")]
  stopifnot(!anyDuplicated(chave))
  # Total de legenda ja inclui votos nominais convertidos: nao somar essa parcela novamente.
  x$votos <- as.numeric(x$QT_VOTOS_NOMINAIS_VALIDOS) + as.numeric(x$QT_TOTAL_VOTOS_LEG_VALIDOS)
  stopifnot(all(is.finite(x$votos)), all(x$votos >= 0))
  x$uf <- x$SG_UF
  x$cargo <- unname(codigos_cargos[x$CD_CARGO])
  x$sigla <- normalizar_sigla(x$SG_PARTIDO)
  aggregate(x["votos"], x[c("uf", "cargo", "sigla")], sum)
}

calcular_indices <- function(votos, ideologia) {
  ideologia$sigla <- normalizar_sigla(ideologia$sigla)
  stopifnot(!anyDuplicated(ideologia$sigla))
  stopifnot(all(is.na(ideologia$nota) | (ideologia$nota >= 0 & ideologia$nota <= 10)))
  x <- merge(votos, ideologia, by = "sigla", all.x = TRUE, sort = FALSE)
  grupos <- split(x, interaction(x$uf, x$cargo, drop = TRUE))
  resultado <- lapply(grupos, function(g) {
    conhecida <- is.finite(g$nota)
    total <- sum(g$votos)
    classificados <- sum(g$votos[conhecida])
    nota <- if (classificados > 0) sum(g$votos[conhecida] * g$nota[conhecida]) / classificados else NA_real_
    desvio <- if (classificados > 0) sqrt(sum(g$votos[conhecida] *
      (g$nota[conhecida] - nota)^2) / classificados) else NA_real_
    data.frame(uf = g$uf[1], cargo = g$cargo[1], nota = nota, desvio = desvio,
      votos_validos = total, votos_classificados = classificados,
      cobertura = if (total > 0) classificados / total else NA_real_,
      partidos_sem_nota = paste(sort(unique(g$sigla[!conhecida & g$votos > 0])), collapse = ", "),
      stringsAsFactors = FALSE)
  })
  do.call(rbind, resultado)
}

aplicar_auditoria <- function(indices, auditoria) {
  x <- merge(indices, auditoria[c("uf", "cargo", "QT_TOTAL_VOTOS_VALIDOS", "diferenca")],
             by = c("uf", "cargo"), all.x = TRUE)
  stopifnot(!anyNA(x$diferenca))
  x$integro <- x$diferenca == 0
  x$votos_validos <- x$QT_TOTAL_VOTOS_VALIDOS
  x$cobertura <- ifelse(x$votos_validos > 0, x$votos_classificados / x$votos_validos, NA_real_)
  # Nao inventar uma posicao politica onde as fontes de votos nao conciliam.
  x$nota[!x$integro] <- NA_real_
  x$desvio[!x$integro] <- NA_real_
  x
}

preparar_votos <- function(raiz) {
  brutos <- file.path(raiz, "dados", "brutos")
  entrada <- file.path(raiz, "dados", "entrada")
  dir.create(entrada, recursive = TRUE, showWarnings = FALSE)
  comuns <- c("ANO_ELEICAO", "NR_TURNO", "CD_TIPO_ELEICAO", "SG_UF", "CD_MUNICIPIO",
              "NR_ZONA", "CD_CARGO", "ST_VOTO_EM_TRANSITO")
  # BRASIL contem todos os cargos. Os arquivos BR e por UF sao subconjuntos e NAO sao somados juntos.
  partidos <- ler_csv_zip(file.path(brutos, "votacao_partido_munzona_2026.zip"),
    "votacao_partido_munzona_2026_BRASIL.csv",
    c(comuns, "NR_PARTIDO", "SG_PARTIDO", "TP_AGREMIACAO", "NR_FEDERACAO", "SQ_COLIGACAO",
      "QT_VOTOS_NOMINAIS_VALIDOS", "QT_TOTAL_VOTOS_LEG_VALIDOS"))
  votos <- somar_votos_partidos(partidos)
  detalhe <- ler_csv_zip(file.path(brutos, "detalhe_votacao_munzona_2026.zip"),
    "detalhe_votacao_munzona_2026_BRASIL.csv",
    c(comuns, "QT_TOTAL_VOTOS_VALIDOS", "QT_VOTOS_BRANCOS", "QT_TOTAL_VOTOS_NULOS"))
  detalhe <- selecionar_primeiro_turno(detalhe)
  stopifnot(!anyDuplicated(detalhe[comuns[c(4, 5, 6, 7, 8)]]))
  detalhe$uf <- detalhe$SG_UF
  detalhe$cargo <- unname(codigos_cargos[detalhe$CD_CARGO])
  campos <- c("QT_TOTAL_VOTOS_VALIDOS", "QT_VOTOS_BRANCOS", "QT_TOTAL_VOTOS_NULOS")
  detalhe[campos] <- lapply(detalhe[campos], as.numeric)
  totais <- aggregate(detalhe[campos], detalhe[c("uf", "cargo")], sum)
  auditoria <- merge(aggregate(votos["votos"], votos[c("uf", "cargo")], sum), totais,
                    by = c("uf", "cargo"), all = TRUE)
  auditoria$diferenca <- auditoria$votos - auditoria$QT_TOTAL_VOTOS_VALIDOS
  stopifnot(nrow(auditoria) == length(ufs_brasil) * length(unique(codigos_cargos)),
            !anyNA(auditoria$diferenca))
  auditoria$integro <- auditoria$diferenca == 0
  write.csv(votos, file.path(entrada, "votos_partido_uf.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  write.csv(totais, file.path(entrada, "totais_uf_cargo.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  write.csv(auditoria, file.path(entrada, "auditoria_eleitoral.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  message("Fontes conciliadas: ", sum(auditoria$integro), " de ", nrow(auditoria),
          " combinacoes UF-cargo. Divergencias serao marcadas como indisponiveis.")
  invisible(votos)
}
