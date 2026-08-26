#!/usr/bin/env python3
"""Lê a cota da sessão do Claude Code e diz se é hora de parar.

A fonte é `~/.claude.json` -> `cachedUsageUtilization`, o **mesmo dado que o
`/usage` mostra**. O Claude Code reescreve esse cache enquanto a sessão roda.

NÃO use `ccusage` para isto. Ele soma `cacheReadInputTokens`, que cresce a cada
turno porque o contexto inteiro é relido, e não enxerga o limite da conta. Em
2026-08-25 uma estimativa por `ccusage` gritou 100% quando o `/usage` real
marcava 18%, e o trabalho foi pausado à toa.

Uso:
    python .claude/scripts/cota.py          # relatório legível
    python .claude/scripts/cota.py --curto  # uma linha
    python .claude/scripts/cota.py --json   # para script

Saída (exit code):
    0  SEGUIR    - abaixo de 70%
    0  ATENCAO   - 70..84%, fechar a task corrente e evitar abrir task longa
    1  PARAR     - >= 85%: escrever handoff, commitar, pausar
    2  INCERTO   - cache ausente, velho ou de janela já encerrada
"""

from __future__ import annotations

import argparse
import datetime as dt
import io
import json
import os
import sys

CAMINHO = os.path.expanduser("~/.claude.json")

# Combinados com o usuário: 85% dispara o handoff; 70% é o aviso amarelo.
LIMITE_PARAR = 85
LIMITE_ATENCAO = 70

# Cache mais velho que isto é número congelado — repetir um valor velho para
# sempre parece "tudo bem" e não é.
IDADE_MAXIMA_MIN = 30

# Quanto esperar depois do reset antes de retomar (combinado com o usuário).
ESPERA_APOS_RESET_MIN = 10


def _agora() -> dt.datetime:
    return dt.datetime.now(dt.timezone.utc)


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
            "motivo": "cachedUsageUtilization ausente — a sessão já chamou /usage nesta máquina?",
        }

    uso = cache.get("utilization") or {}
    cinco_h = uso.get("five_hour") or {}
    sete_d = uso.get("seven_day") or {}

    agora = _agora()
    buscado_em = dt.datetime.fromtimestamp(
        cache.get("fetchedAtMs", 0) / 1000, dt.timezone.utc
    )
    idade_min = (agora - buscado_em).total_seconds() / 60

    reseta_em = cinco_h.get("resets_at")
    reseta = dt.datetime.fromisoformat(reseta_em) if reseta_em else None
    faltam_min = (reseta - agora).total_seconds() / 60 if reseta else None

    estado = {
        "sessao_pct": cinco_h.get("utilization"),
        "semana_pct": sete_d.get("utilization"),
        "reseta_em_utc": reseta.isoformat(timespec="seconds") if reseta else None,
        "reseta_em_local": reseta.astimezone().isoformat(timespec="seconds")
        if reseta
        else None,
        "faltam_min": round(faltam_min, 1) if faltam_min is not None else None,
        "cache_idade_min": round(idade_min, 1),
        "semana_reseta_em_local": (
            dt.datetime.fromisoformat(sete_d["resets_at"]).astimezone().isoformat(timespec="seconds")
            if sete_d.get("resets_at")
            else None
        ),
    }

    # Guarda 1: a janela de 5h já virou. O número em cache é da janela que
    # fechou e não descreve a atual — foi o caso real de 2026-08-26 03:54 UTC,
    # com o cache marcando 55% de uma janela encerrada 4 min antes.
    if faltam_min is not None and faltam_min <= 0:
        estado["veredito"] = "INCERTO"
        estado["motivo"] = (
            "a janela de 5h já resetou e o cache ainda é da janela anterior "
            f"({estado['sessao_pct']}%). Rode /usage para forçar a atualização."
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

    sessao = estado["sessao_pct"]
    semana = estado["semana_pct"]
    if sessao is None or semana is None:
        estado["veredito"] = "INCERTO"
        estado["motivo"] = "o cache não trouxe as duas utilizações"
        return estado

    pior = max(sessao, semana)
    if pior >= LIMITE_PARAR:
        estado["veredito"] = "PARAR"
        estado["motivo"] = f"{'sessão' if sessao >= semana else 'semana'} em {pior}%"
    elif pior >= LIMITE_ATENCAO:
        estado["veredito"] = "ATENCAO"
        estado["motivo"] = f"{pior}% — não abrir task longa"
    else:
        estado["veredito"] = "SEGUIR"
        estado["motivo"] = f"{pior}%"

    return estado


def horario_de_retomada(estado: dict) -> str | None:
    """Quando retomar: reset + 10 min, no fuso local."""
    if not estado.get("reseta_em_utc"):
        return None

    reseta = dt.datetime.fromisoformat(estado["reseta_em_utc"])
    retoma = reseta + dt.timedelta(minutes=ESPERA_APOS_RESET_MIN)

    return retoma.astimezone().isoformat(timespec="seconds")


def _imprimir(texto: str) -> None:
    sys.stdout.buffer.write((texto + "\n").encode("utf-8"))


def main() -> int:
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
        if estado.get("sessao_pct") is not None:
            _imprimir(f"  sessão (5h) : {estado['sessao_pct']}%")
            _imprimir(f"  semana (7d) : {estado['semana_pct']}%")
        if estado.get("reseta_em_local"):
            _imprimir(
                f"  reseta em   : {estado['reseta_em_local']} "
                f"(faltam {estado['faltam_min']} min)"
            )
        if estado.get("semana_reseta_em_local"):
            _imprimir(f"  semana reset: {estado['semana_reseta_em_local']}")
        _imprimir(f"  cache idade : {estado['cache_idade_min']} min")
        if estado.get("retomar_em"):
            _imprimir(f"  retomar em  : {estado['retomar_em']} (reset + 10 min)")

    return {"SEGUIR": 0, "ATENCAO": 0, "PARAR": 1, "INCERTO": 2}[veredito]


if __name__ == "__main__":
    sys.exit(main())
