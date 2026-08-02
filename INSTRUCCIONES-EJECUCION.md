# 🚀 Guía de Ejecución - Sistema POS Ferretería Bolivia

## ⚡ 1. MODO DESARROLLO (2-EN-1 con Recarga en Vivo / Hot Reload)

Para modificar el código y ver los cambios al instante tanto en el Backend como en el Frontend sin andar haciendo `cd` manual:

```powershell
npm run all
```
*(O también `npm start`, `npm run dev` o haciendo doble clic en `dev.bat`)*

### ¿Qué hace este comando?
- ⚡ Ejecuta **NestJS Backend** en el puerto `3000` con recarga automática.
- ⚡ Ejecuta **Angular Frontend** en el puerto `4200` con recarga automática.
- 🎨 Muestra ambos logs unificados con etiquetas de colores (`[BACKEND]` y `[FRONTEND]`) en una sola terminal.

---

## 🐳 2. MODO DOCKER (Contenedores + Base de Datos Automatizada)

```powershell
npm run docker:up
# o directamente:
docker-compose up --build -d
```

---

## 🔑 Usuarios y Contraseñas Simples para Pruebas

Para facilitarte las pruebas, **la contraseña para TODOS los usuarios es simplemente: `123`**

| Rol | Email | Contraseña |
| :--- | :--- | :--- |
| 🛡️ **Administrador** | `admin@ferreteria.com` | `123` |
| 👔 **Gerente** | `gerente@ferreteria.com` | `123` |
| 🛒 **Vendedor** | `vendedor@ferreteria.com` | `123` |
| 📦 **Almacenero** | `almacen@ferreteria.com` | `123` |

---

## 🌐 Puertos del Sistema

- **Frontend Angular (Dev)**: `http://localhost:4200`
- **Frontend Angular (Docker)**: `http://localhost:8080`
- **Backend API (NestJS)**: `http://localhost:3000`
- **pgAdmin (Base de Datos)**: `http://localhost:5050` (`admin@ferreteria.com` / `admin`)

---
**POS Ferretería Bolivia v1.0** | 2026
