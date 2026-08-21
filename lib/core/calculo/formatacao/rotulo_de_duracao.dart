/// Rótulo da duração da festa — RN-13 · CALC-04.
///
/// `2 horas` · `4 horas` · `6 horas` · `Dia todo` (10h). São as quatro opções
/// que o produto oferece (RN-02 e os chips de T-03); nenhuma outra é
/// alcançável pela UI, então nenhuma outra é inventada aqui.
///
/// Mesmo contrato de [MoneyFormatter]: a UI recebe o rótulo pronto.
String rotuloDeDuracao(int horas) => horas == 10 ? 'Dia todo' : '$horas horas';
