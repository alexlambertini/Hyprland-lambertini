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
- `bin/hypr-wallpaper-menu` — seletor de wallpaper (wofi) com persistência via `swaybg`.
- `.local/share/applications/hypr-wallpaper.desktop` — atalho no drun para o seletor de wallpaper.
- `wallpapers/` — wallpapers incluídos (copiados para `~/Pictures/Wallpapers` pelo `install.sh`).

## Dependências

### Pacotes (Fedora)
```bash
sudo dnf install -y \
  waybar rofi dunst jq curl lm_sensors \
  mpv audacious playerctl \
  swaybg wofi wl-clipboard \
  brightnessctl
```

- **PipeWire/WirePlumber**: áudio/volume/microfone (`wpctl`).
- **Perfis de energia**: funciona com `power-profiles-daemon` **ou** `tuned` + `tuned-ppd` (exposto via D-Bus; o módulo alterna perfis via `busctl`).
- **Rede**: `nmcli`/`ip` (NetworkManager) para interface/tráfego.
- **Clima**: usa `https://wttr.in` (requer internet). Localização automática por IP.
- **Sensores**: `lm_sensors` (`sensors`). Pode ser necessário `sudo sensors-detect` em alguns hardwares.

> O tema base V7.2 tinha dependências de Omarchy (`omarchy-*`, `$OMARCHY_PATH`, CSS de tema Omarchy). Nesta versão o `style.css` usa cores fallback e módulos Omarchy específicos podem não funcionar; foram mantidos no config onde não atrapalham.

## Instalação (após clonar)

```bash
git clone <URL_DO_REPOSITORIO> ~/hypr-waybar-theme
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

- Use o app **"Ajustar Wallpaper"** no drun (`bin/hypr-wallpaper-menu`, via `wofi`) para escolher imagem em `~/Pictures/Wallpapers`.
- A escolha é salva em `~/.config/hypr/current-wallpaper` e restaurada no início do Hyprland (`swaybg`). O wallpaper padrão do Hyprland é desabilitado no `hyprland.lua`.

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
- Não inclua arquivos de cache/estado pessoal sensível ao versionar; este repositório inclui estados `.enabled` padrão para os widgets.
