"""Empacota os SVGs desenhados em R em um único HTML offline; não calcula índices."""
from pathlib import Path
import base64
import csv
import json
import math

RAIZ = Path(__file__).resolve().parents[1]


def ler_csv(relativo):
    with (RAIZ / relativo).open(encoding="utf-8-sig", newline="") as arquivo:
        return list(csv.DictReader(arquivo))


def numero(valor):
    if valor in ("NA", ""):
        return None
    x = float(valor)
    if not math.isfinite(x):
        raise ValueError("Número não finito no arquivo de entrada")
    return x


def imagem(relativo):
    return "data:image/svg+xml;base64," + base64.b64encode((RAIZ / relativo).read_bytes()).decode("ascii")


def montar():
    indices = ler_csv("resultados/indices_uf_cargo.csv")
    grade = ler_csv("dados/referencia/layout_ufs.csv")
    estados = {}
    for estado in grade:
        uf = estado["uf"]
        valores = []
        for linha in indices:
            if linha["uf"] != uf:
                continue
            valores.append({
                "cargo": linha["cargo"], "nota": numero(linha["nota"]),
                "cobertura": numero(linha["cobertura"]), "desvio": numero(linha["desvio"]),
                "votos_validos": int(linha["votos_validos"]),
                "votos_classificados": int(linha["votos_classificados"]),
                "integro": {"TRUE": True, "FALSE": False}[linha["integro"]],
                "partidos_sem_nota": linha["partidos_sem_nota"],
            })
        assert len(valores) == 5
        estados[uf] = {"nome": estado["nome"], "indices": valores,
                       "imagem": imagem(f"resultados/detalhes/{uf}.svg")}
    centros = [{"uf": r["uf"], "x": float(r["x"]), "y": float(r["y"]), "raio": float(r["raio"])}
               for r in ler_csv("resultados/centros_cartograma.csv")]
    comparacoes = {cargo: {"imagem": imagem(f"resultados/comparacao_{cargo}.svg"),
                           "exemplos": [{"uf": r["uf"], "nota": numero(r["nota"])}
                                        for r in ler_csv(f"resultados/comparacao_{cargo}.csv")]}
                   for cargo in ("presidente", "governador", "senador", "federal", "estadual")}
    dados = {"estados": estados, "centros": centros, "mapa": imagem("resultados/cartograma_brasil.svg"),
             "comparacoes": comparacoes,
             "csv": "data:text/csv;charset=utf-8;base64," + base64.b64encode(
                 (RAIZ / "resultados/indices_uf_cargo.csv").read_bytes()).decode("ascii")}
    texto = json.dumps(dados, ensure_ascii=False, allow_nan=False, separators=(",", ":")).replace("<", "\\u003c")
    template = (RAIZ / "interface/painel.html").read_text(encoding="utf-8")
    assert template.count("__DADOS__") == 1
    destino = RAIZ / "resultados/painel.html"
    destino.write_text(template.replace("__DADOS__", texto), encoding="utf-8")
    print(f"Painel offline gerado: {destino} ({destino.stat().st_size:,} bytes)")


if __name__ == "__main__":
    montar()
