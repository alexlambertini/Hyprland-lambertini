# Tema/Setup Hyprland + Waybar (V7.2 customizado)

Conjunto de configurações para **Hyprland (Lua, 0.57+)**, **Waybar** (baseado no tema V7.2 de [HANCORE-linux/waybar-themes](https://github.com/HANCORE-linux/waybar-themes)), **Rofi** (drun), **Dunst** e notificações de música (MPRIS/playerctl), com visual unificado (fundo escuro translúcido, texto `#cccccc`, destaque `#df6124`).

> Ambiente de referência: Fedora 44, Hyprland 0.57, Waybar, PipeWire/WirePlumber, Rofi, Dunst. Ajustes podem ser necessários em outras distros/hardware.

## Conteúdo

- `.config/waybar/` — `config.jsonc`, `style.css` e scripts de widgets (clima, microfone, disco, tráfego de rede, layout de teclado, temperatura, toggles).
- `.config/hypr/hyprland.lua` — atalhos, animações, gaps, restauração de wallpaper, autostart de dunst/notificação de música.
- `.config/hypr/scripts/music-notify.sh` — notificação de faixa via `playerctl` + `notify-send`.
- `.config/hypr/scripts/screenshot-region.sh` — captura de região (`grim` + `slurp`) com cópia para área de transferência e notificação.
- `.config/hypr/current-wallpaper` — caminho do wallpaper padrão/restaurado.
- `.config/rofi/` — tema/config do launcher (drun/run/window).
- `.config/dunst/dunstrc` — notificações no mesmo visual.
- `.config/gtk-3.0/` e `.config/gtk-4.0/` — ajustes de tema/cores GTK (aproxima o visual para apps GTK como Nautilus).
- `bin/hypr-wallpaper-menu` — seletor de wallpaper (wofi) com persistência via `swaybg`.
- `.local/share/applications/hypr-wallpaper.desktop` — atalho no drun para o seletor de wallpaper.
- `wallpapers/` — wallpapers incluídos (copiados para `~/Pictures/Wallpapers` pelo `install.sh`).
- `install.sh` — instala/configura (com backup) os arquivos no usuário.
- `bootstrap.sh` — clona (se preciso), pode instalar dependências (Fedora) e roda o `install.sh`.

## Dependências

### Pacotes (Fedora) — completos para o tema funcionar
```bash
sudo dnf install -y \
  git \
  hyprland waybar \
  rofi wofi \
  dunst libnotify \
  swaybg \
  grim slurp wl-clipboard \
  jq curl \
  lm_sensors \
  playerctl \
  mpv audacious \
  pipewire pipewire-pulseaudio wireplumber \
  NetworkManager \
  brightnessctl \
  nautilus \
  kitty
```

**Para que serve cada grupo:**
- **Hyprland + Waybar:** compositor e barra (`hyprland`, `waybar`).
- **Launcher/menu:** `rofi` (drun `SUPER+D`), `wofi` (seletor de wallpaper).
- **Notificações:** `dunst` + `libnotify` (`notify-send`), incluindo avisos de música/captura.
- **Wallpaper:** `swaybg` (aplicação/restauração do papel de parede).
- **Captura de tela:** `grim`, `slurp`, `wl-clipboard` (`SUPER+SHIFT+S`).
- **Scripts/widgets:** `jq`, `curl` (clima, teclado, parse), `lm_sensors` (temperatura).
- **Mídia:** `playerctl` (controles/MPRIS e notificação de faixa), `mpv` (vídeo), `audacious` (música).
- **Áudio:** `pipewire`, `pipewire-pulseaudio`, `wireplumber`, `wpctl` (volume/microfone).
- **Rede:** `NetworkManager` (`nmcli`/interface e tráfego).
- **Outros:** `brightnessctl` (brilho, se houver backlight), `nautilus` (gerenciador de arquivos GTK, tema aplicado), `kitty` (terminal padrão do atalho).
- **Opcional:** `blueman`/`bluez` (Bluetooth), `wttrbar` (alternativa de clima), `power-profiles-daemon` **ou** `tuned`+`tuned-ppd` (perfis de energia), `qt6ct`/`kvantum` (para aproximar tema em apps Qt como Dolphin), fontes Nerd Font (ex.: JetBrains Mono Nerd Font).

> Notas: clima usa `wttr.in` (internet). `lm_sensors` pode precisar de `sudo sensors-detect`. O tema base V7.2 tinha dependências de Omarchy; aqui há fallbacks e alguns módulos Omarchy podem não funcionar sem Omarchy. A tematização GTK aplica-se a apps GTK (ex.: Nautilus); apps Qt (ex.: Dolphin) podem exigir configuração Qt separada.

## Instalação

### Opção rápida (bootstrap, Fedora)
```bash
# clona + instala configs (pergunta se quer instalar dependências via dnf)
curl -fsSL https://raw.githubusercontent.com/alexlambertini/Hyprland-lambertini/main/bootstrap.sh | bash

# para instalar dependências automaticamente (não interativo):
# INSTALL_DEPS=yes curl -fsSL https://raw.githubusercontent.com/alexlambertini/Hyprland-lambertini/main/bootstrap.sh | bash
```

### Manual (após clonar)
```bash
git clone https://github.com/alexlambertini/Hyprland-lambertini.git ~/hypr-waybar-theme
cd ~/hypr-waybar-theme
chmod +x install.sh
./install.sh
```

O `install.sh` faz backup de configs existentes (`*.bak.<timestamp>`), copia os arquivos para `~/.config`, `~/bin` e `~/.local/share/applications` e ajusta permissões.

### Após instalar
```bash
hyprctl reload
pkill waybar; waybar & disown
# dunst e music-notify iniciam no autostart do Hyprland; para iniciar já:
pkill -x dunst 2>/dev/null; dunst &
pkill -f music-notify.sh 2>/dev/null; ~/.config/hypr/scripts/music-notify.sh &
```

## Atalhos principais (Hyprland)

- `SUPER + D` — launcher (Rofi drun)
- `SUPER + RETURN` — terminal (kitty, configurado no lua)
- `SUPER + Q` — fechar janela
- `SUPER + V` — flutuar/tiling + centralizar
- `SUPER + ←/→/↑/↓` — foco entre janelas
- `SUPER + SHIFT + ←/→/↑/↓` — mover janela
- `SUPER + CTRL + ←/→/↑/↓` — redimensionar (segurar repete)
- `SUPER + SHIFT + S` — captura de tela por região (salva em `~/Pictures/Screenshots` e copia para área de transferência)
- `SUPER + 1..0` — workspaces / `SUPER + SHIFT + 1..0` mover para workspace
- Mídia/volume/brilho: teclas XF86 (volume/mute via `wpctl`, brilho via `brightnessctl`, mídia via `playerctl`)

## Waybar: módulos e toggles

- **Clima** (`custom/weather`): temperatura automática — clique para **ocultar/mostrar**.
- **Teclado** (`custom/kblayout`): layout ativo — clique para ocultar/mostrar.
- **Tráfego de rede** (`custom/netspeed`): ↓/↑ na interface — clique para ocultar/mostrar.
- **Disco** (`custom/disk`): uso de `/` — clique para ocultar/mostrar.
- **Temperatura** (`custom/temp`): CPU/GPU via `sensors` — clique para ocultar/mostrar.
- **Microfone** (`custom/mic`): clique esquerdo **muta/ativa**, clique direito **oculta/mostra**.
- **Perfil de energia** (`power-profiles-daemon`): clique/scroll alterna perfis (requer backend PPD/tuned-ppd ativo).
- **Volume** (`pulseaudio`): scroll ajusta, clique muta (`wpctl`).
- **Rede** (`network`): ícone/ESSID (tooltip com tráfego).

Widgets ocultos ficam como **ícone apagado** (clicável) para reexibir. Estado salvo em `~/.config/waybar/.<nome>-enabled`.

## Wallpaper (persistente)

- O repositório inclui wallpapers em `wallpapers/`; o `install.sh` copia para `~/Pictures/Wallpapers` e define um wallpaper padrão em `~/.config/hypr/current-wallpaper` (se não existir).
- Use o app **"Ajustar Wallpaper"** no drun (`bin/hypr-wallpaper-menu`, via `wofi`) para escolher/trocar imagem em `~/Pictures/Wallpapers`.
- A escolha é salva em `~/.config/hypr/current-wallpaper` e restaurada no início do Hyprland (`swaybg`). O wallpaper padrão do Hyprland é desabilitado no `hyprland.lua`.

## Capturas de tela

- `SUPER + SHIFT + S`: seleção de região com `slurp`, captura com `grim`, salva em `~/Pictures/Screenshots/screenshot-YYYYmmdd-HHMMSS.png`, copia para a área de transferência (`wl-copy`) e envia notificação (dunst).
- Dependências: `grim`, `slurp`, `wl-clipboard`.

## Notificações de música

- `dunst` exibe notificações com o tema customizado.
- `~/.config/hypr/scripts/music-notify.sh` detecta trocas de faixa via `playerctl --follow metadata` (MPRIS) e envia notificação “♪ título / artista — álbum”. Players sem MPRIS podem não disparar aviso automático.

## Aplicativos padrão (opcional)

```bash
# Áudio -> Audacious, Vídeo -> mpv (ajuste MIME types conforme necessidade)
xdg-mime default audacious.desktop audio/mpeg audio/flac audio/ogg
xdg-mime default mpv.desktop video/mp4 video/x-matroska video/webm
```

## Notas

- Monitores e teclado estão configurados no `hyprland.lua` (ex.: `HDMI-A-1`/`DVI-D-1`, layout `br abnt2`) — ajuste para seu hardware.
- Gaps: `general.gaps_in/gaps_out` no `hyprland.lua`.
- **Navegador de arquivos:** o tema GTK (`.config/gtk-3.0/gtk-4.0`) aproxima as cores para apps GTK (ex.: **Nautilus**). O atalho `SUPER + E` no config abre **Dolphin** (Qt), que pode exigir `qt6ct`/Kvantum ou esquema de cores KDE para ficar igual; se preferir, troque o bind para `nautilus`.
- Não inclua arquivos de cache/estado pessoal sensível ao versionar; este repositório inclui estados `.enabled` padrão para os widgets.
