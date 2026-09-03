#!/usr/bin/env python3
"""Ponte entre os hooks do Claude Code e `cota.py`.

É isto que torna a monitoria automática em vez de lembrada. Os três eventos
configurados em `.claude/settings.json` cobrem a sessão inteira:

    SessionStart -> arma a monitoria e diz em que pé a cota está
    PostToolUse  -> lê a cota a cada chamada de ferramenta (fala a cada 5 min)
    Stop         -> em PARAR, **bloqueia** o fim do turno e manda executar o
                    protocolo de pausa

O que ele vigia é **só a janela de sessão (5h)**; as semanais viajam junto no
relatório como informação e não disparam pausa (ver `cota.py`).

Ler `~/.claude.json` custa ~0,5 ms e o processo custa ~30 ms, então a leitura
acontece em toda chamada de ferramenta — mais frequente que os 5 minutos
combinados. O intervalo de 5 min governa quando o monitor **fala**, porque
contexto injetado à toa é o único custo real aqui. Em verde ele fica calado.

A cota só anda quando a sessão fala com a API, e toda chamada de ferramenta
vem logo depois de uma — então "a cada chamada de ferramenta" cobre exatamente
os momentos em que o número pode ter mudado. Sessão ociosa não gasta cota e
não precisa de vigia.

Uso (chamado pelos hooks, não à mão):
    python .claude/scripts/cota_hook.py SessionStart < payload.json
"""

from __future__ import annotations

import datetime as dt
import io
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from cota import (  # noqa: E402
    CODIGOS_QUE_UM_CACHE_NOVO_CONSERTA,
    ESPERA_APOS_RESET_MIN,
    LIMITE_PARAR,
    horario_de_retomada,
    ler_cota,
)

# __file__ é .claude/scripts/cota_hook.py, então subir um nível dá .claude.
PASTA_CLAUDE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ESTADO = os.path.join(PASTA_CLAUDE, ".cota-estado.json")

# De quanto em quanto tempo o monitor volta a falar, por veredito.
INTERVALO_S = {"ATENCAO": 300, "INCERTO": 900, "SEGUIR": None}

# Quanto o PostToolUse aceita esperar por um cache regravado quando a leitura
# sai velha. O hook roda logo depois de uma resposta da API, então na prática
# o cache já está fresco; a espera cobre a corrida de estar gravando agora.
# O timeout do hook em settings.json é 15s — este orçamento cabe folgado.
ESPERA_HOOK_S = 2.0

# Entradas de sessões que ninguém tocou há mais de um dia são lixo.
VALIDADE_ESTADO_S = 24 * 3600


def _agora() -> float:
    return dt.datetime.now(dt.timezone.utc).timestamp()


def _ler_estado() -> dict:
    try:
        with io.open(ESTADO, encoding="utf-8") as arquivo:
            dados = json.load(arquivo)
    except (OSError, ValueError):
        return {}
    agora = _agora()
    return {
        sessao: valor
        for sessao, valor in dados.items()
        if isinstance(valor, dict) and agora - valor.get("visto_em", 0) < VALIDADE_ESTADO_S
    }


def _gravar_estado(dados: dict) -> None:
    try:
        os.makedirs(os.path.dirname(ESTADO), exist_ok=True)
        with io.open(ESTADO, "w", encoding="utf-8") as arquivo:
            json.dump(dados, arquivo, ensure_ascii=False, indent=2)
    except OSError:
        pass  # estado é otimização; perder não pode derrubar o hook


def _resumo(estado: dict) -> str:
    """A janela que decide vem primeiro; as semanais entram como informação.

    Sem isso a linha ficava "semana (7d) 83%, sessão (5h) 0%" e parecia que a
    semana tinha pausado o trabalho — ela não pausa mais nada.
    """
    gatilho = estado.get("gatilho")
    partes = []
    if gatilho:
        partes.append(f"{gatilho['janela']} {gatilho['pct']}% (decide)")
    outras = ", ".join(
        f"{janela['janela']} {janela['pct']}%"
        for janela in estado.get("janelas", [])
        if janela is not gatilho
    )
    if outras:
        partes.append(f"informativas: {outras}")
    return " · ".join(partes) or estado.get("motivo", "?")


