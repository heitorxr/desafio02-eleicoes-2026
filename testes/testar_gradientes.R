# Fixtures matemáticas; não lê nem modifica dados eleitorais.
source("R/geometria.R", encoding = "UTF-8")
source("R/visualizar.R", encoding = "UTF-8")
options(warn = 2)
igual <- function(a, b) stopifnot(isTRUE(all.equal(a, b, tolerance = 1e-12)))
stopifnot(exists("campo_gradiente_angular", mode = "function"),
          exists("campo_gradiente_linear", mode = "function"))
notas <- c(0, 2.5, 5, 7.5, 10)
for (raio in c(.84, .92, 1)) {
  z <- ponto_complexo(angulo_ponteiro(notas), raio)
  cores <- campo_gradiente_angular(Re(z), Im(z))
  stopifnot(is.character(cores), length(cores) == length(notas))
  igual(cores, cor_politica(notas))
}
# Fora do anel e abaixo do eixo não existe campo visível.
igual(campo_gradiente_angular(c(0, 0, 0, 0, NA, Inf),
                             c(.839999, 1.000001, -.92, 0, .9, .9)),
      rep("#00000000", 6))
igual(campo_gradiente_angular(c(-.84, -1, .84, 1), 0), cor_politica(c(0, 0, 10, 10)))
# Na diagonal, variar raio não muda a cor: isto detecta o gradiente em X incorreto.
igual(campo_gradiente_angular(c(-.6, -.7), c(.6, .7)), rep(cor_politica(2.5), 2))
igual(campo_gradiente_linear(c(0, .25, .5, .75, 1)), cor_politica(notas))
cat("OK: campo angular por Arg(z), máscara radial e campo linear RGB.\n")

stopifnot(exists("textura_gradiente_angular", mode = "function"),
          exists("textura_gradiente_linear", mode = "function"),
          exists("desenhar_gradiente_angular", mode = "function"),
          exists("desenhar_gradiente_linear", mode = "function"),
          exists("exportar_gradiente_angular", mode = "function"))
textura <- textura_gradiente_angular()
stopifnot(inherits(textura, "raster"), identical(dim(textura), c(384L, 768L)))
x <- -1 + (seq_len(768) - .5) * 2 / 768
y <- 1 - (seq_len(384) - .5) / 384
# Linha 1 = topo (y próximo de 1); centros dos pixels, não bordas.
for (linha in c(1L, 100L, 384L))
  igual(as.character(textura[linha, ]), campo_gradiente_angular(x, y[linha]))
stopifnot(textura[1, 384] != "#00000000", textura[384, 384] == "#00000000",
          textura[384, 1] == cor_politica(0), textura[384, 768] == cor_politica(10))
barra <- textura_gradiente_linear()
stopifnot(inherits(barra, "raster"), identical(dim(barra), c(1L, 1025L)))
igual(as.character(barra[1, c(1, 513, 1025)]), cor_politica(c(0, 5, 10)))
# A mesma textura cacheada serve os 135 velocímetros, sem nota como parâmetro.
for (j in seq_len(135)) stopifnot(identical(textura, textura_gradiente_angular()))
stopifnot(!"nota" %in% names(formals(textura_gradiente_angular)))
igual(dim(textura_gradiente_angular(96L, 48L)), c(48L, 96L))
stopifnot(identical(textura, textura_gradiente_angular()))
cat("OK: textura angular cacheada, orientação e barra endpoints/centro.\n")

