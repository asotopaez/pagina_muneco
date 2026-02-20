#!/usr/bin/env bash
# ============================================================
# deploy.sh — Cerrajería San Rafael
# Construye con Cloud Build (sin Docker local) y despliega
# en Google Cloud Run
# ============================================================
# Uso:
#   chmod +x deploy.sh
#   ./deploy.sh
# ============================================================

set -euo pipefail

# ------------------------------------------------------------
# CONFIGURACIÓN
# ------------------------------------------------------------
PROJECT_ID="loterappsort"            # ID del proyecto en Google Cloud
REGION="us-central1"                 # Región de Cloud Run
SERVICE_NAME="cerrajeria-san-rafael" # Nombre del servicio en Cloud Run
IMAGE_NAME="cerrajeria-san-rafael"   # Nombre de la imagen Docker
SA="lotersort-cloudrun-sa@loterappsort.iam.gserviceaccount.com"
# ------------------------------------------------------------

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
step()    { echo -e "\n${BOLD}▶ $*${NC}"; }

# ============================================================
# 0. VALIDACIONES PREVIAS
# ============================================================
step "Verificando pre-requisitos..."

if ! command -v gcloud &>/dev/null; then
  error "Google Cloud SDK no encontrado. Instálalo en: https://cloud.google.com/sdk/docs/install"
fi

if [[ ! -f "Dockerfile" ]]; then
  error "No se encontró el Dockerfile. Ejecuta este script desde la raíz del proyecto."
fi

success "Pre-requisitos verificados."

# ============================================================
# 1. CONFIGURAR PROYECTO EN GCLOUD
# ============================================================
step "Configurando cuenta y proyecto..."

gcloud config set account asotopaez@gmail.com --quiet
gcloud config set project "$PROJECT_ID" --quiet
success "Cuenta:  asotopaez@gmail.com"
success "Proyecto: $PROJECT_ID"

# ============================================================
# 2. HABILITAR APIS NECESARIAS
# ============================================================
step "Habilitando APIs de GCP..."

gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  --project="$PROJECT_ID" \
  --quiet

success "APIs habilitadas."

# ============================================================
# 3. CREAR REPOSITORIO EN ARTIFACT REGISTRY (si no existe)
# ============================================================
REPO_NAME="docker-repo"
REGISTRY="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}"
IMAGE_FULL="${REGISTRY}/${IMAGE_NAME}"

step "Verificando repositorio en Artifact Registry..."

if ! gcloud artifacts repositories describe "$REPO_NAME" \
     --location="$REGION" \
     --project="$PROJECT_ID" &>/dev/null; then

  info "Creando repositorio '$REPO_NAME'..."
  gcloud artifacts repositories create "$REPO_NAME" \
    --repository-format=docker \
    --location="$REGION" \
    --description="Imágenes Docker — Cerrajería San Rafael" \
    --project="$PROJECT_ID"
  success "Repositorio creado: $REGISTRY"
else
  success "Repositorio ya existe: $REGISTRY"
fi

# ============================================================
# 4. BUILD CON CLOUD BUILD (sin Docker local)
# ============================================================
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
IMAGE_TAG="${IMAGE_FULL}:${TIMESTAMP}"
IMAGE_LATEST="${IMAGE_FULL}:latest"

step "Construyendo imagen con Cloud Build..."
info "Imagen: $IMAGE_TAG"
info "(El build ocurre en GCP — no se necesita Docker local)"

gcloud builds submit . \
  --tag="$IMAGE_TAG" \
  --service-account="projects/${PROJECT_ID}/serviceAccounts/${SA}" \
  --default-buckets-behavior=regional-user-owned-bucket \
  --project="$PROJECT_ID" \
  --quiet

# Etiquetar también como latest
gcloud builds submit . \
  --tag="$IMAGE_LATEST" \
  --service-account="projects/${PROJECT_ID}/serviceAccounts/${SA}" \
  --default-buckets-behavior=regional-user-owned-bucket \
  --project="$PROJECT_ID" \
  --quiet

success "Imagen construida y publicada en Artifact Registry."

# ============================================================
# 5. DESPLIEGUE EN CLOUD RUN
# ============================================================
step "Desplegando en Cloud Run..."
info "Servicio: $SERVICE_NAME"
info "Región:   $REGION"

gcloud run deploy "$SERVICE_NAME" \
  --image="$IMAGE_TAG" \
  --region="$REGION" \
  --platform=managed \
  --allow-unauthenticated \
  --port=8080 \
  --memory=256Mi \
  --cpu=1 \
  --min-instances=0 \
  --max-instances=10 \
  --concurrency=1000 \
  --timeout=30 \
  --service-account="$SA" \
  --project="$PROJECT_ID" \
  --quiet

# ============================================================
# 6. OBTENER URL DEL SERVICIO
# ============================================================
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
  --region="$REGION" \
  --project="$PROJECT_ID" \
  --format="value(status.url)")

# ============================================================
# RESUMEN FINAL
# ============================================================
echo ""
echo -e "${BOLD}============================================================${NC}"
echo -e "${GREEN}${BOLD}  DESPLIEGUE EXITOSO${NC}"
echo -e "${BOLD}============================================================${NC}"
echo -e "  Cuenta   : ${BLUE}asotopaez@gmail.com${NC}"
echo -e "  SA       : ${BLUE}${SA}${NC}"
echo -e "  Proyecto : ${BLUE}${PROJECT_ID}${NC}"
echo -e "  Servicio : ${BLUE}${SERVICE_NAME}${NC}"
echo -e "  Región   : ${BLUE}${REGION}${NC}"
echo -e "  Imagen   : ${BLUE}${IMAGE_TAG}${NC}"
echo -e "  URL      : ${GREEN}${BOLD}${SERVICE_URL}${NC}"
echo -e "${BOLD}============================================================${NC}"
echo ""
info "Tip: Para ver los logs en tiempo real ejecuta:"
echo "     gcloud run services logs tail $SERVICE_NAME --region=$REGION"
echo ""
