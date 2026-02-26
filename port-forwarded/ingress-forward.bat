@echo off
setlocal enabledelayedexpansion

echo "Port forwarding for Automated Testing"
kubectl config use-context dev-fpro-aks
kubectl config set-context --current --namespace=ingress-nginx
if errorlevel 1 (
    echo.
    echo ERROR: Failed to set kubectl context!
    pause
    exit /b 1
)

set RETRY_COUNT=0
set MAX_RETRY=3

:start_port_forward
echo.
echo Starting port-forward...
kubectl port-forward deployments/nginx-ingress-ingress-nginx-controller 80:80 443:443 8443:8443 -n ingress-nginx
set EXIT_CODE=!ERRORLEVEL!

REM Force output flush and small delay
echo.
timeout /t 2 /nobreak >nul 2>&1
echo Connection status check... Exit code: !EXIT_CODE!
echo.

if !EXIT_CODE! NEQ 0 (
    echo.
    echo ========================================
    echo ERROR: Connection failed or lost!
    echo Port-forward terminated with exit code: !EXIT_CODE!
    echo ========================================
    echo.
    
    REM Check if we can still retry
    REM Calculate remaining retries: MAX_RETRY - RETRY_COUNT
    REM If remaining > 0, we can retry
    set /a REMAINING_RETRIES=%MAX_RETRY%-!RETRY_COUNT!
    if !REMAINING_RETRIES! GTR 0 (
        set /a NEXT_ATTEMPT=!RETRY_COUNT!+1
        echo Do you want to reconnect? (Attempt !NEXT_ATTEMPT!/%MAX_RETRY%)
        set "RETRY="
        set /p "RETRY=Enter Y to retry, N to exit: "
        REM Remove all spaces and convert to uppercase
        set "RETRY=!RETRY: =!"
        REM Check if user wants to retry - only Y will retry, everything else exits
        if /i "!RETRY!"=="Y" (
            set /a RETRY_COUNT=!RETRY_COUNT!+1
            echo.
            echo Retrying connection... (Attempt !RETRY_COUNT!/%MAX_RETRY%)
            timeout /t 2 /nobreak >nul
            goto start_port_forward
        ) else (
            REM User entered N, empty, or anything else - exit immediately
            echo.
            echo Connection cancelled by user.
            pause
            exit /b !EXIT_CODE!
        )
    ) else (
        echo.
        echo ========================================
        echo Maximum retry attempts (%MAX_RETRY%) reached.
        echo Please check your connection and try again later.
        echo ========================================
        pause
        exit /b 1
    )
) else (
    echo.
    echo ========================================
    echo Port-forward completed successfully.
    echo ========================================
    pause
    exit /b 0
)