provar_gradientes <- function() {
  scratch <- file.path(Sys.getenv("LOCALAPPDATA"), "hermes", "cache", "scratch")
  stopifnot(dir.exists(scratch))
  arquivos <- file.path(scratch, paste0("gradientes_", Sys.getpid(), c(".png", ".svg", ".pdf")))
  on.exit(unlink(arquivos), add = TRUE)
  exportar_gradiente_angular(arquivos[1])
  cabecalho <- readBin(arquivos[1], "raw", 26)
  stopifnot(identical(cabecalho[1:8], as.raw(c(137, 80, 78, 71, 13, 10, 26, 10))),
            identical(as.integer(cabecalho[17:24]), c(0L, 0L, 3L, 0L, 0L, 0L, 1L, 128L)),
            as.integer(cabecalho[26]) %in% c(4L, 6L)) # PNG com canal alpha.
  # Instrumenta as primitivas reais sem substituir seu desenho.
  .sonda_gradientes <<- new.env(parent = emptyenv())
  .sonda_gradientes$segmentos <- list()
  .sonda_gradientes$poligonos <- 0L
  .sonda_gradientes$retangulos <- 0L
  .sonda_gradientes$rasters <- list()
  trace("rasterImage", where = asNamespace("graphics"), print = FALSE,
        tracer = quote(.sonda_gradientes$rasters[[length(.sonda_gradientes$rasters) + 1L]] <-
          list(imagem = image, limites = c(xleft, ybottom, xright, ytop), interpolar = interpolate)))
  trace("segments", where = asNamespace("graphics"), print = FALSE,
        tracer = quote(.sonda_gradientes$segmentos[[length(.sonda_gradientes$segmentos) + 1L]] <- c(x0, y0, x1, y1)))
  trace("polygon", where = asNamespace("graphics"), print = FALSE,
        tracer = quote(.sonda_gradientes$poligonos <- .sonda_gradientes$poligonos + 1L))
  trace("rect", where = asNamespace("graphics"), print = FALSE,
        tracer = quote(.sonda_gradientes$retangulos <- .sonda_gradientes$retangulos + 1L))
  on.exit({
    for (nome in c("rasterImage", "segments", "polygon", "rect")) untrace(nome, where = asNamespace("graphics"))
    rm(".sonda_gradientes", envir = .GlobalEnv)
  }, add = TRUE)
  for (arquivo in arquivos[-1]) {
    if (grepl("svg$", arquivo)) grDevices::svg(arquivo, width = 6, height = 5)
    else grDevices::cairo_pdf(arquivo, width = 6, height = 5)
    tryCatch({
      graphics::par(mar = c(0, 0, 0, 0))
      for (nota in c(notas, NA_real_, NA)) {
        antes <- length(.sonda_gradientes$segmentos)
        p <- desenhar_velocimetro(nota)
        igual(p, coordenadas_ponteiro(nota, .78))
        raster <- tail(.sonda_gradientes$rasters, 1)[[1]]
        igual(raster$imagem, textura)
        igual(raster$limites, c(-1, 0, 1, 1))
        stopifnot(identical(raster$interpolar, FALSE))
        if (is.na(nota)) stopifnot(length(.sonda_gradientes$segmentos) == antes, all(is.na(unlist(p))))
        else igual(.sonda_gradientes$segmentos[[antes + 1L]], c(0, 0, p$x, p$y))
        stopifnot(identical(textura, textura_gradiente_angular()))
      }
      # Barra na extensão original; retorna a textura realmente desenhada.
      graphics::plot.new()
      graphics::plot.window(c(0, 6), c(-1, 1))
      igual(desenhar_gradiente_linear(), barra)
      raster <- tail(.sonda_gradientes$rasters, 1)[[1]]
      igual(raster$imagem, barra)
      igual(raster$limites, c(.9, -.02, 5.4, .13))
      stopifnot(identical(raster$interpolar, FALSE))
      igual(desenhar_gradiente_angular(), textura)
    }, finally = grDevices::dev.off())
    stopifnot(file.info(arquivo)$size > 1000)
  }
  stopifnot(.sonda_gradientes$poligonos == 0L, .sonda_gradientes$retangulos == 0L)
  svg <- paste(readLines(arquivos[2], warn = FALSE), collapse = "\n")
  stopifnot(grepl("<image", svg, fixed = TRUE), grepl("image/png", svg, fixed = TRUE))
  # Integração: exportação ocorre antes dos painéis; não executa gerar_figuras.
  corpo <- paste(deparse(body(gerar_figuras)), collapse = "\n")
  pos_exportacao <- regexpr("exportar_gradiente_angular", corpo, fixed = TRUE)[1]
  pos_paineis <- regexpr("for (uf in grade$uf)", corpo, fixed = TRUE)[1]
  stopifnot(pos_exportacao > 0L, pos_exportacao < pos_paineis,
            grepl('"gradiente_angular.png"', corpo, fixed = TRUE))
  cartograma <- paste(deparse(body(desenhar_cartograma)), collapse = "\n")
  stopifnot(grepl("desenhar_gradiente_linear()", cartograma, fixed = TRUE),
            !grepl("rect(", cartograma, fixed = TRUE))
  cat("OK: PNG RGBA 768x384, SVG com imagem, PDF, ponteiros intactos/ausentes e integração.\n")
}
provar_gradientes()
cat("SUCESSO: gradientes validados sem regenerar figuras finais.\n")
