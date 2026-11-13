#!/bin/bash
# Calculadora para rofi (usa qalc)
if [ -z "${1:-}" ]; then
  echo "Digite uma expressão (ex: 2+2, 10km em m, 100 USD em BRL)"
  exit 0
fi
qalc -t "$*" 2>/dev/null || echo "Erro na expressão"
