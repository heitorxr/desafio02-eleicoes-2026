"""Recupera RO pelo voto por seção e destinação oficial; não infere partido pelo número."""
from pathlib import Path
import csv
import io
import json
import collections
import zipfile
from baixar_tse import baixar

RAIZ = Path(__file__).resolve().parents[1]
BRUTOS = RAIZ / 'dados/brutos'
FONTES = {
 'votacao_secao_2026_RO.zip': 'https://cdn.tse.jus.br/estatistica/sead/odsele/votacao_secao/votacao_secao_2026_RO.zip',
 'consulta_cand_2026.zip': 'https://cdn.tse.jus.br/estatistica/sead/odsele/consulta_cand/consulta_cand_2026.zip',
 'consulta_cand_complementar_2026.zip': 'https://cdn.tse.jus.br/estatistica/sead/odsele/consulta_cand_complementar/consulta_cand_complementar_2026.zip',
}
CARGOS = {'6':'federal', '7':'estadual'}


def linhas(arquivo, membro):
    with zipfile.ZipFile(BRUTOS / arquivo) as z:
        with io.TextIOWrapper(z.open(membro), encoding='latin1') as f:
            yield from csv.DictReader(f, delimiter=';')


def reconstruir():
    for arquivo, url in FONTES.items():
        baixar(arquivo, url)
    cad = {}
    for r in linhas('consulta_cand_2026.zip', 'consulta_cand_2026_RO.csv'):
        if (r['ANO_ELEICAO'],r['NR_TURNO'],r['CD_TIPO_ELEICAO'],r['SG_UF']) != ('2026','1','2','RO') or r['CD_CARGO'] not in CARGOS:
            continue
        k = (r['CD_ELEICAO'],r['SQ_CANDIDATO'])
        assert k not in cad
        cad[k] = {c:r[c] for c in ('CD_CARGO','NR_CANDIDATO','NR_PARTIDO','SG_PARTIDO')}
    destinos = {}
    for r in linhas('consulta_cand_complementar_2026.zip', 'consulta_cand_complementar_2026_RO.csv'):
        k = (r['CD_ELEICAO'],r['SQ_CANDIDATO'])
        if k in cad:
            assert k not in destinos
            destinos[k] = r['NM_TIPO_DESTINACAO_VOTOS']
    nominais, excluidos, legenda = collections.Counter(), collections.Counter(), collections.Counter()
    for r in linhas('votacao_secao_2026_RO.zip','votacao_secao_2026_RO.csv'):
        if (r['ANO_ELEICAO'],r['NR_TURNO'],r['CD_TIPO_ELEICAO'],r['SG_UF']) != ('2026','1','2','RO') or r['CD_CARGO'] not in CARGOS:
            continue
        if len(r['NR_VOTAVEL']) <= 2:  # Legenda/brancos/nulos não são nominais.
            continue
        k = (r['CD_ELEICAO'],r['SQ_CANDIDATO'])
        c = cad[k]
        assert c['NR_CANDIDATO'] == r['NR_VOTAVEL'] and c['CD_CARGO'] == r['CD_CARGO']
        destino = destinos[k]
        if destino == 'Válido':
            nominais[(CARGOS[r['CD_CARGO']],c['SG_PARTIDO'])] += int(r['QT_VOTOS'])
        else:
            assert destino in ('Anulado','Anulado sub judice','Nulo técnico'), destino
            excluidos[(CARGOS[r['CD_CARGO']],destino)] += int(r['QT_VOTOS'])
    for r in linhas('votacao_partido_munzona_2026.zip','votacao_partido_munzona_2026_RO.csv'):
        if r['NR_TURNO'] == '1' and r['CD_CARGO'] in CARGOS:
            assert int(r['QT_VOTOS_NOMINAIS_VALIDOS']) == 0, 'Fonte original mudou; reavaliar recuperação.'
            legenda[(CARGOS[r['CD_CARGO']],r['SG_PARTIDO'])] += int(r['QT_TOTAL_VOTOS_LEG_VALIDOS'])
    resultado = []
    for cargo, sigla in sorted(nominais.keys() | legenda.keys()):
        k = (cargo,sigla)
        resultado.append(dict(uf='RO',cargo=cargo,sigla=sigla,votos=nominais[k]+legenda[k],
                              nominais_validos=nominais[k],legenda_valida=legenda[k]))
    with (RAIZ/'dados/entrada/totais_uf_cargo.csv').open(encoding='utf-8') as f:
        totais = {r['cargo']:int(r['QT_TOTAL_VOTOS_VALIDOS']) for r in csv.DictReader(f) if r['uf']=='RO'}
    for cargo in CARGOS.values():
        assert sum(r['votos'] for r in resultado if r['cargo']==cargo) == totais[cargo], cargo
    arquivo = RAIZ/'dados/entrada/ro_votos_reconstruidos.csv'
    with arquivo.open('w',encoding='utf-8',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(resultado[0]));w.writeheader();w.writerows(resultado)
    auditoria = [dict(cargo=c,destinacao=d,votos=v) for (c,d),v in sorted(excluidos.items())]
    (RAIZ/'dados/entrada/ro_nominais_excluidos.json').write_text(json.dumps(auditoria,ensure_ascii=False,indent=2),encoding='utf-8')
    print('RO reconstruído: dois totais idênticos ao detalhe oficial; anulados/sub judice/nulos técnicos excluídos.')


if __name__ == '__main__':
    reconstruir()
