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
    page.screenshot(path=str(SCRATCH / "painel_desktop.png"), full_page=True)
    ufs = page.locator(".uf-hit").evaluate_all("els => els.map(x=>x.dataset.uf)")
    for uf in ufs:
        page.locator(f'.uf-hit[data-uf="{uf}"]').click()
        assert page.locator("#uf").input_value() == uf
        assert page.locator("#valores tr").count() == 5
        assert page.locator(f'.uf-hit[data-uf="{uf}"]').get_attribute("aria-pressed") == "true"
    page.locator('.uf-hit[data-uf="RO"]').click()
    assert page.locator('#valores tr[data-cargo="federal"] td').nth(1).inner_text() == "—"
    assert page.locator('#valores tr[data-cargo="estadual"] td').nth(1).inner_text() == "—"
    assert "indisponíveis" in page.locator("#aviso").inner_text()
    page.screenshot(path=str(SCRATCH / "painel_rondonia.png"), full_page=True)
    with page.expect_download() as download:
        page.locator("#baixar").click()
    assert Path(download.value.path()).read_bytes() == (RAIZ / "resultados/indices_uf_cargo.csv").read_bytes()
    for aba in ("leitura", "fontes", "explorar"):
        page.locator(f"#aba-{aba}").click()
        assert page.locator(f"#{aba}").is_visible()
        assert page.locator('[role="tabpanel"]:visible').count() == 1
    assert page.locator("#aba-contas").count() == 0
    page.set_viewport_size({"width": 390, "height": 844})
    for aba in ("explorar", "leitura", "fontes"):
        page.locator(f"#aba-{aba}").click()
        assert page.evaluate("document.documentElement.scrollWidth <= window.innerWidth + 1"), f"Transbordamento: {aba}"
    page.locator("#aba-explorar").click()
    page.screenshot(path=str(SCRATCH / "painel_mobile.png"), full_page=True)
    assert not erros, erros
    context.close()
    browser.close()
print("OK: 27 seleções reais, três abas, CSV, ausências e layout móvel; nenhum erro JavaScript.")
print(f"Capturas verificáveis: {SCRATCH}")
