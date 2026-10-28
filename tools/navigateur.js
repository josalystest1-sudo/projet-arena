// Pilote le prototype web dans un navigateur au format téléphone (Playwright + Chromium), et prend des captures.
// Sert à vérifier un écran comme Gautier le verra, sans téléphone.
//
// Usage :
//   (cd build/web && python3 -m http.server 8765)   # dans un autre terminal, après l'export web
//   node tools/navigateur.js '[{"wait":1000},{"click":[270,700]},{"shot":"accueil"}]'
//
// Étapes (coordonnées du jeu : 540 de large, comme dans Godot ; converties en pixels de la page) :
//   {"click":[x,y]}       clic de souris
//   {"tap":[x,y]}         toucher du doigt (vrais événements tactiles)
//   {"swipe":[x,y0,y1]}   glisser du doigt de y0 à y1 (pour faire défiler)
//   {"wheel":dy}          molette de souris
//   {"wait":ms}           attendre
//   {"shot":"nom"}        capture dans $OUT/nom.png
// Variables : OUT (dossier des captures, /tmp/captures par défaut), PORT (8765), H (hauteur de la page en pixels,
// 844 par défaut ; 664 pour un téléphone peu haut, barres du navigateur visibles), Q (fin d'adresse, par exemple
// "?graine=7" pour rejouer toujours les mêmes tirages).
// Le tactile s'active tout seul si une étape utilise tap ou swipe.
const fs = require('fs');
const { chromium } = require('playwright');

const steps = JSON.parse(process.argv[2] || '[]');
const OUT = process.env.OUT || '/tmp/captures';
const W = 390;
const H = parseInt(process.env.H || '844');
const SCALE = W / 540;
const touchMode = steps.some(s => s.tap || s.swipe);

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  const browser = await chromium.launch({ args: ['--use-gl=swiftshader', '--enable-unsafe-swiftshader'] });
  const context = await browser.newContext({ viewport: { width: W, height: H }, deviceScaleFactor: 2, hasTouch: touchMode, isMobile: touchMode });
  const page = await context.newPage();
  const cdp = await context.newCDPSession(page);
  const logs = [];
  page.on('console', m => logs.push(m.type() + ': ' + m.text()));
  page.on('pageerror', e => logs.push('pageerror: ' + e.message));
  await page.goto('http://localhost:' + (process.env.PORT || '8765') + '/index.html' + (process.env.Q || ''));
  await page.waitForTimeout(7000);
  const touch = (type, x, y) => cdp.send('Input.dispatchTouchEvent', { type, touchPoints: type === 'touchEnd' ? [] : [{ x, y }] });
  let shots = 0;
  for (const s of steps) {
    if (s.click) { await page.mouse.click(s.click[0] * SCALE, s.click[1] * SCALE); }
    if (s.tap) {
      await touch('touchStart', s.tap[0] * SCALE, s.tap[1] * SCALE);
      await page.waitForTimeout(60);
      await touch('touchEnd');
    }
    if (s.swipe) {
      const [x, y0, y1] = s.swipe.map(v => v * SCALE);
      await touch('touchStart', x, y0);
      for (let i = 1; i <= 12; i++) {
        await touch('touchMove', x, y0 + (y1 - y0) * i / 12);
        await page.waitForTimeout(16);
      }
      await touch('touchEnd');
      await page.waitForTimeout(400);
    }
    if (s.wheel) { await page.mouse.move(W / 2, H / 2); await page.mouse.wheel(0, s.wheel); await page.waitForTimeout(500); }
    if (s.wait) { await page.waitForTimeout(s.wait); }
    if (s.shot) { await page.screenshot({ path: `${OUT}/${s.shot}.png` }); shots++; }
  }
  console.log(logs.filter(l => /error/i.test(l)).slice(0, 20).join('\n'));
  console.log(`${shots} capture(s) dans ${OUT}`);
  await browser.close();
})();
