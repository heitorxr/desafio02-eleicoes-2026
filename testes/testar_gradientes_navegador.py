"""Regressão da migração: gradiente angular real e barra linear, sem fatias."""
from pathlib import Path
import base64
import json
import os
import xml.etree.ElementTree as ET
from playwright.sync_api import sync_playwright

RAIZ = Path(__file__).resolve().parents[1]
SCRATCH = Path(os.environ['LOCALAPPDATA']) / 'hermes/cache/scratch/desafio02'
SCRATCH.mkdir(parents=True, exist_ok=True)
SVG = '{http://www.w3.org/2000/svg}'

def imagens_svg(caminho):
    return [next(v for k,v in e.attrib.items() if k.endswith('href'))
            for e in ET.parse(caminho).getroot().iter(SVG+'image')]

with sync_playwright() as p:
    browser = p.chromium.launch(executable_path='C:/Program Files/Google/Chrome/Application/chrome.exe', headless=True)
    context = browser.new_context(viewport={'width':1440,'height':1080}, offline=True)
    page = context.new_page()
    page.goto((RAIZ/'resultados/painel.html').as_uri())
    assert page.locator('#autoria-projeto').count() == 1, 'Falta a identificação do autor'
    assert page.locator('#autoria-projeto').inner_text() == 'Autor: Heitor Cardoso Fernandes'
    page.locator('#aba-matematica').click()
    assert page.locator('#demo-faixa polygon').count() == 0, 'A faixa não deve mais usar quadriláteros'
    gradiente = page.locator('#demo-gradiente').get_attribute('href')
    assert gradiente.startswith('data:image/png;base64,')
    assert base64.b64decode(gradiente.split(',',1)[1]) == (RAIZ/'resultados/gradiente_angular.png').read_bytes()
    assert page.locator('#recorte-faixa-demo path').get_attribute('d').count('A') == 2
    equacoes = page.locator('#matematica .equacao').evaluate_all("els => els.map(e=>e.dataset.tex).join(' ')")
    assert 'F_j' not in equacoes and 'n_j' not in equacoes
    texto = page.locator('.texto-matematica').inner_text()
    assert 'gosto do tema' in texto and 'visualização de dados estatísticos' in texto
    dados = json.loads(page.locator('#dados').text_content())
    for uf in dados['estados']:
        assert len(imagens_svg(RAIZ/f'resultados/detalhes/{uf}.svg')) == 5, uf
    barra = imagens_svg(RAIZ/'resultados/cartograma_brasil.svg')
    assert len(barra) == 1, 'O mapa deve ter uma única imagem de gradiente para a barra'
    assert barra[0].startswith('data:image/png;base64,')
    amostrar = '''async ({url,angular}) => {
      const img=new Image(); img.src=url; await img.decode();
      const c=document.createElement('canvas');c.width=img.width;c.height=img.height;
      const ctx=c.getContext('2d');ctx.drawImage(img,0,0);
      const valores=[0,2.5,5,7.5,10];
      return valores.map(n=>{
        const a=Math.PI*(1-n/10);
        const x=angular?(.92*Math.cos(a)+1)/2:n/10;
        const y=angular?1-.92*Math.sin(a):.5;
        return Array.from(ctx.getImageData(Math.min(c.width-1,Math.floor(x*c.width)),Math.min(c.height-1,Math.floor(y*c.height)),1,1).data);
      });
    }'''
    for url, angular in ((gradiente,True),(barra[0],False)):
        pixels = page.evaluate(amostrar, {'url':url,'angular':angular})
        for n, pixel in zip((0,25,50,75,100),pixels):
            esperado = dados['paleta_demo'][n].lstrip('#')
            canais = [int(esperado[i:i+2],16) for i in (0,2,4)]
            assert pixel[3] >= 250 and all(abs(a-b)<=4 for a,b in zip(pixel[:3],canais)), (angular,n,pixel,canais)
    page.locator('#laboratorio-face').screenshot(path=str(SCRATCH/'gradiente_demo.png'))
    context.close()
    browser.close()
print('OK: autoria, explicação atualizada, 27 painéis com gradientes, arcos e cores angular/linear nos cinco pontos de controle.')
