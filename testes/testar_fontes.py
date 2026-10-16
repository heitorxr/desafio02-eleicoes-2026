"""Verificações independentes das fontes; não cria nem substitui dados eleitorais."""
from pathlib import Path
from html.parser import HTMLParser
import csv
import hashlib
import json

RAIZ = Path(__file__).resolve().parents[1]


class Tabelas(HTMLParser):
    def __init__(self):
        super().__init__()
        self.linhas, self.linha, self.celula = [], None, None

    def handle_starttag(self, tag, attrs):
        if tag == "tr": self.linha = []
        if tag in ("td", "th"): self.celula = []

    def handle_data(self, texto):
        if self.celula is not None: self.celula.append(texto)

    def handle_endtag(self, tag):
        if tag in ("td", "th") and self.celula is not None:
            if self.linha is not None: self.linha.append(" ".join("".join(self.celula).split()))
            self.celula = None
        if tag == "tr" and self.linha is not None:
            self.linhas.append(self.linha)
            self.linha = None


p = Tabelas()
p.feed((RAIZ / "dados/brutos/artigo_ideologia_2022.html").read_text(encoding="utf-8"))
linhas = {r[0]: r for r in p.linhas if len(r) == 9 and r[0] != "Partido"}
with (RAIZ / "dados/referencia/ideologia_partidos.csv").open(encoding="utf-8", newline="") as f:
    referencias = list(csv.DictReader(f))
conhecidas = [r for r in referencias if r["nota"] != "NA"]
assert len(conhecidas) == 32
assert len({r["sigla"] for r in referencias}) == len(referencias)
for r in conhecidas:
    publicado = linhas[r["sigla_fonte"]]
    assert float(r["nota"]) == float(publicado[2])
    assert int(r["nr_2022"]) == int(publicado[4])
    assert float(r["cv_2022"]) == float(publicado[6])
    assert r["ano_fonte"] == "2022" and 0 <= float(r["nota"]) <= 10
assert next(r for r in referencias if r["sigla"] == "MISSÃO")["nota"] == "NA"
for metadado in (RAIZ / "dados/brutos").glob("*.zip.json"):
    info = json.loads(metadado.read_text(encoding="utf-8"))
    arquivo = metadado.with_suffix("")
    assert hashlib.sha256(arquivo.read_bytes()).hexdigest() == info["sha256"]
with (RAIZ / "dados/entrada/auditoria_eleitoral.csv").open(encoding="utf-8") as f:
    auditoria = list(csv.DictReader(f))
assert all(float(r["diferenca"]) == 0 for r in auditoria)
with (RAIZ / "dados/entrada/auditoria_eleitoral_original.csv").open(encoding="utf-8") as f:
    auditoria = list(csv.DictReader(f))
assert len(auditoria) == 135
falhas = {(r["uf"], r["cargo"]) for r in auditoria if float(r["diferenca"]) != 0}
assert falhas == {("RO", "federal"), ("RO", "estadual")}
print("OK: 32 notas acadêmicas, hashes oficiais, auditoria anterior preservada e 135/135 totais conciliados.")
