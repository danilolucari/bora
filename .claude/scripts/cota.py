#!/usr/bin/env python3
"""Lê a cota da conta no Claude Code e diz se é hora de parar.

A fonte é `~/.claude.json` -> `cachedUsageUtilization`, o **mesmo dado que o
`/usage` mostra**. O Claude Code reescreve esse cache a cada resposta da API
enquanto a sessão trabalha, então durante trabalho ativo ele é fresco por
construção. O cache é da conta, não da sessão: outra sessão queimando cota
nesta máquina aparece aqui também.

NÃO use `ccusage` para isto. Ele soma `cacheReadInputTokens`, que cresce a cada
turno porque o contexto inteiro é relido, e não enxerga o limite da conta. Em
2026-08-25 uma estimativa por `ccusage` gritou 100% quando o `/usage` real
marcava 18%, e o trabalho foi pausado à toa.

O gatilho é **só a janela de sessão (5h)**. As janelas semanais continuam
aparecendo no relatório como informação, mas não pausam mais o trabalho:
quem decide se dá para seguir agora é a cota da sessão corrente. Escolha do
usuário em 2026-08-28 — o teto semanal fica alto por dias seguidos e pausar
por ele parava a sessão com a janela de 5h vazia.

Uso:
    python .claude/scripts/cota.py          # relatório legível
    python .claude/scripts/cota.py --curto  # uma linha
    python .claude/scripts/cota.py --json   # para script

Saída (exit code):
    0  SEGUIR    - abaixo de 70%
    0  ATENCAO   - 70..84%, fechar a task corrente e evitar abrir task longa
    1  PARAR     - >= 85%: escrever handoff, commitar, agendar retomada, pausar
    2  INCERTO   - cache ausente, velho ou de janela já encerrada
"""

from __future__ import annotations

import argparse
import datetime as dt
import io
import json
import os
import sys

# COTA_ARQUIVO existe para os testes conseguirem simular 85% sem esperar
# a conta chegar lá de verdade.
CAMINHO = os.environ.get("COTA_ARQUIVO") or os.path.expanduser("~/.claude.json")

# Combinados com o usuário: 85% dispara o handoff; 70% é o aviso amarelo.
LIMITE_PARAR = 85
LIMITE_ATENCAO = 70

# Cache mais velho que isto é número congelado — repetir um valor velho para
# sempre parece "tudo bem" e não é.
IDADE_MAXIMA_MIN = 30

# Quanto esperar depois do reset antes de retomar (combinado com o usuário).
ESPERA_APOS_RESET_MIN = 10

# Nome legível de cada janela, para a mensagem dizer o que estourou.
NOMES = {
    "five_hour": "sessão (5h)",
    "seven_day": "semana (7d)",
    "seven_day_opus": "semana Opus (7d)",
    "seven_day_sonnet": "semana Sonnet (7d)",
    "seven_day_oauth_apps": "semana apps (7d)",
    "seven_day_cowork": "semana cowork (7d)",
    "session": "sessão (5h)",
    "weekly_all": "semana (7d)",
    "weekly_opus": "semana Opus (7d)",
}

# A única janela que dispara veredito. Tudo o mais é informativo.
NOME_SESSAO = "sessão (5h)"


def _agora() -> dt.datetime:
    return dt.datetime.now(dt.timezone.utc)


def _nome(chave: str) -> str:
    return NOMES.get(chave, chave)


