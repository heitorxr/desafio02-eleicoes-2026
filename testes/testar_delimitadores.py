"""Regressão dos delimitadores altos: a chave precisa abranger as duas linhas."""
from pathlib import Path
from playwright.sync_api import sync_playwright
RAIZ = Path(__file__).resolve().parents[1]
with sync_playwright() as p:
    browser = p.chromium.launch(executable_path='C:/Program Files/Google/Chrome/Application/chrome.exe', headless=True)
    page = browser.new_page(viewport={'width':1440,'height':1080})
    page.goto((RAIZ/'resultados/painel.html').as_uri())
    page.locator('#aba-matematica').click()
    page.evaluate('document.fonts.ready')
    eq = page.locator('.equacao').filter(has_text='C(t)').first
    fontes = page.evaluate('Array.from(document.fonts).map(f=>({family:f.family,status:f.status}))')
    css = (RAIZ/'node_modules/katex/dist/katex.min.css').read_text(encoding='utf-8')
    assert len(fontes) == css.count('@font-face'), 'O empacotamento não pode apagar regras de fontes do KaTeX'
    assert any(f['family']=='KaTeX_Size4' and f['status']=='loaded' for f in fontes)
    assert 'KaTeX_Main' in eq.locator('.katex').evaluate('el=>getComputedStyle(el).fontFamily')
    chave = eq.locator('.katex-html .delimsizing').bounding_box()
    tabela = eq.locator('.katex-html .mtable').bounding_box()
    assert chave['height'] >= tabela['height']*.9, 'A chave precisa acompanhar a altura dos dois casos'
    eq.screenshot(path='C:/Users/heito/AppData/Local/hermes/cache/scratch/desafio02/chave_verificacao.png')
    browser.close()
print('OK: fontes KaTeX preservadas e chave com altura suficiente para os dois casos.')
