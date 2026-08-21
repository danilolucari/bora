/// Camada de cálculo do BORA — território das regras RN-01..RN-29.
///
/// Dart puro por contrato: nenhum arquivo desta pasta pode importar
/// `package:flutter/…`, `dart:ui`, `package:firebase…`, `cloud_firestore` ou
/// `package:flutter_bloc`. É o que torna as RN-xx testáveis sozinhas e o que
/// impede a fórmula de vazar para a UI —
/// `test/architecture/calculo_isolation_test.dart` policia a regra e quebra a
/// suíte nomeando o arquivo infrator.
///
/// **Esta é a única porta de entrada da camada.** Uma feature importa
/// `package:bora/core/calculo/calculo.dart` e recebe tudo: as entidades de
/// `dominio/`, as fórmulas de `regras/` e os formatadores de `formatacao/`.
/// Importar arquivo interno da pasta contorna o contrato e não é permitido.
///
/// A superfície tem três partes:
///
/// - **`dominio/`** — o vocabulário do arquivo 01 §6, em PT-BR: [Festa],
///   [Pessoa], [ContagemDePessoas], [ItemDeLista], [Despesa], [SaldoDePessoa],
///   [LinhaDeAcerto], mais os catálogos [catalogoDeItens] (preço-base da
///   calculadora, RN-03..RN-10) e [tabelaDePrecosDeMercado] (média real de
///   mercados, RN-11). **As duas tabelas de preço coexistem de propósito e
///   nunca se unificam** (A-03).
/// - **`regras/`** — uma função por RN-xx, do [fatorDuracao] de RN-02 ao
///   [calcularRacha] de RN-16, orquestradas por [CalculadoraDaFesta.calcular].
/// - **`formatacao/`** — [MoneyFormatter] (RN-13) e [rotuloDeDuracao].
///
/// **Nenhuma outra camada recalcula nada.** O resultado sai pronto daqui,
/// inclusive as strings de dinheiro (RN-13) e a posição do marcador da barra
/// de faixa (RN-11, [posicaoDoMarcador]) — a tela recebe o número resolvido e
/// só pinta. Se um widget precisar de uma conta que não existe aqui, a conta
/// nasce aqui, não lá.
library;

export 'dominio/catalogo_de_itens.dart';
export 'dominio/chave_item.dart';
export 'dominio/composicao_da_festa.dart';
export 'dominio/contagem_de_pessoas.dart';
export 'dominio/corredor.dart';
export 'dominio/despesa.dart';
export 'dominio/dieta.dart';
export 'dominio/festa.dart';
export 'dominio/item_de_lista.dart';
export 'dominio/linha_de_acerto.dart';
export 'dominio/papel_na_festa.dart';
export 'dominio/pessoa.dart';
export 'dominio/preco_de_mercado.dart';
export 'dominio/saldo_de_pessoa.dart';
export 'dominio/status_da_festa.dart';
export 'dominio/status_de_presenca.dart';
export 'dominio/tabela_de_precos_de_mercado.dart';
export 'formatacao/money_formatter.dart';
export 'formatacao/rotulo_de_duracao.dart';
export 'regras/calculadora_da_festa.dart';
export 'regras/contribuicoes.dart';
export 'regras/cota.dart';
export 'regras/essenciais.dart';
export 'regras/faixa_de_preco.dart';
export 'regras/fator_duracao.dart';
export 'regras/overrides.dart';
export 'regras/precisao.dart';
export 'regras/preferencias.dart';
export 'regras/quantidade_de_carne.dart';
export 'regras/quantidade_de_cerveja.dart';
export 'regras/quantidade_de_destilado.dart';
export 'regras/quantidades_de_bebida.dart';
export 'regras/quantidades_por_pessoa.dart';
export 'regras/quem_paga_quem.dart';
export 'regras/quitacao.dart';
export 'regras/saldos.dart';
export 'regras/split_de_despesa.dart';
export 'regras/total_do_pedido.dart';
export 'regras/totais.dart';