def _protocolo(estado: dict) -> str:
    """O texto que o modelo recebe quando bate 85%. Precisa bastar sozinho."""
    gatilho = estado.get("gatilho") or {}
    retomar = estado.get("retomar_em") or "(sem horário — rode o script)"
    return (
        f"COTA EM {gatilho.get('pct', '?')}% ({gatilho.get('janela', '?')}) — "
        f"limite de pausa é {LIMITE_PARAR}%. Execute o protocolo de pausa AGORA, "
        "nesta ordem, sem abrir trabalho novo:\n"
        "1. Feche a task corrente até o commit, ou descarte o trabalho parcial. "
        "Nunca deixe meia task no disco.\n"
        "2. Escreva o handoff em .specs/STATE.md, seção `## Handoff`, "
        "**substituindo só o corpo daquela seção** (o log de Decisions acima não "
        "pode ser tocado): feature, fase, tasks concluídas, próximo passo, "
        "contagem de testes, branch, arquivos não commitados, bloqueios.\n"
        "3. Commite o handoff.\n"
        "4. Agende a retomada:\n"
        "   pwsh -File .claude/scripts/agendar-retomada.ps1\n"
        f"   (ela calcula sozinha o alvo: {retomar}, que é o reset de "
        f"{gatilho.get('janela', '?')} + {ESPERA_APOS_RESET_MIN} min)\n"
        "5. Avise o usuário: porcentagem que disparou, janela, horário do reset, "
        "horário agendado da retomada e o que ficou pela metade (idealmente: nada).\n"
        "Detalhe completo na skill `cota`."
    )


def _emitir(payload: dict) -> None:
    sys.stdout.buffer.write(json.dumps(payload, ensure_ascii=False).encode("utf-8"))
    sys.stdout.buffer.write(b"\n")


def _contexto(evento: str, texto: str, aviso: str | None = None) -> dict:
    payload = {
        "hookSpecificOutput": {"hookEventName": evento, "additionalContext": texto},
        "suppressOutput": True,
    }
    if aviso:
        payload["systemMessage"] = aviso
    return payload


