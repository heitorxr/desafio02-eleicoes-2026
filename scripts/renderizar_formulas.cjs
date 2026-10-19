// Compila TeX no empacotamento; o navegador recebe HTML + MathML prontos.
'use strict';
const fs = require('node:fs');
const katex = require('katex');
const formulas = JSON.parse(fs.readFileSync(0, 'utf8'));
const resultado = formulas.map(tex => katex.renderToString(tex, {
  displayMode: true,
  throwOnError: true,
  strict: 'error',
  output: 'htmlAndMathml',
  trust: false
}));
process.stdout.write(JSON.stringify(resultado));
