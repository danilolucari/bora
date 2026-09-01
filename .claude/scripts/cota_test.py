#!/usr/bin/env python3
"""Testes do monitor de cota. Sem dependência externa: `python cota_test.py`.

Cada caso sai de um critério do CLAUDE.md, não da implementação:

- a tabela de gatilho (`<70` seguir, `70..84` atenção, `>=85` parar);
- "gatilho só pela janela de sessão (5h)" — semana em 97% com sessão em 5% é SEGUIR;
- "cache velho ou janela virada → INCERTO, pedir /usage, não decidir no escuro";
- e a regra que faltava: **falha do monitor é INCERTO, nunca PARAR**, porque
  `PARAR` divide o exit code 1 com o traceback do Python.
"""

from __future__ import annotations

import datetime as dt
import io
import json
import os
import subprocess
import sys
import tempfile

def print(*partes: object) -> None:  # noqa: A001 — saída legível no console do Windows
    texto = " ".join(str(parte) for parte in partes)
    sys.stdout.buffer.write((texto + "\n").encode("utf-8"))
    sys.stdout.flush()


AQUI = os.path.dirname(os.path.abspath(__file__))
COTA = os.path.join(AQUI, "cota.py")

SEGUIR, PARAR, INCERTO = 0, 1, 2

falhas: list[str] = []


def _iso(**delta: float) -> str:
    return (dt.datetime.now(dt.timezone.utc) + dt.timedelta(**delta)).isoformat()


def _agora_ms() -> int:
    return int(dt.datetime.now(dt.timezone.utc).timestamp() * 1000)


def _cache(**janelas: dict) -> dict:
    return {"cachedUsageUtilization": {"fetchedAtMs": _agora_ms(), "utilization": janelas}}


def _rodar(conteudo) -> tuple[int, str]:
    """Roda o cota.py de verdade, como o hook roda: subprocesso e exit code."""
    with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False, encoding="utf-8") as arq:
        arq.write(conteudo if isinstance(conteudo, str) else json.dumps(conteudo))
        caminho = arq.name
    try:
        ambiente = dict(os.environ, COTA_ARQUIVO=caminho, PYTHONIOENCODING="utf-8")
        saida = subprocess.run(
            [sys.executable, COTA], capture_output=True, text=True,
            encoding="utf-8", errors="replace", env=ambiente,
        )
        return saida.returncode, (saida.stdout or "") + (saida.stderr or "")
    finally:
        os.unlink(caminho)


def checar(
    nome: str,
    conteudo,
    exit_esperado: int,
    deve_conter: str | None = None,
    nao_conter: str | None = None,
) -> None:
    codigo, texto = _rodar(conteudo)
    if codigo != exit_esperado:
        falhas.append(f"{nome}: exit {codigo}, esperado {exit_esperado}\n{texto.strip()}")
        return
    if deve_conter and deve_conter.lower() not in texto.lower():
        falhas.append(f"{nome}: saída não menciona {deve_conter!r}\n{texto.strip()}")
        return
    # `nao_conter` separa o ramo que trata o caso do fallback genérico da
    # barreira: os dois dão INCERTO, e sem isto um guarda podia sumir sem que
    # nenhum teste notasse — a barreira o cobriria calada.
    if nao_conter and nao_conter.lower() in texto.lower():
        falhas.append(f"{nome}: caiu no fallback {nao_conter!r}\n{texto.strip()}")
        return
    if "Traceback" in texto:
        falhas.append(f"{nome}: o monitor imprimiu um traceback\n{texto.strip()}")
        return
    print(f"  ok  {nome}")