def main() -> int:
    evento = sys.argv[1] if len(sys.argv) > 1 else "PostToolUse"

    try:
        entrada = json.loads(sys.stdin.read() or "{}")
    except ValueError:
        entrada = {}
    sessao = entrada.get("session_id") or "sem-id"

    leitura = ler_cota(esperar_s=ESPERA_HOOK_S if evento == "PostToolUse" else 0.0)
    leitura["retomar_em"] = horario_de_retomada(leitura)
    veredito = leitura["veredito"]

    todas = _ler_estado()
    minha = todas.get(sessao, {})
    agora = _agora()
    mudou = minha.get("veredito") != veredito
    desde_ultimo = agora - minha.get("falou_em", 0)

    # A janela que disparou identifica o "episódio" de PARAR: bloquear uma vez
    # por episódio evita laço com o Stop hook e evita repetir depois do reset.
    janela_gatilho = (leitura.get("gatilho") or {}).get("reseta_em")

    saida: dict | None = None

    if evento == "SessionStart":
        # Toda sessão começa sabendo onde está — é isto que garante que
        # nenhuma sessão rode sem monitoria, mesmo se o CLAUDE.md não for lido.
        #
        # Só que aqui o cache velho é o **estado normal**, não anomalia: este
        # hook roda antes da primeira resposta da API da sessão, e é a resposta
        # que regrava o cache. Tratar isso como "rode /usage" produzia alarme
        # falso toda vez que a máquina ficava um tempo parada — e ensinou o
        # ritual de rodar o script duas vezes, em que a leitura certa só vinha
        # porque entre as duas rodadas coube uma chamada à API.
        herdado = leitura.get("motivo_codigo") in CODIGOS_QUE_UM_CACHE_NOVO_CONSERTA
        aviso = (
            f"cota: {veredito} — {leitura.get('motivo', '')}"
            if veredito != "SEGUIR" and not herdado
            else None
        )
        if herdado:
            fecho = (
                f"Este número é herdado da sessão anterior ({leitura.get('cache_idade_min', '?')} "
                "min) porque o cache só é regravado quando o Claude Code recebe resposta da "
                "API — o que ainda não aconteceu nesta sessão. Ele se corrige sozinho na "
                "primeira chamada de ferramenta, e o monitor avisa se não estiver verde. "
                "Não peça /usage nem rode o script duas vezes por causa disto."
            )
        elif veredito == "SEGUIR":
            fecho = "Ela vai avisar sozinha; não precisa rodar o script à mão."
        elif veredito == "PARAR":
            fecho = _protocolo(leitura)
        else:
            fecho = f"Atenção: {leitura.get('motivo', '')}."
        saida = _contexto(
            evento,
            f"Monitoria de cota ARMADA (hooks PostToolUse + Stop, limite de pausa "
            f"{LIMITE_PARAR}%). Leitura atual: {veredito} — {_resumo(leitura)}. "
            f"Cache com {leitura.get('cache_idade_min', '?')} min. " + fecho,
            aviso,
        )
        minha["falou_em"] = agora

    elif evento == "Stop":
        ja_bloqueou = minha.get("bloqueou_janela") == janela_gatilho
        # `stop_hook_active` é o turno que só existe porque este hook bloqueou —
        # bloquear de novo ali vira laço infinito.
        if veredito == "PARAR" and not ja_bloqueou and not entrada.get("stop_hook_active"):
            minha["bloqueou_janela"] = janela_gatilho
            minha["falou_em"] = agora
            saida = {
                "decision": "block",
                "reason": _protocolo(leitura),
                "systemMessage": (
                    f"COTA {(leitura.get('gatilho') or {}).get('pct', '?')}% — "
                    "pausa automática: escrevendo handoff e agendando a retomada."
                ),
            }

    else:  # PostToolUse
        intervalo = INTERVALO_S.get(veredito, 300)
        if veredito == "PARAR":
            deve_falar = True
        elif intervalo is None:
            # Verde é silêncio — contexto não é de graça. A exceção é o verde
            # que **corrige** um INCERTO anterior (tipicamente o do
            # SessionStart, herdado da sessão passada): esse número precisa
            # chegar uma vez, senão a sessão inteira segue lembrando do valor
            # velho e alguém acaba rodando o script à mão para conferir.
            deve_falar = minha.get("veredito") == "INCERTO"
        else:
            deve_falar = mudou or desde_ultimo >= intervalo

        if deve_falar:
            minha["falou_em"] = agora
            if veredito == "PARAR":
                saida = _contexto(
                    evento,
                    _protocolo(leitura),
                    f"COTA {(leitura.get('gatilho') or {}).get('pct', '?')}% — pare e faça o handoff.",
                )
            elif veredito == "ATENCAO":
                saida = _contexto(
                    evento,
                    f"COTA ATENCAO — {_resumo(leitura)}. Feche a task corrente e "
                    f"NÃO abra task longa; prepare o handoff. A pausa dispara em "
                    f"{LIMITE_PARAR}%.",
                    f"cota: {leitura.get('motivo', '')}",
                )
            elif veredito == "SEGUIR":
                saida = _contexto(
                    evento,
                    f"COTA OK — {_resumo(leitura)} (cache de "
                    f"{leitura.get('cache_idade_min', '?')} min). Esta leitura substitui o "
                    "INCERTO anterior; o monitor volta ao silêncio até mudar de faixa.",
                )
            else:  # INCERTO
                saida = _contexto(
                    evento,
                    f"COTA INCERTO — {leitura.get('motivo', '')}. Isto NÃO é verde: "
                    "peça ao usuário para rodar /usage antes de abrir trabalho longo.",
                    f"cota: incerto — {leitura.get('motivo', '')}",
                )

    minha["veredito"] = veredito
    minha["visto_em"] = agora
    minha["lido_em"] = agora
    todas[sessao] = minha
    _gravar_estado(todas)

    if saida:
        _emitir(saida)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as erro:  # noqa: BLE001 — hook mudo é pior que hook barulhento
        _emitir(
            {
                "systemMessage": (
                    f"monitor de cota falhou ({type(erro).__name__}: {erro}) — "
                    "a pausa automática NÃO está protegendo esta sessão. "
                    "Rode `python .claude/scripts/cota.py` à mão."
                )
            }
        )
        sys.exit(0)
