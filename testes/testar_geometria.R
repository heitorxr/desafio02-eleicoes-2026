# Fixtures exclusivamente matemáticas: não representam dados eleitorais.
argumentos <- commandArgs(trailingOnly = FALSE)
arquivo <- sub("^--file=", "", argumentos[grepl("^--file=", argumentos)])
raiz <- if (length(arquivo)) dirname(dirname(normalizePath(arquivo))) else getwd()
modulo <- file.path(raiz, "R", "geometria.R")
if (file.exists(modulo)) source(modulo, encoding = "UTF-8")
igual <- function(a, b) stopifnot(isTRUE(all.equal(a, b, tolerance = 1e-12)))
rejeita <- function(expr) stopifnot(inherits(tryCatch(force(expr), error = identity), "error"))
stopifnot(exists("normalizar_nota", mode = "function"))
igual(normalizar_nota(c(0, 5, 10, NA)), c(0, .5, 1, NA))
igual(normalizar_nota(c(20, 30, 40), 20, 40), c(0, .5, 1))
rejeita(normalizar_nota(1, 2, 2))
rejeita(normalizar_nota(1, 3, 2))
rejeita(normalizar_nota(c(-1, 11)))
rejeita(normalizar_nota(Inf))
igual(angulo_ponteiro(c(0, 5, 10)), c(pi, pi / 2, 0))
for (n in c(0, 2.5, 5, 7.5, 10)) {
  p <- coordenadas_ponteiro(n)
  q <- coordenadas_ponteiro(10 - n)
  igual(p$x, -q$x); igual(p$y, q$y)
  igual(Mod(p$z), 1)
  r <- coordenadas_ponteiro(n, 3, c(2, -4))
  igual(r$theta, p$theta)
  igual(r$z, 2 - 4i + 3 * p$z)
  stopifnot(all(is.finite(unlist(r))))
}
igual(ponto_complexo(c(0, pi / 2, pi), 2, 1 + 3i), c(3 + 3i, 1 + 5i, -1 + 3i))
stopifnot(all(is.na(unlist(coordenadas_ponteiro(NA_real_)))))
stopifnot(all(is.na(unlist(coordenadas_ponteiro(NA)))))
igual(normalizar_nota(NA), NA_real_)
igual(cor_politica(NA), "#B8B8B8")
rejeita(coordenadas_ponteiro(-1)); rejeita(coordenadas_ponteiro(11))
rejeita(coordenadas_ponteiro(5, -1)); rejeita(coordenadas_ponteiro(c(1, 2)))
rejeita(coordenadas_ponteiro(5, centro = c(1, Inf)))
cat("OK: normalização, geometria complexa, espelho, raio e ausências.\n")
stopifnot(exists("cor_politica", mode = "function"))
igual(cor_politica(c(0, 5, 10, NA)), c("#BF4D45", "#F2E9D8", "#43866A", "#B8B8B8"))
stopifnot(all(grepl("^#[0-9A-F]{6}$", cor_politica(seq(0, 10, by = .1)))))
rejeita(cor_politica(11))
cat("OK: cores RGB e ausência explicitamente cinza.\n")
stopifnot(exists("desenhar_velocimetro", mode = "function"))
stopifnot(exists("desenhar_face", mode = "function"))
provar_desenhos <- function() {
  scratch <- "C:/Users/heito/AppData/Local/hermes/cache/scratch"
  stopifnot(dir.exists(scratch))
  arquivos <- file.path(scratch, paste0("prova_geometria_", Sys.getpid(), c(".png", ".pdf")))
  on.exit(unlink(arquivos), add = TRUE)
  for (arquivo in arquivos) {
    if (grepl("png$", arquivo)) grDevices::png(arquivo, width = 1600, height = 1000)
    else grDevices::pdf(arquivo, width = 12, height = 8, family = "Helvetica")
    tryCatch({
      graphics::par(mfrow = c(2, 4), mar = c(1, 1, 3, 1), family = "sans")
      for (n in c(0, 5, 10, NA_real_)) {
        p <- desenhar_velocimetro(n, titulo = "Fixture matemática", subtitulo = "Somente teste")
        igual(p, coordenadas_ponteiro(n, .78))
      }
      for (n in c(0, 5, 10, NA_real_)) {
        graphics::plot.new()
        graphics::plot.window(c(-1.2, 1.2), c(-1.2, 1.2), asp = 1)
        notas <- setNames(rep(n, 5), c("presidente", "governador", "senador", "federal", "estadual"))
        estado <- desenhar_face(notas = notas)
        stopifnot(all(c("abertura_olho", "abertura_boca", "curvatura_nariz",
                        "altura_sobrancelha") %in% names(estado)))
        igual(unname(estado$notas), rep(n / 10, 5))
        if (is.na(n)) {
          stopifnot(all(is.na(estado$notas)), is.na(estado$abertura_boca))
        } else {
          stopifnot(length(estado$boca$y) > 2L)
          stopifnot(estado$abertura_olho > 0, estado$abertura_boca > 0)
          stopifnot(all(is.finite(unlist(estado))))
        }
      }
      ausentes <- setNames(rep(NA, 5), names(notas))
      stopifnot(all(is.na(desenhar_face(notas = ausentes)$notas)))
      base <- setNames(rep(5, 5), names(notas))
      for (cargo in names(base)) {
        parcial <- base; parcial[cargo] <- NA_real_
        resultado <- desenhar_face(notas = parcial)
        stopifnot(is.na(resultado$notas[cargo]), sum(is.na(resultado$notas)) == 1)
      }
      inicial <- desenhar_face(notas = base)
      ampliado <- desenhar_face(x = 2, y = -3, raio = 2, notas = base)
      igual(ampliado$boca$x, 2 + 2 * inicial$boca$x)
      igual(ampliado$boca$y, -3 + 2 * inicial$boca$y)
      igual(ampliado$nariz$x, 2 + 2 * inicial$nariz$x)
      igual(ampliado$nariz$y, -3 + 2 * inicial$nariz$y)
      # Uma mesma família de traços: só largura e arredondamento dependem do federal.
      anterior <- NULL
      for (nota_federal in seq(0, 10, by = .5)) {
        mesmas <- base; mesmas["federal"] <- nota_federal
        perfil <- desenhar_face(notas = mesmas)
        stopifnot(is.numeric(perfil$curvatura_nariz), length(perfil$curvatura_nariz) == 1L,
                  is.finite(perfil$curvatura_nariz), length(perfil$nariz$x) > 30L)
        igual(perfil$comprimento_nariz, inicial$comprimento_nariz)
        igual(diff(range(perfil$nariz$y)), perfil$comprimento_nariz)
        igual(perfil$nariz$x[1], 0)
        igual(perfil$nariz$y[1], .06)
        if (!is.null(anterior)) {
          stopifnot(perfil$curvatura_nariz > anterior$curvatura_nariz,
                    perfil$curvatura_nariz / perfil$largura_nariz >
                      anterior$curvatura_nariz / anterior$largura_nariz,
                    diff(range(perfil$nariz$x)) > diff(range(anterior$nariz$x)))
        }
        for (outro in c("abertura_olho", "abertura_boca", "altura_sobrancelha", "boca"))
          igual(perfil[[outro]], inicial[[outro]])
        anterior <- perfil
      }
      for (cargo in names(base)[-1]) {
        alterada <- base; alterada[cargo] <- 10
        estado <- desenhar_face(notas = alterada)
        campo <- c(governador = "abertura_olho", senador = "abertura_boca",
                   federal = "curvatura_nariz", estadual = "altura_sobrancelha")[[cargo]]
        stopifnot(estado[[campo]] > inicial[[campo]])
        igual(estado$comprimento_sobrancelha, inicial$comprimento_sobrancelha)
        stopifnot(length(estado$nariz$x) > 30L)
        igual(estado$comprimento_nariz, inicial$comprimento_nariz)
        igual(min(estado$nariz$x), -max(estado$nariz$x))
        if (cargo == "federal") {
          stopifnot(diff(range(estado$nariz$x)) > diff(range(inicial$nariz$x)))
          igual(diff(range(estado$nariz$y)), diff(range(inicial$nariz$y)))
        } else igual(estado$nariz, inicial$nariz)
        outros <- setdiff(unname(c("abertura_olho", "abertura_boca", "curvatura_nariz", "altura_sobrancelha")), campo)
        for (outro in outros) igual(estado[[outro]], inicial[[outro]])
      }
      rejeita(desenhar_face(notas = c(presidente = 5)))
      rejeita(desenhar_face(notas = setNames(rep(11, 5), names(notas))))
      rejeita(desenhar_face(raio = -1, notas = notas))
      rejeita(desenhar_velocimetro(11))
    }, finally = grDevices::dev.off())
    stopifnot(file.info(arquivo)$size > 1000)
    assinatura <- readBin(arquivo, "raw", n = 4)
    stopifnot(identical(assinatura, if (grepl("png$", arquivo))
      as.raw(c(137, 80, 78, 71)) else charToRaw("%PDF")))
    cat("OK: prova", basename(arquivo), "gerada e validada.\n")
  }
  unlink(arquivos)
  stopifnot(!any(file.exists(arquivos)))
}
options(warn = 2)
provar_desenhos()
cat("SUCESSO: todos os testes passaram; provas temporárias removidas.\n")
