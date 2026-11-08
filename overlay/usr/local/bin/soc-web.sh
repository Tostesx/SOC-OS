#!/usr/bin/env bash
# soc-web — navegador TUI/TTY do SOC-OS
#
# Dependências (Arch):
#   sudo pacman -S w3m fzf mpv yt-dlp deno
#   (opcionais) aerc          -> e-mail no terminal
#   (opcionais) cage firefox  -> navegador completo em modo kiosk
#
# Uso: source soc-web.sh && web      (ou chame ./soc-web.sh direto)

SOC_UA="Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0"
SOC_BUSCA="https://lite.duckduckgo.com/lite/?q="

_soc_tem() { command -v "$1" >/dev/null 2>&1; }

_soc_pausa() { read -r -p "  [Enter para continuar] " _; }

# URL-encode em Bash puro (sem depender de python/jq)
_soc_urlencode() {
    local LC_ALL=C s="$1" i c hex out=""
    for ((i = 0; i < ${#s}; i++)); do
        c="${s:i:1}"
        case "$c" in
            [a-zA-Z0-9.~_-]) out+="$c" ;;
            *) printf -v hex '%%%02X' "'$c"; out+="$hex" ;;
        esac
    done
    printf '%s' "$out"
}

# ---------------------------------------------------------------
# 1) Páginas web (texto) — o w3m já faz links, formulários e cookies
# ---------------------------------------------------------------
_soc_abrir() {
    local url="$1"
    w3m -cookie -o user_agent="$SOC_UA" -o accept_language="pt-BR,pt;q=0.9" "$url"
}

_soc_pagina() {
    echo ""
    local entrada
    read -r -p "  [ URL / BUSCA ] > " entrada
    [[ -z "$entrada" ]] && return

    local url
    if [[ "$entrada" == *" "* || "$entrada" != *.* ]]; then
        url="${SOC_BUSCA}$(_soc_urlencode "$entrada")"
    elif [[ "$entrada" == http* ]]; then
        url="$entrada"
    else
        url="https://$entrada"
    fi
    _soc_abrir "$url"
}

# ---------------------------------------------------------------
# 2) YouTube — yt-dlp acha o vídeo, mpv toca
# ---------------------------------------------------------------
_soc_tocar() {
    local vo
    if [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]; then
        vo=gpu                        # dentro de uma sessão gráfica
    elif [[ "$XDG_SESSION_TYPE" == "tty" ]]; then
        vo=drm                        # console puro (funciona dentro do tmux)
    else
        vo=tct                        # SSH/terminal genérico: vídeo em caracteres
    fi
    mpv --vo="$vo" \
        --ytdl-format='bv*[height<=720]+ba/b[height<=720]' \
        "$1"
}

_soc_youtube() {
    if ! _soc_tem yt-dlp || ! _soc_tem mpv; then
        echo "  Instale: sudo pacman -S yt-dlp mpv deno"
        _soc_pausa
        return
    fi

    echo ""
    local q alvo linha
    read -r -p "  [ YOUTUBE ] busca ou URL > " q
    [[ -z "$q" ]] && return

    if [[ "$q" == http* ]]; then
        alvo="$q"
    else
        echo "  Buscando..."
        linha=$(yt-dlp --flat-playlist --no-warnings \
                    --print "%(title)s  [%(duration_string)s]  %(uploader)s|%(id)s" \
                    "ytsearch15:$q" 2>/dev/null |
                fzf --reverse --delimiter='|' --with-nth=1 \
                    --prompt="  Vídeo > " --header="  Enter toca / Esc volta")
        [[ -z "$linha" ]] && return
        alvo="https://www.youtube.com/watch?v=${linha##*|}"
    fi

    _soc_tocar "$alvo"
}

# ---------------------------------------------------------------
# 3) E-mail — cliente de terminal via IMAP (Gmail precisa de senha de app/OAuth)
# ---------------------------------------------------------------
_soc_email() {
    if _soc_tem aerc; then
        aerc
    elif _soc_tem neomutt; then
        neomutt
    else
        echo "  Instale um cliente: sudo pacman -S aerc"
        _soc_pausa
    fi
}

# ---------------------------------------------------------------
# 4) Navegador completo (JS, Gmail web, sites pesados) em modo kiosk
# ---------------------------------------------------------------
_soc_completo() {
    if ! _soc_tem cage || ! _soc_tem firefox; then
        echo "  Instale: sudo pacman -S cage firefox"
        _soc_pausa
        return
    fi
    MOZ_ENABLE_WAYLAND=1 cage -s -- firefox
}

# ---------------------------------------------------------------
# Menu principal
# ---------------------------------------------------------------
web() {
    local escolha
    while true; do
        clear
        echo "╔═════════════════════════════════════════════╗"
        echo "║               NAVEGADOR SOC                 ║"
        echo "╚═════════════════════════════════════════════╝"

        escolha=$(printf '%s\n' \
            "🌐 Abrir página / pesquisar (texto)" \
            "🎬 YouTube (buscar e assistir)" \
            "📧 E-mail" \
            "🖥️  Navegador completo (Firefox em modo kiosk)" \
            "🚪 Sair" |
            fzf --height=10 --reverse --prompt="  Ação > " \
                --header="  [ NAVEGADOR SOC ]  Esc = sair")

        case "$escolha" in
            *"Abrir página"*) _soc_pagina ;;
            *"YouTube"*)      _soc_youtube ;;
            *"E-mail"*)       _soc_email ;;
            *"completo"*)     _soc_completo ;;
            *)                return 0 ;;
        esac
    done
}

# Permite rodar direto: ./soc-web.sh
[[ "${BASH_SOURCE[0]}" == "$0" ]] && web
