"""Verifica o PDF principal; a explicação técnica fica separada para o vídeo."""
from pathlib import Path
import pymupdf

raiz = Path(__file__).resolve().parents[1]
with pymupdf.open(raiz / "resultados/Figuras_desafio02.pdf") as pdf:
    assert len(pdf) == 2, "Mapa/legenda e velocímetros devem ocupar duas páginas"
    mapa, velocimetros = [p.get_text() for p in pdf]
    assert "BRASIL" in mapa and "FACES DO VOTO" in mapa
    assert "Heitor Cardoso Fernandes" in mapa
    assert "Abertura do sorriso" in mapa and "sobrancelhas" in mapa
    assert "Paraná / PR" in velocimetros
    for cargo in ("Presidência", "Governo estadual", "Senado", "Deputados federais", "Estaduais / distritais"):
        assert cargo in velocimetros
    assert "complex" not in (mapa + velocimetros).lower()
print("OK: PDF com duas páginas, mapa e legenda juntos, cinco cargos e sem explicação dos complexos.")
