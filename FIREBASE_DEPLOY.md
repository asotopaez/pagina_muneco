# Guía: Firebase Hosting + Dominio cerrajeriasanrafael.com (GoDaddy)

## Resumen del proceso

```
Instalar CLI → Login → Init → Deploy → Conectar dominio → Configurar DNS en GoDaddy
```

---

## Paso 1 — Instalar Firebase CLI

```bash
npm install -g firebase-tools

# Verificar instalación
firebase --version
```

> Si no tienes Node.js: https://nodejs.org/en/download (versión LTS)

---

## Paso 2 — Autenticarte con tu cuenta de Google

```bash
firebase login
```

- Abrirá el navegador
- Inicia sesión con **asotopaez@gmail.com** (la misma del proyecto GCP)
- Acepta los permisos

---

## Paso 3 — Inicializar Firebase en el proyecto

Desde la carpeta del proyecto `/home/asotopaez/pagina_muneco`:

```bash
firebase init hosting
```

Responde las preguntas así:

```
? Please select an option:
  → Use an existing project

? Select a default Firebase project:
  → loterappsort

? What do you want to use as your public directory?
  → .                          ← punto (directorio actual)

? Configure as a single-page app (rewrite all urls to /index.html)?
  → Yes

? Set up automatic builds and deploys with GitHub?
  → No

? File ./index.html already exists. Overwrite?
  → No                         ← MUY IMPORTANTE: No sobreescribir
```

Esto crea dos archivos:
- `.firebaserc` — vincula al proyecto loterappsort
- `firebase.json` — configuración del hosting

---

## Paso 4 — Ajustar firebase.json

Reemplaza el contenido de `firebase.json` con esto para agregar cache headers:

```json
{
  "hosting": {
    "public": ".",
    "ignore": [
      "firebase.json",
      ".firebaserc",
      ".dockerignore",
      "Dockerfile",
      "nginx.conf",
      "deploy.sh",
      "*.sh",
      "*.md",
      ".git/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(css|js|svg|ico|png|jpg|jpeg|gif|webp|woff|woff2)",
        "headers": [
          { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
        ]
      },
      {
        "source": "**/*.html",
        "headers": [
          { "key": "Cache-Control", "value": "no-cache" }
        ]
      }
    ]
  }
}
```

---

## Paso 5 — Primer despliegue

```bash
firebase deploy --only hosting
```

Verás algo así:

```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/loterappsort/overview
Hosting URL: https://loterappsort.web.app
```

Prueba que funcione en: **https://loterappsort.web.app**

---

## Paso 6 — Conectar dominio cerrajeriasanrafael.com

### 6.1 Agregar dominio en Firebase Console

1. Ve a: https://console.firebase.google.com/project/loterappsort/hosting
2. Haz clic en **"Add custom domain"**
3. Escribe: `cerrajeriasanrafael.com`
4. Haz clic en **Continue**

Firebase te mostrará **dos registros TXT** para verificar que eres dueño del dominio:

```
Tipo: TXT
Host: @  (o cerrajeriasanrafael.com)
Valor: firebase=loterappsort-xxxx (Firebase te da este valor)
```

> **Copia estos valores**, los necesitas en el siguiente paso.

---

## Paso 7 — Configurar DNS en GoDaddy

### 7.1 Entrar al panel de GoDaddy

1. Ve a https://dcc.godaddy.com
2. Inicia sesión
3. En **"Mis productos"**, busca `cerrajeriasanrafael.com`
4. Haz clic en **"DNS"** o **"Administrar DNS"**

---

### 7.2 Agregar registro TXT (verificación de dominio)

En la tabla de registros DNS, haz clic en **"Agregar"**:

| Campo | Valor |
|---|---|
| Tipo | `TXT` |
| Host | `@` |
| TXT Value | `firebase=loterappsort-xxxx` ← el que te dio Firebase |
| TTL | 1 hora (600 segundos) |

Haz clic en **Guardar**.

---

### 7.3 Volver a Firebase y verificar

1. En Firebase Console, haz clic en **"Verify"**
2. Puede tardar entre **1 y 30 minutos** en propagarse
3. Una vez verificado, Firebase te mostrará los **registros A** a configurar

Firebase te dará algo así:

```
Tipo: A     Host: @     Valor: 151.101.1.195
Tipo: A     Host: @     Valor: 151.101.65.195
```

---

### 7.4 Agregar registros A en GoDaddy

De regreso en GoDaddy → DNS, **elimina** cualquier registro `A` que apunte a `@` (el que GoDaddy pone por defecto con su IP) y agrega los de Firebase:

**Registro A #1:**

| Campo | Valor |
|---|---|
| Tipo | `A` |
| Host | `@` |
| Apunta a | `151.101.1.195` ← usar el valor real de Firebase |
| TTL | 1 hora |

**Registro A #2:**

| Campo | Valor |
|---|---|
| Tipo | `A` |
| Host | `@` |
| Apunta a | `151.101.65.195` ← usar el valor real de Firebase |
| TTL | 1 hora |

---

### 7.5 Agregar subdominio www (opcional pero recomendado)

Para que `www.cerrajeriasanrafael.com` también funcione:

**Opción A — CNAME hacia Firebase:**

| Campo | Valor |
|---|---|
| Tipo | `CNAME` |
| Host | `www` |
| Apunta a | `loterappsort.web.app` |
| TTL | 1 hora |

O bien agrega `www.cerrajeriasanrafael.com` como segundo dominio en Firebase Console repitiendo el proceso.

---

## Paso 8 — Esperar propagación DNS

La propagación DNS puede tardar entre **30 minutos y 48 horas** (GoDaddy suele ser rápido, normalmente en 1-2 horas).

Puedes verificar el estado en:
```bash
# Verificar que el DNS ya apunta a Firebase
nslookup cerrajeriasanrafael.com
dig cerrajeriasanrafael.com A
```

Una vez propagado, Firebase emite el **certificado SSL automáticamente** (Let's Encrypt). En 24 horas el sitio estará en:

```
https://cerrajeriasanrafael.com        ← con HTTPS
https://www.cerrajeriasanrafael.com    ← con HTTPS
```

---

## Comandos de uso diario

```bash
# Redesplegar después de cambios
firebase deploy --only hosting

# Ver el sitio en preview local antes de desplegar
firebase serve

# Ver estado del hosting
firebase hosting:sites:list
```

---

## Resumen de archivos que genera Firebase

```
pagina_muneco/
├── .firebaserc      ← proyecto vinculado (loterappsort)
└── firebase.json    ← config de hosting, ignore y cache headers
```

Estos dos archivos deben subirse al repositorio con git.

---

## Tabla resumen de DNS en GoDaddy

| Tipo | Host | Valor | Para qué |
|---|---|---|---|
| `TXT` | `@` | `firebase=xxxx` | Verificar propiedad del dominio |
| `A` | `@` | IP #1 de Firebase | Apuntar dominio raíz a Firebase |
| `A` | `@` | IP #2 de Firebase | Redundancia |
| `CNAME` | `www` | `loterappsort.web.app` | Subdominio www |

> Las IPs exactas te las da Firebase Console al conectar el dominio.
> **No uses las IPs de este documento** — Firebase te asigna IPs específicas para tu proyecto.
