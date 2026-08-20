/// Forma aceita para o `:codigo` do link público `/c/:codigo` (RN-22/RN-24).
///
/// O limite de 64 caracteres existe para que "tamanho absurdo" caia no destino
/// de erro em vez de virar tela de convidado.
final RegExp _formaDoCodigo = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

/// Diz se [codigo] tem a **forma** de um código de convite.
///
/// É só robustez de rota: as perguntas semânticas — o convite existe? já
/// expirou? — são da spec 09 `convidado`, que consulta o backend. Aqui nada é
/// consultado, e um código bem formado ainda pode não existir.
bool isWellFormedInviteCode(String? codigo) =>
    codigo != null && _formaDoCodigo.hasMatch(codigo);
