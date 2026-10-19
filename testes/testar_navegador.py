"""QA real no Chromium instalado; executar com uv run --with playwright python ..."""
from pathlib import Path
import csv
import os
from playwright.sync_api import sync_playwright

RAIZ = Path(__file__).resolve().parents[1]
SCRATCH = Path(os.environ["LOCALAPPDATA"]) / "hermes/cache/scratch/desafio02"
SCRATCH.mkdir(parents=True, exist_ok=True)
for variavel in ("TMPDIR", "TMP", "TEMP"):
    os.environ[variavel] = str(SCRATCH)
NAVEGADORES = [Path("C:/Program Files/Google/Chrome/Application/chrome.exe"),
              Path("C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe")]
exe = next(p for p in NAVEGADORES if p.exists())
def caixa_comparacao(page):
    # Cliques podem rolar a página: comparar posição no documento, não na viewport.
    return page.locator("#demonstracao-aspecto").evaluate("el => {const r=el.getBoundingClientRect();return {x:r.left+scrollX,y:r.top+scrollY,width:r.width,height:r.height}}")

with sync_playwright() as p:
    browser = p.chromium.launch(executable_path=str(exe), headless=True)
    context = browser.new_context(viewport={"width": 1440, "height": 1080}, device_scale_factor=1,
                                  accept_downloads=True)
    page = context.new_page()
    erros = []
    page.on("pageerror", lambda erro: erros.append(str(erro)))
    page.goto((RAIZ / "resultados/painel.html").as_uri(), wait_until="load")
    page.wait_for_function("document.getElementById('gauges').complete")
    assert page.locator(".uf-hit").count() == 27
    assert page.locator("#nome-uf").inner_text() == "Paraná / PR"
    legenda = page.locator("#legenda-face")
    assert legenda.is_visible()
    assert legenda.locator("dt").count() == 5
    assert page.locator("#aba-leitura").count() == 0
    assert page.locator("#guia-chernoff").is_visible()
    assert page.locator(".aspecto-titulo").count() == 5
    assert page.locator("#aspecto-comparacao").count() == 1
    referencia = caixa_comparacao(page)
    tabela_antes = page.locator("#valores").inner_text()
    for cargo in ("presidente", "governador", "senador", "federal", "estadual"):
        botao = page.locator(f'.aspecto-titulo[data-aspecto="{cargo}"]')
        botao.click()
        page.wait_for_function("document.getElementById('aspecto-comparacao').complete && document.getElementById('aspecto-comparacao').naturalWidth > 0")
        assert botao.get_attribute("aria-pressed") == "true"
        assert page.locator('.aspecto-titulo[aria-pressed="true"]').count() == 1
        assert page.locator("#demonstracao-aspecto").get_attribute("data-aspecto") == cargo
        atual = caixa_comparacao(page)
        assert all(abs(atual[k] - referencia[k]) < 1 for k in ("x", "y", "width", "height"))
        assert page.locator("#valores").inner_text() == tabela_antes
        page.locator("#demonstracao-aspecto").screenshot(path=str(SCRATCH / f"aspecto_{cargo}.png"))
    page.locator('.aspecto-titulo[data-aspecto="federal"]').focus()
    page.keyboard.press("Enter")
    assert page.locator("#demonstracao-aspecto").get_attribute("data-aspecto") == "federal"
    assert page.evaluate("document.getElementById('legenda-face').getBoundingClientRect().top >= document.getElementById('mapa-wrap').getBoundingClientRect().bottom")
    page.screenshot(path=str(SCRATCH / "painel_desktop.png"), full_page=True)
    ufs = page.locator(".uf-hit").evaluate_all("els => els.map(x=>x.dataset.uf)")
    for uf in ufs:
        page.locator(f'.uf-hit[data-uf="{uf}"]').click()
        assert page.locator("#uf").input_value() == uf
        assert page.locator("#valores tr").count() == 5
        assert page.locator(f'.uf-hit[data-uf="{uf}"]').get_attribute("aria-pressed") == "true"
    page.locator('.uf-hit[data-uf="RO"]').click()
    assert page.locator('#valores tr[data-cargo="federal"] td').nth(1).inner_text() != "—"
    assert page.locator('#valores tr[data-cargo="estadual"] td').nth(1).inner_text() != "—"
    assert "indisponíveis" not in page.locator("#aviso").inner_text()
    page.screenshot(path=str(SCRATCH / "painel_rondonia.png"), full_page=True)
    with page.expect_download() as download:
        page.locator("#baixar").click()
    assert Path(download.value.path()).read_bytes() == (RAIZ / "resultados/indices_uf_cargo.csv").read_bytes()
    for aba in ("fontes", "explorar"):
        page.locator(f"#aba-{aba}").click()
        assert page.locator(f"#{aba}").is_visible()
        assert page.locator('[role="tabpanel"]:visible').count() == 1
    assert page.locator("#aba-contas").count() == 0
    page.set_viewport_size({"width": 390, "height": 844})
    for aba in ("explorar", "fontes"):
        page.locator(f"#aba-{aba}").click()
        assert page.evaluate("document.documentElement.scrollWidth <= window.innerWidth + 1"), f"Transbordamento: {aba}"
    page.locator("#aba-explorar").click()
    referencia_mobile = caixa_comparacao(page)
    for cargo in ("presidente", "governador", "senador", "federal", "estadual"):
        page.locator(f'.aspecto-titulo[data-aspecto="{cargo}"]').click()
        atual = caixa_comparacao(page)
        assert all(abs(atual[k] - referencia_mobile[k]) < 1 for k in ("width", "height"))
        assert page.evaluate("document.documentElement.scrollWidth <= window.innerWidth + 1")
    page.screenshot(path=str(SCRATCH / "painel_mobile.png"), full_page=True)
    assert not erros, erros
    context.close()
    browser.close()
print("OK: 27 UFs, cinco demonstrações no mesmo espaço, teclado, duas abas e layout móvel; nenhum erro JavaScript.")
print(f"Capturas verificáveis: {SCRATCH}")
