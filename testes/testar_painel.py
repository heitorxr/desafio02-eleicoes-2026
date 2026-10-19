"""Painel portátil com índices conciliados e referência partidária sem imputação."""
from pathlib import Path
from html.parser import HTMLParser
import base64
import csv
import json
import subprocess
import sys
import unicodedata
import xml.etree.ElementTree as ET

RAIZ = Path(__file__).resolve().parents[1]
script = RAIZ / "scripts/montar_painel.py"
assert script.exists(), "Falta o empacotador do painel offline"
subprocess.run([sys.executable, str(script)], check=True, cwd=RAIZ)

class Pagina(HTMLParser):
    def __init__(self):
        super().__init__()
        self.dados, self.coletando, self.externos = [], False, []
    def handle_starttag(self, tag, atributos):
        a = dict(atributos)
        if tag == "script" and a.get("id") == "dados": self.coletando = True
        if tag in ("img", "script", "link"):
            src = a.get("src", a.get("href", ""))
            if src and not src.startswith("data:"): self.externos.append(src)
    def handle_data(self, texto):
        if self.coletando: self.dados.append(texto)
    def handle_endtag(self, tag):
        if tag == "script": self.coletando = False

pagina = Pagina()
html = (RAIZ / "resultados/painel.html").read_text(encoding="utf-8")
assert 'id="aba-contas"' not in html, "Explicação dos complexos deve ficar apenas no apoio ao vídeo"
pagina.feed(html)
dados = json.loads("".join(pagina.dados))
assert 'id="partidos-sem-nota"' not in html and 'id="lista-partidos-sem-nota"' not in html
assert 'id="tabela-partidos"' in html
def chave_partido(texto):
    return unicodedata.normalize("NFKD", texto).encode("ascii", "ignore").decode().strip().upper()
with (RAIZ / "dados/referencia/ideologia_partidos.csv").open(encoding="utf-8-sig", newline="") as arquivo:
    referencia_partidos = {chave_partido(r["sigla"]): r for r in csv.DictReader(arquivo)}
lacunas_partidos = {chave_partido(p) for estado in dados["estados"].values() for r in estado["indices"]
                   for p in r["partidos_sem_nota"].split(",") if p.strip()}
partidos = {p["chave"]: p for p in dados["partidos"]}
assert len(partidos) == len(dados["partidos"]), "Sigla duplicada por grafia/acentuação"
assert set(partidos) == set(referencia_partidos) | lacunas_partidos
for chave, p in partidos.items():
    fonte = referencia_partidos.get(chave)
    if fonte and fonte["nota"] not in ("", "NA"):
        assert p["nota"] == float(fonte["nota"]) and p["ano"] == 2022
        assert p["sigla"] == fonte["sigla"]
    else:
        assert p["nota"] is None and p["ano"] is None
assert not pagina.externos, pagina.externos
assert len(dados["estados"]) == 27
assert len(dados["centros"]) == 27
assert 'id="aba-leitura"' not in html and 'id="leitura"' not in html
assert 'id="guia-chernoff"' in html
assert html.count('id="aspecto-comparacao"') == 1, "As demonstrações devem compartilhar uma única área"
cargos = {"presidente", "governador", "senador", "federal", "estadual"}
assert set(dados["comparacoes"]) == cargos
dimensoes = set()
for cargo, comparacao in dados["comparacoes"].items():
    svg = base64.b64decode(comparacao["imagem"].split(",", 1)[1])
    arvore = ET.fromstring(svg)
    assert arvore.tag.endswith("svg")
    dimensoes.add((arvore.get("width"), arvore.get("height"), arvore.get("viewBox")))
    assert svg == (RAIZ / f"resultados/comparacao_{cargo}.svg").read_bytes()
    reais = sorted((i["nota"], uf) for uf, estado in dados["estados"].items()
                   for i in estado["indices"] if i["cargo"] == cargo and i["nota"] is not None)
    esperados = [reais[0], reais[len(reais) // 2], reais[-1]]
    assert len(comparacao["exemplos"]) == len(esperados)
    for exemplo, (nota, uf) in zip(comparacao["exemplos"], esperados):
        assert exemplo["uf"] == uf and abs(exemplo["nota"] - nota) < 1e-12
assert len(dimensoes) == 1, "As cinco imagens devem ocupar o mesmo espaço"
assert sum(len(x["indices"]) for x in dados["estados"].values()) == 135
na = {(uf, i["cargo"]) for uf, x in dados["estados"].items() for i in x["indices"] if i["nota"] is None}
assert not na, "Todos os 135 índices devem estar conciliados após recuperação de RO"
for x in dados["estados"].values():
    assert len(x["indices"]) == 5
    svg = base64.b64decode(x["imagem"].split(",", 1)[1])
    assert ET.fromstring(svg).tag.endswith("svg")
assert all(0 < x["x"] < 100 and 0 < x["y"] < 100 for x in dados["centros"])
print(f"OK: painel offline com 27 UFs, 135 índices e {len(partidos)} siglas; notas e lacunas preservadas.")
