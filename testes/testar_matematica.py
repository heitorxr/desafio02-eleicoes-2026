"""Demo offline: TeX renderizado, sliders e paridade numérica com o desenho em R."""
from pathlib import Path
import json
import math
import os
import subprocess
from playwright.sync_api import sync_playwright

RAIZ = Path(__file__).resolve().parents[1]
SCRATCH = Path(os.environ['LOCALAPPDATA']) / 'hermes/cache/scratch/desafio02'
SCRATCH.mkdir(parents=True, exist_ok=True)
RSCRIPT = Path('D:/Program Files/R/R-4.5.2/bin/Rscript.exe')
subprocess.run([str(RSCRIPT), 'testes/exportar_demo.R', str(SCRATCH / 'referencia_demo.json')], cwd=RAIZ, check=True)
referencia = json.loads((SCRATCH / 'referencia_demo.json').read_text(encoding='utf-8'))
assert json.loads((RAIZ / 'interface/paleta_demo.json').read_text()) == referencia['paleta']
assert json.loads((RAIZ / 'interface/paleta_faixa_demo.json').read_text()) == referencia['faixa']

def perto(real, esperado):
    if isinstance(esperado, dict):
        assert set(real) >= set(esperado)
        for k, v in esperado.items():
            perto(real[k], v)
    elif isinstance(esperado, list):
        assert len(real) == len(esperado)
        for a, b in zip(real, esperado):
            perto(a, b)
    elif isinstance(esperado, str):
        assert real == esperado
    else:
        assert math.isfinite(real) and abs(real - esperado) < 1e-11, (real, esperado)

with sync_playwright() as p:
    exe = next(x for x in [Path('C:/Program Files/Google/Chrome/Application/chrome.exe'), Path('C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe')] if x.exists())
    browser = p.chromium.launch(executable_path=str(exe), headless=True)
    context = browser.new_context(viewport={'width': 1440, 'height': 1080}, offline=True)
    page = context.new_page()
    erros, rede = [], []
    page.on('pageerror', lambda e: erros.append(str(e)))
    page.on('request', lambda r: rede.append(r.url) if r.url.startswith(('http:', 'https:')) else None)
    page.goto((RAIZ / 'resultados/painel.html').as_uri())
    assert page.locator('[role=tab]').all_text_contents() == ['Explorar', 'Matemática', 'Mais informações']
    page.locator('#aba-matematica').click()
    assert page.locator('#matematica').is_visible()
    assert page.locator('#matematica input[type=range]').count() == 5
    assert page.locator('#matematica .katex').count() >= 15
    assert page.locator('#matematica .katex-error').count() == 0
    assert page.locator('#matematica .equacao math').count() == page.locator('#matematica .equacao').count()
    inline = page.locator('#matematica .mat-inline')
    assert inline.count() >= 15, 'As variáveis dentro dos parágrafos também precisam de TeX'
    assert inline.locator('.katex-display').count() == 0, 'Matemática no texto não deve virar um bloco separado'
    assert inline.locator('math').count() == inline.count()
    for expressao in ('t', 's', 'u', 'K', 'v_p', 'a_p'):
        assert page.locator(f'.texto-matematica p .mat-inline[data-tex="{expressao}"]').count() >= 1, expressao
    assert page.locator('.texto-matematica p .mat-inline[data-tex="a_p"] .katex').count() == 1
    inline_antes = inline.count()
    page.evaluate('document.fonts.ready')
    assert page.evaluate("document.fonts.check('16px KaTeX_Main')")
    dados_antes = page.locator('#dados').text_content()
    assert page.locator('#demo-faixa polygon').count() == 0
    assert page.locator('#demo-gradiente').get_attribute('href').startswith('data:image/png;base64,')
    for caso in referencia['casos']:
        real = page.evaluate('(notas) => geometriaDemo(notas)', caso['notas'])
        perto(real, {k: v for k, v in caso.items() if k != 'notas'})
        for cargo, nota in caso['notas'].items():
            page.locator(f'#slider-{cargo}').evaluate('(el,v) => {el.value=v;el.dispatchEvent(new Event("input",{bubbles:true}))}', nota)
        assert page.locator('#demo-cor').get_attribute('fill') == caso['cor']
        pontos = page.locator('#demo-nariz').get_attribute('points').split()
        assert len(pontos) == len(caso['nariz']['x'])
        for texto, x, y in zip(pontos, caso['nariz']['x'], caso['nariz']['y']):
            px, py = map(float, texto.split(','))
            perto(px, x)
            perto(py, y)
    page.locator('#demo-reiniciar').click()
    assert all(el.input_value() == '5' for el in page.locator('#matematica input[type=range]').all())
    antes = page.locator('#demo-olhos').inner_html()
    page.locator('#slider-federal').focus()
    page.keyboard.press('End')
    assert page.locator('#slider-federal').input_value() == '10'
    assert page.locator('#valor-federal').inner_text() == '10,0'
    assert page.locator('#demo-olhos').inner_html() == antes
    assert page.locator('#dados').text_content() == dados_antes
    page.locator('#demo-reiniciar').click()
    assert inline.count() == inline_antes and inline.locator('math').count() == inline_antes
    page.locator('#laboratorio-face').screenshot(path=str(SCRATCH / 'matematica_demo_desktop.png'))
    for largura in (390, 320):
        page.set_viewport_size({'width': largura, 'height': 844})
        assert page.evaluate('document.documentElement.scrollWidth <= innerWidth + 1'), largura
        for equacao in page.locator('#matematica .equacao').all():
            assert equacao.evaluate('el => el.clientWidth <= innerWidth'), largura
    page.set_viewport_size({'width': 390, 'height': 844})
    page.locator('#slider-estadual').scroll_into_view_if_needed()
    assert page.locator('#rosto-demo').evaluate('el => {const r=el.getBoundingClientRect();return r.top>=0 && r.bottom<=innerHeight}'), 'O rosto precisa continuar visível ao mover o último slider no celular'
    page.screenshot(path=str(SCRATCH / 'matematica_interacao_mobile.png'))
    page.locator('#laboratorio-face').screenshot(path=str(SCRATCH / 'matematica_demo_mobile.png'))
    page.locator('.texto-matematica').screenshot(path=str(SCRATCH / 'matematica_formulas.png'))
    page.set_viewport_size({'width':1440,'height':1080})
    page.locator('.texto-matematica section').nth(3).screenshot(path=str(SCRATCH / 'matematica_formula_nariz.png'))
    page.locator('.texto-matematica section').first.screenshot(path=str(SCRATCH / 'matematica_variaveis_inline.png'))
    page.locator('.texto-matematica section').last.screenshot(path=str(SCRATCH / 'matematica_media_inline.png'))
    assert not erros and not rede, (erros, rede)
    context.close()
    toque = browser.new_context(viewport={'width':390,'height':844},has_touch=True,is_mobile=True,offline=True)
    tela = toque.new_page()
    tela.goto((RAIZ / 'resultados/painel.html').as_uri())
    tela.locator('#aba-matematica').tap()
    slider = tela.locator('#slider-presidente')
    slider.scroll_into_view_if_needed()
    caixa = slider.bounding_box()
    tela.touchscreen.tap(caixa['x']+.8*caixa['width'],caixa['y']+caixa['height']/2)
    assert float(slider.input_value()) > 5
    assert tela.locator('#demo-cor').get_attribute('fill') != referencia['paleta'][50]
    toque.close()
    browser.close()
print(f'OK: {len(referencia["casos"])} casos comparados ao R; TeX offline, cinco sliders, teclado, reset e layout até 320 px.')
