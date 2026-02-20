# Cerrajería San Rafael — Sitio Web Oficial

Sitio web estático de una sola página (single-page) para **Cerrajería San Rafael**, empresa de servicios de cerrajería 24/7 en Ciudad de México y Estado de México.

---

## Descripción

Página de presentación y generación de contacto para la empresa. El objetivo principal es convertir visitas en clientes a través de botones directos de WhatsApp y Facebook, comunicando de forma clara los servicios, zonas de cobertura y diferenciadores de la marca.

### Características

- **One-page** con navegación por scroll suave y header sticky
- **Botón flotante de WhatsApp** con animación pulsante, siempre visible
- **Llamadas directas** a WhatsApp y teléfono desde cualquier sección
- **Enlace a Facebook** con apertura en nueva pestaña
- **Responsive** — optimizado para móvil (375px), tablet (768px) y escritorio (1100px+)
- **Sin dependencias externas** — HTML5 + CSS3 + Vanilla JS puro (solo Google Fonts vía CDN)
- **Accesible** — atributos ARIA, navegación por teclado, contraste de colores
- **SEO básico** — meta description, Open Graph tags para Facebook, robots meta

### Secciones

| Sección | Descripción |
|---|---|
| Hero | Propuesta de valor, badge de disponibilidad en tiempo real, stats clave, 2 CTAs |
| Servicios | Tarjetas para Casa, Automóviles y Empresas con lista de sub-servicios |
| ¿Por qué elegirnos? | Stats de confianza: 24/7, certificados, 20 min de respuesta, +500 clientes |
| Zonas de Cobertura | Badges para CDMX (Reforma, Centro) y Estado de México (Tecamachalco, Interlomas, Naucalpan, Santa Fe, Bosques) |
| Quiénes Somos | Presentación de la empresa y valores |
| Contacto | CTA final con botones grandes de WhatsApp, teléfono y Facebook |

---

## Tecnologías

| Capa | Tecnología |
|---|---|
| Markup | HTML5 semántico |
| Estilos | CSS3 con Custom Properties (variables) |
| Interacción | Vanilla JavaScript (ES6+) |
| Tipografía | Google Fonts — Cinzel + Open Sans |
| Servidor (producción) | nginx:alpine |
| Contenedor | Docker |
| Despliegue | Google Cloud Run |

---

## Branding

| Token | Valor |
|---|---|
| Color primario (dorado) | `#D4AF37` |
| Color dorado claro | `#F0C040` |
| Color dorado oscuro | `#B8960C` |
| Color negro | `#1A1A1A` |
| Color blanco | `#FFFFFF` |
| Fuente de títulos | Cinzel (serif) |
| Fuente de cuerpo | Open Sans (sans-serif) |

---

## Estructura del proyecto

```
pagina_muneco/
├── index.html          # Página principal (toda la app en un archivo)
├── css/
│   └── styles.css      # Estilos — design tokens, componentes, media queries
├── js/
│   └── main.js         # Interacciones — scroll, menú, animaciones, WA links
├── assets/
│   ├── logo.svg        # Logo completo (escudo + llave + texto)
│   └── favicon.svg     # Ícono del tab del navegador
├── nginx.conf          # Configuración de nginx para Cloud Run
├── Dockerfile          # Imagen Docker para servir el sitio
├── .dockerignore       # Archivos excluidos del contexto Docker
├── deploy.sh           # Script de despliegue a Cloud Run
└── README.md           # Este archivo
```

---

## Desarrollo local

### Opción A — Abrir directamente

```bash
# Abrir en el navegador sin servidor
open index.html        # macOS
xdg-open index.html    # Linux
start index.html       # Windows
```

### Opción B — Servidor local con Python

```bash
python3 -m http.server 8080
# Abrir: http://localhost:8080
```

### Opción C — Con Docker (idéntico a producción)

```bash
docker build -t cerrajeria-san-rafael .
docker run -p 8080:8080 cerrajeria-san-rafael
# Abrir: http://localhost:8080
```

---

## Despliegue en Google Cloud Run

### Pre-requisitos

1. Tener instalado [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
2. Tener instalado [Docker](https://docs.docker.com/get-docker/)
3. Autenticarse en Google Cloud:
   ```bash
   gcloud auth login
   gcloud auth configure-docker
   ```
4. Tener un proyecto en Google Cloud con **Cloud Run API** y **Artifact Registry API** habilitadas

### Despliegue rápido

```bash
# 1. Editar las variables del script
nano deploy.sh        # Cambiar PROJECT_ID y REGION

# 2. Dar permisos de ejecución
chmod +x deploy.sh

# 3. Ejecutar
./deploy.sh
```

El script realiza automáticamente:
- Build de la imagen Docker
- Push al Artifact Registry de Google Cloud
- Despliegue en Cloud Run con acceso público
- Muestra la URL final del servicio

### Variables configurables en `deploy.sh`

| Variable | Descripción | Ejemplo |
|---|---|---|
| `PROJECT_ID` | ID de tu proyecto en GCP | `mi-proyecto-123` |
| `REGION` | Región de Cloud Run | `us-central1` |
| `SERVICE_NAME` | Nombre del servicio en Cloud Run | `cerrajeria-san-rafael` |
| `IMAGE_NAME` | Nombre de la imagen Docker | `cerrajeria-san-rafael` |

---

## Contacto del negocio

| Canal | Datos |
|---|---|
| WhatsApp | [+52 56 1548 6432](https://wa.me/5215615486432) |
| Facebook | [Cerrajería San Rafael](https://www.facebook.com/profile.php?id=100067037716280) |
| Cobertura | CDMX (Reforma, Centro) · Estado de México (Tecamachalco, Interlomas, Naucalpan, Santa Fe, Bosques) |

---

## Licencia

Proyecto privado. Todos los derechos reservados © Cerrajería San Rafael.
