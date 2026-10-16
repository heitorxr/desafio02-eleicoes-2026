# Regressão: recuperar os dois cargos de RO sem inventar votos nem alterar outras UFs.
x <- read.csv('resultados/indices_uf_cargo.csv', fileEncoding='UTF-8')
stopifnot(nrow(x) == 135L, all(is.finite(x$nota)), all(x$integro))
a <- read.csv('dados/entrada/auditoria_eleitoral.csv')
o <- read.csv('dados/entrada/auditoria_eleitoral_original.csv')
stopifnot(all(a$diferenca == 0), sum(o$diferenca != 0) == 2L,
          all(o$uf[o$diferenca != 0] == 'RO'))
r <- read.csv('dados/entrada/ro_votos_reconstruidos.csv', fileEncoding='UTF-8')
stopifnot(sum(r$nominais_validos[r$cargo=='federal']) == 904018,
          sum(r$nominais_validos[r$cargo=='estadual']) == 896601,
          all(r$votos == r$nominais_validos + r$legenda_valida))
original <- read.csv('dados/entrada/votos_partido_uf_original.csv', fileEncoding='UTF-8')
atual <- read.csv('dados/entrada/votos_partido_uf.csv', fileEncoding='UTF-8')
ordenar <- function(x) {
  x <- x[x$uf!='RO',]
  x <- x[order(x$uf,x$cargo,x$sigla),]
  rownames(x) <- NULL
  x
}
stopifnot(identical(ordenar(original),ordenar(atual)))
cat('OK: RO recuperado, 135 índices conciliados e demais UFs preservadas.\n')
