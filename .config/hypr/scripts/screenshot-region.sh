#!/bin/bash
# Captura de região (grim + slurp) com ações opcionais.
#
# Uso:  screenshot-region.sh [save|annotate|ocr]
#   save (padrão) -> salva em ~/Pictures/Screenshots e copia p/ área de transferência
#   annotate      -> abre o swappy para anotar e salva o resultado
#   ocr           -> extrai o texto da região (tesseract, por+eng) e copia
set -euo pipefail

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
ACTION="${1:-save}"
FILE="$DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

GEOM="$(slurp 2>/dev/null || true)"
[ -z "$GEOM" ] && exit 0

notify() {
  command -v notify-send >/dev/null 2>&1 && notify-send -a "screenshot" "$@" || true
}

case "$ACTION" in
  annotate)
    grim -g "$GEOM" "$FILE"
    if command -v swappy >/dev/null 2>&1; then
      swappy -f "$FILE" -o "$FILE" || true
    fi
    wl-copy < "$FILE"
    notify -i "$FILE" "Captura anotada" "Salva em: $FILE (copiada para a área de transferência)"
    ;;
  ocr)
    TMP="$(mktemp --suffix=.png)"
    grim -g "$GEOM" "$TMP"
    LANGS="$(tesseract --list-langs 2>/dev/null | awk 'NR>1{print $1}' | paste -sd+ - || true)"
    TXT="$(tesseract "$TMP" stdout -l "${LANGS:-eng}" 2>/dev/null | sed '/^[[:space:]]*$/d' || true)"
    rm -f "$TMP"
    if [ -z "$TXT" ]; then
      notify "OCR" "Nenhum texto encontrado na região"
      exit 0
    fi
    printf '%s' "$TXT" | wl-copy
    notify "Texto copiado (OCR)" "$(printf '%s' "$TXT" | head -1 | cut -c1-90)"
    ;;
  save|*)
    grim -g "$GEOM" "$FILE"
    wl-copy < "$FILE"
    notify -i "$FILE" "Captura de tela" "Salva em: $FILE (copiada para a área de transferência)"
    ;;
esac
