import 'status_da_festa.dart';

/// A identidade da festa (arquivo 01 §6 · CALC-05).
///
/// [data] e [hora] são **rótulos literais** — `SÁB · 18 JUL` e `14H` —, não
/// `DateTime` (A-23): a spec não dá ano nem fuso, e convertê-los exigiria
/// inventar os dois. Quem precisar de data real (agenda, festa passada) troca
/// o tipo na sua spec, com a informação em mãos.
///
/// **Sem `link` e sem `nivelDoLink`** de propósito (A-21): os dois são RN-22 e
/// RN-23, domínio de `galera`. Esta entidade é estendida por quem precisar —
/// ninguém recalcula nada por causa disso.
///
/// `==`/`hashCode` escritos à mão (A-19).
class Festa {
  const Festa({
    required this.nome,
    required this.data,
    required this.hora,
    required this.local,
    required this.duracaoHoras,
    this.status = StatusDaFesta.chegando,
  });

  final String nome;

  /// Rótulo literal do dia, como aparece na tela: `SÁB · 18 JUL` (A-23).
  final String data;

  /// Rótulo literal da hora, como aparece na tela: `14H` (A-23).
  final String hora;

  final String local;

  /// Duração em horas — a entrada de `fatorDuracao` (RN-02).
  final int duracaoHoras;

  final StatusDaFesta status;

  Festa copyWith({
    String? nome,
    String? data,
    String? hora,
    String? local,
    int? duracaoHoras,
    StatusDaFesta? status,
  }) =>
      Festa(
        nome: nome ?? this.nome,
        data: data ?? this.data,
        hora: hora ?? this.hora,
        local: local ?? this.local,
        duracaoHoras: duracaoHoras ?? this.duracaoHoras,
        status: status ?? this.status,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Festa &&
          other.nome == nome &&
          other.data == data &&
          other.hora == hora &&
          other.local == local &&
          other.duracaoHoras == duracaoHoras &&
          other.status == status;

  @override
  int get hashCode =>
      Object.hash(nome, data, hora, local, duracaoHoras, status);
}
