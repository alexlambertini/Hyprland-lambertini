-- Tooltip de feriados para o calendario do Conky.
-- Recebe eventos de mouse (coordenadas relativas a janela) e, quando o
-- cursor passa sobre um dia que e feriado, mostra o nome via dunst.
--
-- A geometria abaixo precisa casar com o widget (conky.conf + calendar.sh):
--   - border_inner_margin = 14, fonte do calendario = size 9 (CW ~= 7.2)
--   - o bloco do mes atual comeca no caractere 0; o do proximo, no 26
--   - a 1a linha de dias comeca em y=87; cada linha tem 17px de altura

local HOME  = os.getenv("HOME") or ""
local STATE = HOME .. "/.config/conky/calendar-state.lua"

local MARGIN    = 14
local CW        = 7.2
local LEFT0     = 0
local RIGHT0    = 26
local BLOCK_W   = 20
local ROW_TOP   = 87
local ROW_PITCH = 17
local NROWS     = 6

local state, shown_id, shown_key = nil, nil, nil

local function load_state()
  local f = io.open(STATE, "r")
  if not f then return nil end
  local src = f:read("*a"); f:close()
  local fn = load or loadstring
  if not fn then return nil end
  local chunk = fn(src)
  if not chunk then return nil end
  local ok, res = pcall(chunk)
  if ok and type(res) == "table" then return res end
  return nil
end

local function close_tip()
  if shown_id and shown_id ~= "" then
    os.execute("dunstify -C " .. shown_id .. " >/dev/null 2>&1")
  end
  shown_id, shown_key = nil, nil
end

local function open_tip(key, name)
  if shown_key == key then return end            -- ja mostrando este feriado
  close_tip()
  local cmd = string.format(
    "dunstify -a Calendario --stack-tag=conky-feriado -t 5000 -p 'Feriado' '%s' 2>/dev/null",
    name)
  local h = io.popen(cmd)
  if h then
    shown_id = h:read("*l")
    h:close()
  end
  shown_key = key
end

local function handle(x, y)
  if not state then return end
  local row = math.floor((y - ROW_TOP) / ROW_PITCH)
  if row < 0 or row >= NROWS then return close_tip() end
  local cx = (x - MARGIN) / CW
  local block, c
  if cx >= LEFT0 and cx < LEFT0 + BLOCK_W then
    block, c = "L", cx - LEFT0
  elseif cx >= RIGHT0 and cx < RIGHT0 + BLOCK_W then
    block, c = "R", cx - RIGHT0
  else
    return close_tip()
  end
  local col  = math.floor(c / 3)
  local grid = state.grid and state.grid[block]
  local r    = grid and grid[row + 1]
  local day  = r and r[col + 1]
  if not day or day == 0 then return close_tip() end
  local key  = tostring(state.month[block]) .. "-" .. tostring(day)
  local name = state.holidays and state.holidays[key]
  if name then open_tip(key, name) else close_tip() end
end

function conky_on_mouse(event)
  if event.type == "mouse_leave" then
    close_tip()
  elseif event.type == "mouse_enter" then
    state = load_state()
    handle(event.x, event.y)
  elseif event.type == "mouse_move" then
    if not state then state = load_state() end
    handle(event.x, event.y)
  end
  return false
end