def _coletar_janelas(uso: dict) -> list[dict]:
    """Toda janela de limite que o cache conhece, não só as duas óbvias.

    Coletar tudo é para o **relatório**: o `/usage` expõe mais buckets do que
    `five_hour`/`seven_day` (planos Max têm teto semanal separado de Opus) e
    ver todos ajuda a entender o dia. Quem **decide** o veredito é só a janela
    de sessão — ver `NOME_SESSAO` em `ler_cota`.
    """
    janelas: dict[str, dict] = {}

    # Os buckets nomeados no topo de `utilization`.
    for chave, valor in uso.items():
        if not isinstance(valor, dict):
            continue
        pct = valor.get("utilization")
        if not isinstance(pct, (int, float)):
            continue
        # Bucket zerado e sem data de reset é placeholder inerte do plano
        # (nimbus_quill e afins). Um que chegue a passar de zero volta a contar.
        if pct == 0 and not valor.get("resets_at"):
            continue
        janelas[_nome(chave)] = {
            "janela": _nome(chave),
            "chave": chave,
            "pct": pct,
            "reseta_em": valor.get("resets_at"),
        }

    # A lista `limits[]`, que traz as mesmas janelas em forma uniforme e às
    # vezes alguma que não aparece como bucket nomeado.
    for limite in uso.get("limits") or []:
        if not isinstance(limite, dict):
            continue
        pct = limite.get("percent")
        if not isinstance(pct, (int, float)):
            continue
        nome = _nome(limite.get("kind") or limite.get("group") or "?")
        anterior = janelas.get(nome)
        # Na dúvida entre duas leituras da mesma janela, fica a mais alta.
        if anterior is None or pct > anterior["pct"]:
            janelas[nome] = {
                "janela": nome,
                "chave": limite.get("kind"),
                "pct": pct,
                "reseta_em": limite.get("resets_at") or (anterior or {}).get("reseta_em"),
            }

    return sorted(janelas.values(), key=lambda janela: janela["pct"], reverse=True)


def _instante(iso: str | None) -> dt.datetime | None:
    """`resets_at` -> datetime **aware**, ou `None` se o campo não servir.

    Nunca levanta. Um `resets_at` corrompido é um cache em que não dá para
    confiar, e o preço disso é um `INCERTO` — nunca um traceback, que a tabela
    de exit code leria como `PARAR` (ver `main`).

    Aceita o sufixo `Z`, que `fromisoformat` cobre mal em versões antigas.

    Recusa a data **ingênua**: sem fuso não dá para saber se ela já passou, e
    chutar UTC ou local erraria por horas justamente no cálculo que decide se a
    janela virou. Subtraí-la de `_agora()` (aware) também lançaria `TypeError`.
    Ininterpretável vira `None`, e quem chama transforma isso em `INCERTO`.
    """
    if not isinstance(iso, str) or not iso:
        return None
    try:
        quando = dt.datetime.fromisoformat(iso.replace("Z", "+00:00"))
    except ValueError:
        return None
    if quando.tzinfo is None:
        return None
    return quando


def _local(iso: str | None) -> str | None:
    quando = _instante(iso)
    if quando is None:
        return None
    return quando.astimezone().isoformat(timespec="seconds")


