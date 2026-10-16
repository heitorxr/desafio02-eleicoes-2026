"""Obtém somente o membro RO do ZIP oficial, por HTTP Range, sem baixar o Brasil inteiro."""
from pathlib import Path
from datetime import datetime, timezone
import csv
import hashlib
import io
import json
import urllib.request
import zipfile

URL = "https://cdn.tse.jus.br/estatistica/sead/odsele/votacao_candidato_munzona/votacao_candidato_munzona_2026.zip"
RAIZ = Path(__file__).resolve().parents[1]


class ArquivoRemoto(io.RawIOBase):
    def __init__(self):
        self.posicao = 0
        r = urllib.request.urlopen(urllib.request.Request(URL, method="HEAD"), timeout=30)
        self.tamanho = int(r.headers["Content-Length"])
        self.etag = r.headers.get("ETag")
        self.modificado = r.headers.get("Last-Modified")

    def seekable(self):
        return True

    def readable(self):
        return True

    def tell(self):
        return self.posicao

    def seek(self, deslocamento, origem=0):
        self.posicao = (deslocamento if origem == 0 else self.posicao + deslocamento
                        if origem == 1 else self.tamanho + deslocamento)
        return self.posicao

    def read(self, tamanho=-1):
        tamanho = self.tamanho - self.posicao if tamanho < 0 else min(tamanho, self.tamanho - self.posicao)
        if tamanho <= 0:
            return b""
        fim = self.posicao + tamanho - 1
        pedido = urllib.request.Request(URL, headers={"Range": f"bytes={self.posicao}-{fim}"})
        with urllib.request.urlopen(pedido, timeout=90) as r:
            if r.status != 206:
                raise RuntimeError("Servidor não respeitou a leitura parcial")
            if r.headers.get("ETag") != self.etag:
                raise RuntimeError("O arquivo oficial mudou durante a coleta")
            bloco = r.read()
        self.posicao += len(bloco)
        return bloco


if __name__ == "__main__":
    membro = "votacao_candidato_munzona_2026_RO.csv"
    destino = RAIZ / "dados" / "brutos" / membro
    if destino.exists():
        raise SystemExit("Fonte RO já preservada; não sobrescrever.")
    remoto = ArquivoRemoto()
    with zipfile.ZipFile(remoto) as z:
        conteudo = z.read(membro)  # zipfile valida o CRC do membro.
        crc = z.getinfo(membro).CRC
    destino.write_bytes(conteudo)
    metadados = dict(url=URL, membro=membro, crc32=crc, sha256=hashlib.sha256(conteudo).hexdigest(),
                     etag=remoto.etag, last_modified=remoto.modificado,
                     coleta_utc=datetime.now(timezone.utc).isoformat())
    destino.with_suffix(".csv.json").write_text(json.dumps(metadados, indent=2), encoding="utf-8")
    registros = list(csv.DictReader(io.StringIO(conteudo.decode("latin1")), delimiter=";"))
    print("Linhas preservadas:", len(registros))
    print("Cargos:", sorted(set(x["DS_CARGO"] for x in registros)))
    print("Primeira linha:", registros[0])
