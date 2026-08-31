/// A data default do rolê novo — MONT-15 (A-04).
///
/// Nenhuma spec define nome nem data de `/roles/novo`; **A-04** escolheu o
/// próximo sábado, e este arquivo é a única fonte dessa escolha. Dart puro,
/// sem Flutter: é o que torna o default testável sem esperar sábado.
library;

/// Quantos dias faltam para o **próximo** sábado, por dia da semana.
///
/// Sábado vale **7**, não 0: quem abre o app num sábado está marcando o rolê
/// do sábado que vem, não o de hoje — é o caso que decide a regra.
///
/// Declarado como tabela, e não derivado por resto de divisão, porque a regra
/// por dia é o que a spec diz e é assim que ela se lê. (E `%` não entra em
/// `lib/features/montar/**`, por MONT-08.)
const Map<int, int> _diasAteOProximoSabado = {
  DateTime.monday: 5,
  DateTime.tuesday: 4,
  DateTime.wednesday: 3,
  DateTime.thursday: 2,
  DateTime.friday: 1,
  DateTime.saturday: 7,
  DateTime.sunday: 6,
};

/// As abreviações dos 12 meses em pt-BR, **em CAIXA ALTA** — o formato de
/// `Festa.data` (`SÁB · 18 JUL`), que é rótulo literal e não `DateTime`
/// (A-23 de `calculo`).
const List<String> _mesesAbreviados = [
  'JAN',
  'FEV',
  'MAR',
  'ABR',
  'MAI',
  'JUN',
  'JUL',
  'AGO',
  'SET',
  'OUT',
  'NOV',
  'DEZ',
];

/// O próximo sábado a partir de [hoje], à meia-noite local.
///
/// [hoje] entra **por parâmetro**: sem relógio injetado, o default do rascunho
/// só seria testável no sábado. Nada aqui chama `DateTime.now()` — quem tem o
/// relógio é a borda (a página), não o domínio.
///
/// Virada de mês e de ano saem de graça: `DateTime(ano, mes, dia + n)`
/// normaliza o estouro (31 de dezembro + 2 vira 2 de janeiro do ano seguinte),
/// inclusive em fevereiro de ano bissexto.
DateTime proximoSabado(DateTime hoje) => DateTime(
      hoje.year,
      hoje.month,
      hoje.day + _diasAteOProximoSabado[hoje.weekday]!,
    );

/// O rótulo de um sábado no formato de `Festa.data`: `SÁB · 18 JUL`.
///
/// Recusa qualquer outro dia da semana, ruidosamente: `SÁB` é literal deste
/// rótulo, e formatar uma quarta-feira aqui produziria uma data que **mente**
/// na tela. É a mesma escolha de `ContagemDePessoas`, que recusa contagem
/// negativa em vez de corrigi-la em silêncio.
///
/// *SPEC_PRECISION_GAP*: todo exemplo da spec-fonte tem dia de dois dígitos
/// (`18 JUL`, `21 JUN`, `20 DEZ`), então o dia de um dígito não está definido
/// em lugar nenhum. Sai **sem zero à esquerda** (`SÁB · 2 JAN`), pela mesma
/// economia de RN-13, que não escreve centavo que não precisa existir.
String rotuloDeSabado(DateTime sabado) {
  if (sabado.weekday != DateTime.saturday) {
    throw ArgumentError.value(sabado, 'sabado', 'não é um sábado');
  }

  return 'SÁB · ${sabado.day} ${_mesesAbreviados[sabado.month - 1]}';
}
