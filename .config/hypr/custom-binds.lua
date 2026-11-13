-- Atalhos personalizados (gerenciado por: hypr-binds-config / "Atalhos do Sistema")
-- NÃO edite manualmente: alterações podem ser sobrescritas pelo painel.

-- Abrir Atalhos Personalizados
hl.bind("SUPER + S", hl.dsp.exec_cmd("/home/lambertini/.local/bin/hypr-binds-config"))

-- Calculadora
hl.bind("ALT + C", hl.dsp.exec_cmd("rofi -show calc"))

-- Desligar todos os widgets
hl.bind("SHIFT + CTRL + M", hl.dsp.exec_cmd("pkill -x conky"))
