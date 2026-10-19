/* Geometria espelhada de R/geometria.R; testar_matematica.py confere contra o R. */
function geometriaDemo(notas) {
  const cargos = ['presidente','governador','senador','federal','estadual'];
  if (cargos.some(c => !Number.isFinite(notas[c]) || notas[c] < 0 || notas[c] > 10)) throw new Error('A nota do exemplo deve ficar entre 0 e 10.');
  const t = Object.fromEntries(cargos.map(c => [c, notas[c] / 10]));
  const seq = (a,b,n) => Array.from({length:n}, (_,i) => a + (b-a)*i/(n-1));
  const p = {
    largura_olho:.23, abertura_olho:.02+.25*t.governador, distancia_olhos:.34,
    comprimento_nariz:.29, largura_nariz:.04+.72*t.federal, curvatura_nariz:.005+.155*t.federal,
    largura_boca:.76, abertura_boca:.01+.22*t.senador,
    comprimento_sobrancelha:.36, altura_sobrancelha:.58+.25*t.estadual
  };
  const rx = p.largura_nariz/2, cy = .06-p.comprimento_nariz+p.curvatura_nariz;
  const s = seq(0,1,21), angulos = seq(Math.PI,2*Math.PI,61);
  const nariz = {
    x:s.map(v => -rx*(3*(1-v)*v*v+v*v*v)).concat(angulos.map(a => rx*Math.cos(a))),
    y:s.map(v => .06*(1-v)**3+3*(1-v)*v*v*(cy+.04)+v**3*cy).concat(angulos.map(a => cy+p.curvatura_nariz*Math.sin(a)))
  };
  const u = seq(-1,1,61), superior = u.map(v => -.35+.08*v*v);
  const inferior = u.map((v,i) => superior[i]-p.abertura_boca*(1-v*v));
  const boca = {x:u.concat([...u].reverse()).map(v => v*p.largura_boca/2), y:superior.concat([...inferior].reverse())};
  const elipse = (lado,a,b) => {
    const theta = seq(0,2*Math.PI,41);
    return {x:theta.map(v => lado*.34+a*Math.cos(v)), y:theta.map(v => .27+b*Math.sin(v))};
  };
  const theta = Math.PI*(1-t.presidente), contorno = seq(0,2*Math.PI,121);
  return {parametros:p, nariz, boca, cor:dados.paleta_demo[Math.round(notas.presidente*10)],
    ponteiro:{x:.78*Math.cos(theta),y:.78*Math.sin(theta)},
    contorno:{x:contorno.map(Math.cos),y:contorno.map(Math.sin)},
    olhos:[-1,1].map(l => elipse(l,.23,p.abertura_olho)),
    pupilas:[-1,1].map(l => elipse(l,.065,Math.min(.085,.65*p.abertura_olho))),
    sobrancelhas:[-1,1].map(l => ({x1:l*.34-.36/2,x2:l*.34+.36/2,y1:p.altura_sobrancelha,y2:p.altura_sobrancelha}))};
}
(function iniciarDemo() {
  const cargos = ['presidente','governador','senador','federal','estadual'];
  const numero = new Intl.NumberFormat('pt-BR',{minimumFractionDigits:3,maximumFractionDigits:3});
  const pontos = g => g.x.map((x,i) => x+','+g.y[i]).join(' ');
  const curva = (id,g) => document.getElementById(id).setAttribute('points',pontos(g));
  const faixa = document.getElementById('demo-faixa'), ns = 'http://www.w3.org/2000/svg';
  for (let j=0;j<120;j++) {
    const a=Math.PI*(1-j/120),b=Math.PI*(1-(j+1)/120);
    const poligono = document.createElementNS(ns,'polygon');
    poligono.setAttribute('points',[[Math.cos(a),Math.sin(a)],[Math.cos(b),Math.sin(b)],[.84*Math.cos(b),.84*Math.sin(b)],[.84*Math.cos(a),.84*Math.sin(a)]].map(p=>p.join(',')).join(' '));
    poligono.setAttribute('fill',dados.paleta_faixa_demo[j]);
    faixa.append(poligono);
  }
  function atualizar() {
    const notas = Object.fromEntries(cargos.map(c => [c,Number(document.getElementById('slider-'+c).value)]));
    const g = geometriaDemo(notas), p = g.parametros;
    curva('demo-cor',g.contorno);document.getElementById('demo-cor').setAttribute('fill',g.cor);
    curva('demo-nariz',g.nariz);curva('demo-boca',g.boca);
    [['esquerdo','esquerda'],['direito','direita']].forEach(([olho,pupila],i) => {curva('demo-olho-'+olho,g.olhos[i]);curva('demo-pupila-'+pupila,g.pupilas[i]);});
    ['esquerda','direita'].forEach((lado,i) => {for(const [a,v] of Object.entries(g.sobrancelhas[i])) document.getElementById('demo-sobrancelha-'+lado).setAttribute(a,v);});
    document.getElementById('demo-ponteiro').setAttribute('x2',g.ponteiro.x);
    document.getElementById('demo-ponteiro').setAttribute('y2',g.ponteiro.y);
    for(const c of cargos) document.getElementById('valor-'+c).textContent=notas[c].toLocaleString('pt-BR',{minimumFractionDigits:1,maximumFractionDigits:1});
    document.getElementById('parametro-presidente').textContent='Cor RGB: '+g.cor+' · t = '+numero.format(notas.presidente/10);
    document.getElementById('parametro-governador').textContent='Semieixo vertical: '+numero.format(p.abertura_olho)+' r';
    document.getElementById('parametro-senador').textContent='Abertura no centro: '+numero.format(p.abertura_boca)+' r';
    document.getElementById('parametro-federal').textContent='Largura: '+numero.format(p.largura_nariz)+' r · raio vertical da ponta: '+numero.format(p.curvatura_nariz)+' r';
    document.getElementById('parametro-estadual').textContent='Altura: '+numero.format(p.altura_sobrancelha)+' r';
    document.getElementById('descricao-rosto-demo').textContent='Exemplo hipotético. '+cargos.map(c=>nomes[c]+': '+notas[c].toLocaleString('pt-BR')).join('; ')+'.';
  }
  for(const c of cargos) document.getElementById('slider-'+c).addEventListener('input',atualizar);
  document.getElementById('demo-reiniciar').addEventListener('click',()=>{for(const c of cargos)document.getElementById('slider-'+c).value=5;atualizar();});
  atualizar();
})();
