"""O painel deve ser portátil, íntegro e conter 135 índices reais, inclusive dois NA."""
from pathlib import Path
from html.parser import HTMLParser
import base64
import csv
import json
import subprocess
import sys
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
assert not pagina.externos, pagina.externos
assert len(dados["estados"]) == 27
assert len(dados["centros"]) == 27
assert 'id="narizes-comparacao"' in html, "Falta a comparação ampliada de narizes reais"
narizes_svg = base64.b64decode(dados["narizes"].split(",", 1)[1])
assert ET.fromstring(narizes_svg).tag.endswith("svg")
assert narizes_svg == (RAIZ / "resultados/comparacao_narizes.svg").read_bytes()
federais = sorted((i["nota"], uf) for uf, estado in dados["estados"].items()
                  for i in estado["indices"] if i["cargo"] == "federal" and i["nota"] is not None)
with (RAIZ / "resultados/comparacao_narizes.csv").open(encoding="utf-8-sig", newline="") as arquivo:
    exemplos = list(csv.DictReader(arquivo))
esperados = [federais[0], federais[len(federais) // 2], federais[-1]]
assert len(exemplos) == len(esperados)
for exemplo, (nota, uf) in zip(exemplos, esperados):
    assert exemplo["uf"] == uf and abs(float(exemplo["nota"]) - nota) < 1e-12
assert sum(len(x["indices"]) for x in dados["estados"].values()) == 135
na = {(uf, i["cargo"]) for uf, x in dados["estados"].items() for i in x["indices"] if i["nota"] is None}
assert not na, "Todos os 135 índices devem estar conciliados após recuperação de RO"
for x in dados["estados"].values():
    assert len(x["indices"]) == 5
    svg = base64.b64decode(x["imagem"].split(",", 1)[1])
    assert ET.fromstring(svg).tag.endswith("svg")
assert all(0 < x["x"] < 100 and 0 < x["y"] < 100 for x in dados["centros"])
print("OK: painel autossuficiente com 27 SVGs e 135 índices oficiais, sem transformar NA em zero.")
