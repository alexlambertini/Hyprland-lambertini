#!/bin/bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/alexlambertini/Hyprland-lambertini.git}"
REPO_DIR="${REPO_DIR:-$HOME/hypr-waybar-theme}"
INSTALL_DEPS="${INSTALL_DEPS:-ask}" # yes|no|ask

echo "== Bootstrap: Hyprland + Waybar theme =="

if [ ! -d "$REPO_DIR/.git" ]; then
  if command -v git >/dev/null 2>&1; then
    echo "Clonando repositório em $REPO_DIR..."
    git clone "$REPO_URL" "$REPO_DIR"
  else
    echo "git não encontrado. Instale git e execute novamente, ou clone manualmente."
    exit 1
  fi
else
  echo "Repositório já existe em $REPO_DIR"
fi

install_deps_fedora() {
  echo "Instalando dependências (Fedora/dnf)..."
  sudo dnf install -y waybar rofi dunst jq curl lm_sensors mpv audacious playerctl \
    wl-clipboard swaybg wofi grim slurp brightnessctl \
    nautilus papirus-icon-theme kitty git
}

if [ -f /etc/fedora-release ] || command -v dnf >/dev/null 2>&1; then
  case "$INSTALL_DEPS" in
    yes) install_deps_fedora ;;
    no)  echo "Pulando instalação de dependências." ;;
    ask)
      if [ -t 0 ]; then
        read -r -p "Instalar dependências com dnf (Fedora)? [s/N] " ans
        case "${ans:-}" in
          s|S|sim|SIM|y|Y) install_deps_fedora ;;
          *) echo "Pulando instalação de dependências." ;;
        esac
      else
        echo "Execução não interativa: pulando instalação de dependências (use INSTALL_DEPS=yes para instalar)."
      fi
      ;;
  esac
else
  echo "Gerenciador dnf não detectado. Instale as dependências manualmente (veja README.md)."
fi

chmod +x "$REPO_DIR/install.sh"
"$REPO_DIR/install.sh"

echo "== Bootstrap concluído =="
echo "Recarregue: hyprctl reload && pkill waybar; waybar & disown"
