"""Empacota os SVGs desenhados em R em um único HTML offline; não calcula índices."""
from pathlib import Path
import base64
import csv
import json
import math
import unicodedata
import html
import re
import subprocess

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


def chave_partido(sigla):
    return unicodedata.normalize("NFKD", sigla).encode("ascii", "ignore").decode().strip().upper()


def tabela_partidos(indices):
    partidos = {}
    for linha in ler_csv("dados/referencia/ideologia_partidos.csv"):
        chave = chave_partido(linha["sigla"])
        if chave in partidos:
            raise ValueError(f"Sigla duplicada na referência: {linha['sigla']}")
        nota = numero(linha["nota"])
        if nota is not None and not 0 <= nota <= 10:
            raise ValueError("Nota partidária fora da escala 0–10")
        partidos[chave] = {"chave": chave, "sigla": linha["sigla"], "nota": nota,
                           "ano": int(linha["ano_fonte"]) if nota is not None else None,
                           "sigla_fonte": linha["sigla_fonte"]}
    for linha in indices:
        for sigla in (s.strip() for s in linha["partidos_sem_nota"].split(",")):
            if not sigla:
                continue
            chave = chave_partido(sigla)
            if chave not in partidos:
                partidos[chave] = {"chave": chave, "sigla": sigla, "nota": None,
                                   "ano": None, "sigla_fonte": ""}
            elif partidos[chave]["nota"] is not None:
                raise ValueError(f"Lacuna contradiz nota da referência: {sigla}")
    return sorted(partidos.values(), key=lambda p: (p["nota"] is None,
                  p["nota"] if p["nota"] is not None else math.inf, p["chave"]))


def matematica_offline():
    biblioteca = RAIZ / "node_modules/katex"
    if not (biblioteca / "dist/katex.min.css").exists():
        raise RuntimeError("Execute npm ci na raiz para instalar o KaTeX usado no empacotamento.")
    artigo = (RAIZ / "interface/matematica_texto.html").read_text(encoding="utf-8")
    demo = (RAIZ / "interface/matematica_demo.html").read_text(encoding="utf-8")
    demo = demo.replace("__MATEMATICA_TEXTO__", artigo)
    padrao = re.compile(r'(<(?P<tag>div|span) class="(?:equacao|mat-inline)" data-tex="(?P<tex>[^"]*)">)</(?P=tag)>')
    formulas = [{"tex": html.unescape(m["tex"]), "displayMode": m["tag"] == "div"}
                for m in padrao.finditer(demo)]
    if not formulas:
        raise ValueError("Faltam as fórmulas TeX da aba de matemática.")
    processo = subprocess.run(["node", str(RAIZ / "scripts/renderizar_formulas.cjs")],
                              input=json.dumps(formulas), text=True, encoding="utf-8",
                              capture_output=True, cwd=RAIZ, check=True)
    renderizadas = iter(json.loads(processo.stdout))
    demo = padrao.sub(lambda m: m[1] + next(renderizadas) + "</" + m["tag"] + ">", demo)
    css = (biblioteca / "dist/katex.min.css").read_text(encoding="utf-8")
    def fonte_local(m):
        caminhos = [x.strip("\"'") for x in re.findall(r"url\(([^)]+)\)", m[0])]
        caminho = next(x for x in caminhos if x.endswith(".woff2"))
        conteudo = base64.b64encode((biblioteca / "dist" / caminho).read_bytes()).decode("ascii")
        return 'src:url("data:font/woff2;base64,' + conteudo + '") format("woff2");'
    # O CSS minificado pode encerrar src com }, sem ponto e vírgula.
    # Nunca consumir o fechamento da regra nem o @font-face seguinte.
    css = re.sub(r"src:[^;}]+;?", fonte_local, css)
    css += (RAIZ / "interface/matematica.css").read_text(encoding="utf-8")
    licenca = (biblioteca / "LICENSE").read_text(encoding="utf-8")
    demo += "\n<!-- KaTeX, licença MIT:\n" + licenca + "\n-->"
    javascript = (RAIZ / "interface/matematica.js").read_text(encoding="utf-8")
    return demo, css, javascript


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
             "partidos": tabela_partidos(indices),
             "paleta_demo": json.loads((RAIZ / "interface/paleta_demo.json").read_text()),
             "paleta_faixa_demo": json.loads((RAIZ / "interface/paleta_faixa_demo.json").read_text()),
             "csv": "data:text/csv;charset=utf-8;base64," + base64.b64encode(
                 (RAIZ / "resultados/indices_uf_cargo.csv").read_bytes()).decode("ascii")}
    texto = json.dumps(dados, ensure_ascii=False, allow_nan=False, separators=(",", ":")).replace("<", "\\u003c")
    template = (RAIZ / "interface/painel.html").read_text(encoding="utf-8")
    demo, css, javascript = matematica_offline()
    for marcador, conteudo in (("__MATEMATICA_HTML__", demo), ("__MATEMATICA_CSS__", css),
                              ("__MATEMATICA_JS__", javascript)):
        assert template.count(marcador) == 1
        template = template.replace(marcador, conteudo)
    assert template.count("__DADOS__") == 1
    destino = RAIZ / "resultados/painel.html"
    destino.write_text(template.replace("__DADOS__", texto), encoding="utf-8")
    print(f"Painel offline gerado: {destino} ({destino.stat().st_size:,} bytes)")


if __name__ == "__main__":
    montar()
