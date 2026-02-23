#!/usr/bin/env bash
# ============================================================
# deploy.sh — Cerrajería San Rafael
# Despliega el sitio estático en Firebase Hosting
# ============================================================
# Uso:
#   chmod +x deploy.sh
#   ./deploy.sh
# ============================================================

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
step()    { echo -e "\n${BOLD}▶ $*${NC}"; }

# ============================================================
# 0. VALIDACIONES PREVIAS
# ============================================================
step "Verificando pre-requisitos..."

if ! command -v firebase &>/dev/null; then
  error "Firebase CLI no encontrado. Instálalo con: npm install -g firebase-tools"
fi

if [[ ! -f "firebase.json" ]]; then
  error "No se encontró firebase.json. Ejecuta primero: firebase init hosting"
fi

if [[ ! -f "index.html" ]]; then
  error "No se encontró index.html. Ejecuta este script desde la raíz del proyecto."
fi

success "Pre-requisitos verificados."

# ============================================================
# 1. DESPLIEGUE EN FIREBASE HOSTING
# ============================================================
step "Desplegando en Firebase Hosting..."

firebase deploy --only hosting

# ============================================================
# 2. OBTENER URL DEL SITIO
# ============================================================
SITE_URL=$(firebase hosting:sites:list --json 2>/dev/null \
  | grep -o '"defaultUrl":"[^"]*"' \
  | head -1 \
  | sed 's/"defaultUrl":"//;s/"//')

# ============================================================
# RESUMEN FINAL
# ============================================================
echo ""
echo -e "${BOLD}============================================================${NC}"
echo -e "${GREEN}${BOLD}  DESPLIEGUE EXITOSO${NC}"
echo -e "${BOLD}============================================================${NC}"
echo -e "  Proyecto : ${BLUE}loterappsort${NC}"
echo -e "  URL      : ${GREEN}${BOLD}https://loterappsort.web.app${NC}"
if [[ -n "$SITE_URL" ]]; then
echo -e "  URL alt  : ${GREEN}${BOLD}${SITE_URL}${NC}"
fi
echo -e "${BOLD}============================================================${NC}"
echo ""
info "Tip: Para ver el sitio en local antes de desplegar ejecuta:"
echo "     firebase serve"
echo ""
