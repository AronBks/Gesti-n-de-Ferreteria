@echo off
echo.
echo =============================================================================
echo  🐳 FERRETERÍA POS - INICIO CON DOCKER COMPOSE AUTOMÁTICO
echo =============================================================================
echo.

docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Docker Desktop no está instalado o ejecutándose.
    echo Por favor inicia Docker Desktop y vuelve a intentar.
    pause
    exit /b 1
)

echo 🚀 Levantando Contenedores (PostgreSQL + Backend + Frontend + pgAdmin)...
docker-compose up --build -d

echo.
echo =============================================================================
echo  ✅ SISTEMA POS DESPLEGADO EXITOSAMENTE
echo =============================================================================
echo.
echo  🌐 Frontend (Angular): http://localhost:4200
echo  ⚙️ Backend (NestJS):  http://localhost:3000
echo  🗄️ pgAdmin (BD UI):  http://localhost:5050 (admin@ferreteria.com / admin)
echo.
echo  🔐 CREDENCIALES DE ACCESO:
echo      Email: admin@ferreteria.com
echo      Pass:  Admin@123
echo.
echo =============================================================================
pause
