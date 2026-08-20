/// Estado inicial de RN-30 — o churrasco do Rafa — como **dado bruto**.
///
/// Fonte literal: `.specs/init-spec/03-regras-de-negocio.md` (RN-30) e
/// `.specs/init-spec/01-produto-e-fluxos.md` §7 (personas do protótipo).
///
/// Dart puro: sem import de Flutter e sem import de Firebase (FUND-19). Sem
/// entidades de domínio — `Festa`, `Pessoa` e `ItemDeLista` nascem na spec 02
/// `calculo`, que tipa esta fixture depois. Aqui só `Map`/`List` de primitivos.
library;

/// Campos da festa exemplo de RN-30.
///
/// `confirmadosNaHome: 4` e `pendentesNaHome: 2` convivem com as cinco pessoas
/// nomeadas em [pessoasRn30] **de propósito**: são os números literais de
/// RN-30. A fixture não reconcilia — quem reconcilia é a spec 04.
const Map<String, Object?> festaRn30 = {
  'nome': 'CHURRAS DO RAFA 🔥',
  'data': 'SÁB · 18 JUL',
  'hora': '14H',
  'local': 'Laje do Rafa — Vila Madalena',
  'duracaoHoras': 4,
  'confirmadosNaHome': 4,
  'pendentesNaHome': 2,
};

/// As cinco pessoas nomeadas de RN-30 — quatro confirmadas mais Duda.
///
/// `papel`, `dieta` e `bebe` são as personas do arquivo 01 §7; existem porque
/// RN-21 vai consumi-los na spec 02. Cor de avatar fica de fora: é token, e
/// token é território da spec 01.
const List<Map<String, Object?>> pessoasRn30 = [
  {
    'nome': 'Rafa',
    'papel': 'host',
    'dieta': 'tudo',
    'bebe': true,
    'status': 'confirmado',
    'voce': true,
  },
  {
    'nome': 'Ana',
    'papel': 'cohost',
    'dieta': 'tudo',
    'bebe': true,
    'status': 'confirmado',
    'voce': false,
  },
  {
    'nome': 'Léo',
    'papel': 'guest',
    'dieta': 'veggie',
    'bebe': true,
    'status': 'confirmado',
    'voce': false,
  },
  {
    'nome': 'Bia',
    'papel': 'guest',
    'dieta': 'semporco',
    'bebe': false,
    'status': 'confirmado',
    'voce': false,
  },
  {
    'nome': 'Duda',
    'papel': 'viewer',
    'dieta': 'tudo',
    'bebe': false,
    'status': 'pendente',
    'voce': false,
  },
];

/// Chaves dos itens padrão de RN-30: bovina + frango, pão de alho, refri,
/// água, cerveja e cachaça.
const List<String> itensPadraoRn30 = [
  'bovina',
  'frango',
  'pao_de_alho',
  'refrigerante',
  'agua',
  'cerveja',
  'cachaca',
];