def ler_cota(caminho: str = CAMINHO) -> dict:
    """Devolve o estado da cota, já com os guardas de confiabilidade aplicados."""
    try:
        with io.open(caminho, encoding="utf-8") as arquivo:
            dados = json.load(arquivo)
    except (OSError, ValueError) as erro:
        return {"veredito": "INCERTO", "motivo": f"não deu para ler {caminho}: {erro}"}

    cache = dados.get("cachedUsageUtilization")
    if not cache:
        return {
            "veredito": "INCERTO",
            "motivo": "cachedUsageUtilization ausente — a sessão já falou com a API nesta máquina?",
        }

    uso = cache.get("utilization") or {}
    janelas = _coletar_janelas(uso)

    agora = _agora()

    # Sem `fetchedAtMs` não dá para saber se o número é fresco. O default de 0
    # transformava isso numa idade de ~30 milhões de minutos, que o guarda 2
    # relatava como "cache parado há 29804414 min" — verdadeiro no cálculo e
    # inútil para quem lê.
    buscado_ms = cache.get("fetchedAtMs")
    if not isinstance(buscado_ms, (int, float)):
        return {
            "veredito": "INCERTO",
            "motivo": (
                "o cache não trouxe `fetchedAtMs`, então não dá para saber se o "
                "número é fresco. Rode /usage para atualizar."
            ),
        }
    idade_min = (agora - dt.datetime.fromtimestamp(
        buscado_ms / 1000, dt.timezone.utc
    )).total_seconds() / 60

    cinco_h = uso.get("five_hour") or {}
    reseta_sessao = cinco_h.get("resets_at")
    reseta = _instante(reseta_sessao)

    # Sem um `resets_at` legível na janela de 5h o guarda 1 não roda, e é ele
    # que pega o caso perigoso: número em cache de uma janela que já fechou.
    # Seguir aqui seria decidir sem poder conferir a premissa — o mesmo escuro
    # que o cache velho produz, e a resposta é a mesma.
    if cinco_h and reseta is None:
        return {
            "veredito": "INCERTO",
            "motivo": (
                f"a janela de 5h veio com `resets_at` ilegível ({reseta_sessao!r}), "
                "então não dá para saber se ela já virou. Rode /usage."
            ),
        }

    faltam_min = (reseta - agora).total_seconds() / 60 if reseta else None

    estado = {
        "janelas": janelas,
        "sessao_pct": cinco_h.get("utilization"),
        "semana_pct": (uso.get("seven_day") or {}).get("utilization"),
        "reseta_em_utc": reseta.isoformat(timespec="seconds") if reseta else None,
        "reseta_em_local": _local(reseta_sessao),
        "faltam_min": round(faltam_min, 1) if faltam_min is not None else None,
        "cache_idade_min": round(idade_min, 1),
        "semana_reseta_em_local": _local((uso.get("seven_day") or {}).get("resets_at")),
    }

    # Guarda 1: a janela de 5h já virou. O número em cache é da janela que
    # fechou e não descreve a atual — foi o caso real de 2026-08-26 03:54 UTC,
    # com o cache marcando 55% de uma janela encerrada 4 min antes.
    if faltam_min is not None and faltam_min <= 0:
        estado["veredito"] = "INCERTO"
        estado["motivo"] = (
            "a janela de 5h já resetou e o cache ainda é da janela anterior "
            f"({estado['sessao_pct']}%). Rode /usage ou faça uma chamada para atualizar."
        )
        return estado

    # Guarda 2: número congelado.
    if idade_min > IDADE_MAXIMA_MIN:
        estado["veredito"] = "INCERTO"
        estado["motivo"] = (
            f"cache parado há {idade_min:.0f} min (máx {IDADE_MAXIMA_MIN}). "
            "Rode /usage para atualizar."
        )
        return estado

    if not janelas:
        estado["veredito"] = "INCERTO"
        estado["motivo"] = "o cache não trouxe nenhuma janela de utilização"
        return estado

    # O veredito sai **só** da janela de sessão. As semanais ficam em
    # `janelas` para o relatório mostrar, mas não pausam o trabalho.
    gatilho = next((j for j in janelas if j["janela"] == NOME_SESSAO), None)
    if gatilho is None:
        estado["veredito"] = "INCERTO"
        estado["motivo"] = (
            "o cache não trouxe a janela de sessão (5h), que é a única que "
            "decide. Rode /usage para atualizar."
        )
        return estado

    estado["gatilho"] = gatilho
    if gatilho["pct"] >= LIMITE_PARAR:
        estado["veredito"] = "PARAR"
        estado["motivo"] = f"{gatilho['janela']} em {gatilho['pct']}%"
    elif gatilho["pct"] >= LIMITE_ATENCAO:
        estado["veredito"] = "ATENCAO"
        estado["motivo"] = f"{gatilho['janela']} em {gatilho['pct']}% — não abrir task longa"
    else:
        estado["veredito"] = "SEGUIR"
        estado["motivo"] = f"{gatilho['janela']} em {gatilho['pct']}%"

    return estado