def main() -> int:
    print("A tabela de gatilho, pela janela de 5h")
    sessao = lambda pct: _cache(five_hour={"utilization": pct, "resets_at": _iso(hours=3)})
    checar("sessão em 5% segue", sessao(5), SEGUIR)
    checar("sessão em 69% ainda segue", sessao(69), SEGUIR)
    checar("sessão em 70% é atenção", sessao(70), SEGUIR, "ATENCAO")
    checar("sessão em 84% ainda é atenção", sessao(84), SEGUIR, "ATENCAO")
    checar("sessão em 85% para", sessao(85), PARAR, "PARAR")
    checar("sessão em 97% para", sessao(97), PARAR, "PARAR")

    print("Só a sessão decide; as semanais são informativas")
    checar(
        "semana em 97% com sessão em 5% NÃO para",
        _cache(
            five_hour={"utilization": 5, "resets_at": _iso(hours=3)},
            seven_day={"utilization": 97, "resets_at": _iso(days=4)},
        ),
        SEGUIR,
        "informativa",
    )

    print("Os guardas de confiabilidade")
    checar(
        "janela de 5h já virada é INCERTO",
        _cache(five_hour={"utilization": 55, "resets_at": _iso(minutes=-4)}),
        INCERTO,
        "já resetou",
    )
    velho = _cache(five_hour={"utilization": 20, "resets_at": _iso(hours=3)})
    velho["cachedUsageUtilization"]["fetchedAtMs"] = _agora_ms() - 31 * 60 * 1000
    checar("cache parado há 31 min é INCERTO", velho, INCERTO, "/usage", "o monitor falhou")
    checar(
        "cache sem a janela de sessão é INCERTO",
        _cache(seven_day={"utilization": 40, "resets_at": _iso(days=2)}),
        INCERTO,
        "janela de sessão",
    )

    print("Regressões de 2026-09-01 — falha do monitor não pode virar PARAR")
    # Era KeyError: 'cache_idade_min', que saía 1 e o hook lia como PARAR.
    checar("sem cachedUsageUtilization é INCERTO", {}, INCERTO, "ausente", "o monitor falhou")
    # Era ValueError em fromisoformat, também exit 1.
    checar(
        "resets_at corrompido é INCERTO",
        _cache(five_hour={"utilization": 42, "resets_at": "nao-e-data"}),
        INCERTO,
        "ilegível",
    )
    # Era "cache parado há 29804414 min" — verdadeiro no cálculo, inútil de ler.
    semfetch = {"cachedUsageUtilization": {"utilization": {
        "five_hour": {"utilization": 42, "resets_at": _iso(hours=3)}}}}
    checar("sem fetchedAtMs é INCERTO com motivo legível", semfetch, INCERTO, "fetchedAtMs")
    # resets_at ingênuo subtraía aware de naive e lançava TypeError. Hoje é
    # INCERTO: sem fuso não dá para saber se a janela virou, e chutar um fuso
    # erraria por horas justamente nesse cálculo.
    ingenuo = _cache(five_hour={
        "utilization": 42,
        "resets_at": (dt.datetime.now() + dt.timedelta(hours=3)).isoformat(),
    })
    checar("resets_at sem fuso é INCERTO", ingenuo, INCERTO, "ilegível", "o monitor falhou")
    checar("arquivo ilegível é INCERTO", "{ isto não é json", INCERTO)
    checar("arquivo vazio é INCERTO", "", INCERTO)

    print("A barreira de exit code, exercitada com forma que ninguém previu")
    # Estes dois existem para provar a barreira do `main`, não os guardas: são
    # formas que nenhum ramo trata de propósito e que estouram lá dentro
    # (AttributeError). Sem a barreira o Python sai 1, que é PARAR.
    checar(
        "utilization como lista é INCERTO, não PARAR",
        {"cachedUsageUtilization": {"fetchedAtMs": _agora_ms(), "utilization": ["oi"]}},
        INCERTO,
        "o monitor falhou",
    )
    checar(
        "cachedUsageUtilization como texto é INCERTO, não PARAR",
        {"cachedUsageUtilization": "isto devia ser um objeto"},
        INCERTO,
        "o monitor falhou",
    )

    print()
    if falhas:
        print(f"FALHOU — {len(falhas)} de {len(falhas)} caso(s) abaixo:\n")
        for falha in falhas:
            print(f"  {falha}\n")
        return 1
    print("Todos os casos passaram.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
