#!/bin/bash
# Mostra botão do assistente OpenCode apenas se estiver instalado
if command -v opencode >/dev/null 2>&1 || [ -x "$HOME/.opencode/bin/opencode" ]; then
  echo '{"text":"󰚩","tooltip":"Assistente (OpenCode)\nClique para abrir/fechar | Atalho: SUPER + A","class":"enabled"}'
else
  echo '{"text":"","tooltip":"","class":"disabled"}'
fi
