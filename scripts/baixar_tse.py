"""Baixa arquivos oficiais sem alterar uma coleta já congelada."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json
import urllib.request
import zipfile

RAIZ = Path(__file__).resolve().parents[1]
BRUTOS = RAIZ / "dados" / "brutos"
BRUTOS.mkdir(parents=True, exist_ok=True)
FONTES = {
    "votacao_partido_munzona_2026.zip": "https://cdn.tse.jus.br/estatistica/sead/odsele/votacao_partido_munzona/votacao_partido_munzona_2026.zip",
    "detalhe_votacao_munzona_2026.zip": "https://cdn.tse.jus.br/estatistica/sead/odsele/detalhe_votacao_munzona/detalhe_votacao_munzona_2026.zip",
}


def baixar(nome, url):
    destino = BRUTOS / nome
    metadados = BRUTOS / (nome + ".json")
    if destino.exists():
        if not metadados.exists():
            raise RuntimeError(f"Arquivo sem metadados: {destino}")
        registro = json.loads(metadados.read_text(encoding="utf-8"))
        resumo = hashlib.sha256(destino.read_bytes()).hexdigest()
        if resumo != registro["sha256"]:
            raise RuntimeError(f"Arquivo modificado: {destino}")
        print("Coleta preservada:", nome)
        return
    temporario = destino.with_suffix(".part")
    digest = hashlib.sha256()
    with urllib.request.urlopen(url, timeout=120) as resposta, temporario.open("wb") as saida:
        registro = {"url": url, "coleta_utc": datetime.now(timezone.utc).isoformat(),
                    "last_modified": resposta.headers.get("Last-Modified"),
                    "etag": resposta.headers.get("ETag")}
        while bloco := resposta.read(1024 * 1024):
            saida.write(bloco)
            digest.update(bloco)
    with zipfile.ZipFile(temporario) as arquivo:
        if arquivo.testzip() is not None:
            raise RuntimeError("ZIP inválido")
        registro["arquivos"] = arquivo.namelist()
    temporario.replace(destino)
    registro.update(sha256=digest.hexdigest(), bytes=destino.stat().st_size)
    metadados.write_text(json.dumps(registro, ensure_ascii=False, indent=2), encoding="utf-8")
    print("Baixado e validado:", nome, registro["bytes"], "bytes")


if __name__ == "__main__":
    for nome, url in FONTES.items():
        baixar(nome, url)
