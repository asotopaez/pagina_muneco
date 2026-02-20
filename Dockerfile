# ============================================================
# Cerrajería San Rafael — Dockerfile
# Sirve los archivos estáticos con nginx en Google Cloud Run
# ============================================================

FROM nginx:1.27-alpine

# Metadatos de la imagen
LABEL maintainer="Cerrajería San Rafael"
LABEL description="Sitio web estático de Cerrajería San Rafael"

# Eliminar la configuración default de nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copiar nuestra configuración como template
# nginx:alpine procesa automáticamente /etc/nginx/templates/*.template
# sustituyendo variables de entorno (ej: $PORT) al iniciar el contenedor
COPY nginx.conf /etc/nginx/templates/default.conf.template

# Copiar los archivos estáticos del sitio
COPY index.html   /usr/share/nginx/html/
COPY css/         /usr/share/nginx/html/css/
COPY js/          /usr/share/nginx/html/js/
COPY assets/      /usr/share/nginx/html/assets/

# Cloud Run usa el puerto definido en la variable de entorno PORT
# El default es 8080; lo establecemos como valor por defecto
ENV PORT=8080

# Documentar el puerto expuesto
EXPOSE 8080

# nginx:alpine ya trae el entrypoint correcto que procesa los templates
# CMD heredado: ["nginx", "-g", "daemon off;"]