def horario_de_retomada(estado: dict) -> str | None:
    """Quando retomar: reset da janela do gatilho + 10 min, no fuso local.

    Como só a sessão dispara veredito, na prática o alvo é sempre o reset de
    5h. A função continua lendo `gatilho.reseta_em` em vez de fixar `five_hour`
    para não mentir se um dia outra janela voltar a decidir.
    """
    gatilho = estado.get("gatilho") or {}
    alvo = gatilho.get("reseta_em") or estado.get("reseta_em_utc")
    if not alvo:
        return None

    quando = _instante(alvo)
    if quando is None:
        return None
    retoma = quando + dt.timedelta(minutes=ESPERA_APOS_RESET_MIN)
    return retoma.astimezone().isoformat(timespec="seconds")


def _imprimir(texto: str) -> None:
    sys.stdout.buffer.write((texto + "\n").encode("utf-8"))


def _relatar() -> int:
    analisador = argparse.ArgumentParser(description=__doc__)
    analisador.add_argument("--json", action="store_true")
    analisador.add_argument("--curto", action="store_true")
    argumentos = analisador.parse_args()

    estado = ler_cota()
    estado["retomar_em"] = horario_de_retomada(estado)
    veredito = estado["veredito"]

    if argumentos.json:
        _imprimir(json.dumps(estado, ensure_ascii=False, indent=2))
    elif argumentos.curto:
        _imprimir(f"{veredito} · {estado.get('motivo', '')}")
    else:
        _imprimir(f"COTA: {veredito} — {estado.get('motivo', '')}")
        gatilho = estado.get("gatilho")
        for janela in estado.get("janelas", []):
            if janela is gatilho:
                marca = "<< decide"
            elif janela["janela"] == NOME_SESSAO:
                marca = ""
            else:
                marca = "(informativa)"
            _imprimir(f"  {janela['janela']:<20}: {janela['pct']:>3}% {marca}")
        if estado.get("reseta_em_local"):
            _imprimir(
                f"  reseta em (5h)      : {estado['reseta_em_local']} "
                f"(faltam {estado['faltam_min']} min)"
            )
        if estado.get("semana_reseta_em_local"):
            _imprimir(f"  reseta em (7d)      : {estado['semana_reseta_em_local']}")
        if estado.get("cache_idade_min") is not None:
            _imprimir(f"  cache idade         : {estado['cache_idade_min']} min")
        if estado.get("retomar_em"):
            gatilho = estado.get("gatilho") or {}
            _imprimir(
                f"  retomar em          : {estado['retomar_em']} "
                f"(reset de {gatilho.get('janela', '?')} + {ESPERA_APOS_RESET_MIN} min)"
            )

    return {"SEGUIR": 0, "ATENCAO": 0, "PARAR": 1, "INCERTO": 2}.get(veredito, 2)


def main() -> int:
    """Barreira de exit code: falha inesperada é INCERTO, nunca PARAR.

    `PARAR` é o código 1, que é também o que o Python devolve quando morre de
    traceback. Sem esta barreira, um defeito no monitor ficava indistinguível
    de "pare o trabalho e escreva o handoff" — foi o que aconteceu em
    2026-09-01, quando um `KeyError: 'cache_idade_min'` saiu como 1.

    Um monitor quebrado não sabe nada sobre a cota, e a regra do CLAUDE.md para
    quem não sabe é `INCERTO`: pedir `/usage` ao usuário em vez de decidir no
    escuro. Por isso o código 2.
    """
    try:
        return _relatar()
    except Exception as erro:  # noqa: BLE001 — a barreira é o objetivo
        _imprimir(
            f"COTA: INCERTO — o monitor falhou ({type(erro).__name__}: {erro}). "
            "Isto NÃO é um PARAR: rode /usage e decida com o número na mão."
        )
        return 2


if __name__ == "__main__":
    sys.exit(main())
