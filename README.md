# Tema/Setup Hyprland + Waybar (V7.2 customizado)

Conjunto de configurações para **Hyprland (Lua, 0.57+)**, **Waybar** (baseado no tema V7.2 de [HANCORE-linux/waybar-themes](https://github.com/HANCORE-linux/waybar-themes)), **Rofi** (drun), **Dunst** e notificações de música (MPRIS/playerctl), com visual unificado (fundo escuro translúcido, texto `#cccccc`, destaque `#df6124`).

> Ambiente de referência: Fedora 44, Hyprland 0.57, Waybar, PipeWire/WirePlumber, Rofi, Dunst. Ajustes podem ser necessários em outras distros/hardware.

## Conteúdo

- `.config/waybar/` — `config.jsonc`, `style.css` e scripts de widgets (clima, microfone, disco, tráfego de rede, layout de teclado, temperatura, toggles).
- `.config/hypr/hyprland.lua` — atalhos, animações, gaps, restauração de wallpaper, autostart de dunst/notificação de música.
- `.config/hypr/scripts/music-notify.sh` — notificação de faixa via `playerctl` + `notify-send`.
- `.config/hypr/scripts/screenshot-region.sh` — captura de região (`grim` + `slurp`) com cópia para área de transferência e notificação.
- `.config/hypr/current-wallpaper` — caminho do wallpaper padrão/restaurado.
- `.config/hypr/custom-binds.json` / `custom-binds.lua` — atalhos personalizados, editáveis pelo app **Atalhos do Sistema** (sem editar o `hyprland.lua`).
- `.config/hypr/hypridle.conf` / `hyprlock.conf` — inatividade (bloqueio/desligar tela) e tela de bloqueio.
- `.config/rofi/` — tema/config do launcher (drun/run/window), calculadora (`ALT+C`), combi e navegador de arquivos.
- `.config/dunst/dunstrc` — notificações no mesmo visual.
- `.config/kitty/kitty.conf` — terminal Kitty com cores do tema, transparência, padding e ajustes visuais (cursor/abas).
- `.config/gtk-3.0/` e `.config/gtk-4.0/` — ajustes de tema/cores GTK (aproxima o visual para apps GTK como Nautilus).
- `.config/conky/` — widgets de área de trabalho no tema Waybar: dashboard (relógio/calendário/clima/mídia), sistema (CPU/RAM/disco/rede/top) e notas; scripts `weather-short.sh`/`now-playing.sh` e estado `widgets.json`.
- `.local/bin/widgets-config` — **Painel de Widgets** (GTK): habilita/desabilita, escolhe a coluna e o espaçamento (aberto pelo drun).
- `.local/bin/widgets-apply` — aplica o layout dos widgets (mede a altura real e empilha com espaçamento uniforme).
- `.local/bin/conky-toggle` — liga/desliga os widgets habilitados (`CTRL+SHIFT+M`).
- `.local/bin/hypr-binds-config` — **Atalhos do Sistema** (ver atalhos atuais e adicionar personalizados).
- `.local/bin/hypridle-config` — configura inatividade/bloqueio de tela.
- `.local/bin/pavucontrol` — lançador do controle de áudio (usa `~/.local/opt` se existir, senão o `pavucontrol` do sistema).
- `bin/hypr-wallpaper-menu` — seletor de wallpaper (wofi) com persistência via `swaybg`.
- `bin/hypr-resolution-menu` — seletor de resolução/monitor (rofi + `hyprctl`/`wlr-randr`).
- `.local/share/applications/*.desktop` — atalhos no drun: ajustar wallpaper/resolução, **Atalhos do Sistema**, **Inatividade e Bloqueio** e **Painel de Widgets**.
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
  conky \
  pavucontrol \
  playerctl \
  mpv audacious \
  pipewire pipewire-pulseaudio wireplumber \
  NetworkManager \
  brightnessctl \
  nautilus \
  papirus-icon-theme \
  kitty \
  chromium
```

**Para que serve cada grupo:**
- **Hyprland + Waybar:** compositor e barra (`hyprland`, `waybar`).
- **Launcher/menu:** `rofi` (drun `SUPER+D`), `wofi` (seletor de wallpaper).
- **Notificações:** `dunst` + `libnotify` (`notify-send`), incluindo avisos de música/captura.
- **Wallpaper:** `swaybg` (aplicação/restauração do papel de parede).
- **Captura de tela:** `grim`, `slurp`, `wl-clipboard` (`SUPER+SHIFT+S`).
- **Scripts/widgets:** `jq`, `curl` (clima, teclado, parse), `lm_sensors` (temperatura).
- **Widgets de área de trabalho:** `conky` (dashboard/sistema/notas na área de trabalho, no tema Waybar).
- **Mídia:** `playerctl` (controles/MPRIS e notificação de faixa), `mpv` (vídeo), `audacious` (música).
- **Áudio:** `pipewire`, `pipewire-pulseaudio`, `wireplumber`, `wpctl` (volume/microfone).
- **Rede:** `NetworkManager` (`nmcli`/interface e tráfego).
- **Outros:** `brightnessctl` (brilho, se houver backlight), `nautilus` (gerenciador de arquivos GTK, tema aplicado, padrão em `SUPER+E`), `papirus-icon-theme` (ícones Papirus Dark), `kitty` (terminal padrão do atalho).
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
- `SUPER + A` — abrir/fechar **OpenCode Assistente** (painel lateral/scratchpad)
- `SUPER + Q` — fechar janela
- `SUPER + V` — flutuar/tiling + centralizar
- `SUPER + ←/→` — workspaces anterior/próximo (áreas de trabalho)
- `SUPER + ↑/↓` — alternar entre monitores (indo e voltando)
- `SUPER + SHIFT + ←/→/↑/↓` — mover janela
- `SUPER + CTRL + ←/→/↑/↓` — redimensionar (segurar repete)
- `SUPER + SHIFT + S` — captura de tela por região (salva em `~/Pictures/Screenshots` e copia para área de transferência)
- `SUPER + S` — **Atalhos do Sistema** (ver atalhos atuais e adicionar personalizados)
- `ALT + C` — calculadora (Rofi calc)
- `CTRL + SHIFT + M` — ligar/desligar os widgets de área de trabalho (Conky)
- `SUPER + SHIFT + A` — controle de áudio (pavucontrol)
- `SUPER + 1..0` — workspaces / `SUPER + SHIFT + 1..0` mover para workspace
- Mídia/volume/brilho: teclas XF86 (volume/mute via `wpctl`, brilho via `brightnessctl`, mídia via `playerctl`)

## Waybar: módulos e toggles

- **Assistente/OpenCode** (`custom/opencode`): botão na barra (exibido apenas se o `opencode` estiver instalado) para abrir/fechar o painel lateral (também via `SUPER + A`).
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

## Widgets de área de trabalho (Conky)

- Widgets no tema Waybar (fundo translúcido, texto `#cccccc`, destaque `#df6124`) na área de trabalho, **atrás** das janelas:
  - **Dashboard** — relógio, data, calendário, clima (`wttr.in`) e “tocando agora” (`playerctl`).
  - **Sistema** — CPU, RAM, disco, rede e top 5 processos.
  - **Notas / Lembretes** — lê `~/.config/conky/notes.txt` (editável).
- **Painel de Widgets** (drun → “Painel de Widgets”, ou `~/.local/bin/widgets-config`): abas por widget para **ativar/desativar**, escolher a **coluna** (Direita/Esquerda), a **margem lateral** e o **espaçamento entre widgets**; o botão *Salvar e aplicar* recalcula as posições e reinicia os widgets.
- **`CTRL + SHIFT + M`** liga/desliga os widgets habilitados (`~/.local/bin/conky-toggle`).
- Estado em `~/.config/conky/widgets.json`. O `~/.local/bin/widgets-apply` mede a **altura real** de cada widget e os empilha (como um *float*), com espaçamento uniforme e sem sobreposição.

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

## OpenCode Assistente (lateral, Web UI)

- **`SUPER + A`** ou botão **`custom/opencode`** na Waybar: executa `~/.config/hypr/scripts/opencode-web-panel.sh` para abrir/fechar a **Web UI do OpenCode** (`opencode serve`) em uma janela dedicada do **Chromium** (modo `--app`, classe `opencode-web`) como painel lateral **lado a lado** (tiled), dividindo a tela.
- Se a workspace não tiver outras janelas, o painel abre ocupando **100%** do espaço; se houver janelas, abre à direita dividindo a tela.
- O script inicia `opencode serve` em `127.0.0.1:4096` (se necessário) e abre `http://127.0.0.1:4096/`. Requer `opencode`, `chromium`, `curl`, `jq` e `nc`.

## Aplicativos padrão (opcional)

```bash
# Áudio -> Audacious, Vídeo -> mpv (ajuste MIME types conforme necessidade)
xdg-mime default audacious.desktop audio/mpeg audio/flac audio/ogg
xdg-mime default mpv.desktop video/mp4 video/x-matroska video/webm
```

## Terminal (Kitty)

- Config em `.config/kitty/kitty.conf`: fonte JetBrains Mono Nerd Font, paleta/cores do tema (`#1e1e2e`, `#cccccc`, `#df6124`), fundo com transparência, padding, cursor em *beam* com blink/trail, abas estilizadas e integração com shell.
- Após instalar, recarregue o Kitty com `Ctrl+Shift+F5` (ou reabra o terminal).

## Notas

- Monitores e teclado estão configurados no `hyprland.lua` (ex.: `HDMI-A-1`/`DVI-D-1`, layout `br abnt2`) — ajuste para seu hardware.
- Gaps: `general.gaps_in/gaps_out` no `hyprland.lua`.
- **Navegador de arquivos:** `SUPER + E` abre o **Nautilus** (GTK), que usa o tema GTK incluído (`.config/gtk-3.0/gtk-4.0`) para combinar com o visual. Se preferir Dolphin (Qt), será necessário configurar `qt6ct`/Kvantum e ajustar `fileManager` no `hyprland.lua`.
- Não inclua arquivos de cache/estado pessoal sensível ao versionar; este repositório inclui estados `.enabled` padrão para os widgets.
