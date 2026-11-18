-- Botao "Editar notas" do widget de Notas do Conky.
--
-- Recebe os eventos de mouse do Conky e, num clique esquerdo sobre a ultima
-- linha do widget (o botao "Editar notas"), abre o notes.txt no editor
-- grafico (gnome-text-editor).
--
-- O evento nao traz o tamanho da janela, mas o Conky expoe o global
-- `conky_window`, que da a margem interna (border_inner_margin) e a altura
-- da area de texto (text_height). O botao e a ultima linha dessa area.

local HOME   = os.getenv("HOME") or ""
local NOTES  = HOME .. "/.config/conky/notes.txt"
local EDITOR = "gnome-text-editor"

-- Faixa vertical do botao (px, relativa a janela): ultima linha do texto.
local function button_band()
  local cw = conky_window
  if not cw or not cw.text_height then return nil end
  local margin = cw.border_inner_margin or 14
  local bottom = margin + cw.text_height
  return bottom - 20, bottom + 2
end

function conky_on_mouse(event)
  if event.type == "button_down" and event.button == "left" then
    local top, bottom = button_band()
    if top and event.y >= top and event.y <= bottom then
      os.execute(string.format("setsid %s '%s' >/dev/null 2>&1 &", EDITOR, NOTES))
      return true
    end
  end
  return false
end
