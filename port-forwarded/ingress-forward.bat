@echo on

echo "Port forwarding for Automated Testing"
kubectl config set-context --current --namespace=ingress-nginx

set RETRY_COUNT=0
set MAX_RETRY=3

:start_port_forward
echo.
echo Starting port-forward...
kubectl port-forward deployments/nginx-ingress-ingress-nginx-controller 80:80 443:443 8443:8443 -n ingress-nginx

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo Connection lost! Port-forward terminated.
    echo ========================================
    echo.
    
    if %RETRY_COUNT% LSS %MAX_RETRY% (
        set /p RETRY="Do you want to reconnect? (Y/N): "
        if /i "%RETRY%"=="Y" (
            set /a RETRY_COUNT+=1
            echo.
            echo Retrying connection... (Attempt %RETRY_COUNT%/%MAX_RETRY%)
            timeout /t 2 /nobreak >nul
            goto start_port_forward
        ) else (
            echo.
            echo Connection cancelled by user.
            pause
            exit /b
        )
    ) else (
        echo.
        echo Maximum retry attempts (%MAX_RETRY%) reached.
        echo Please check your connection and try again later.
        pause
        exit /b
    )
) else (
    echo.
    echo Port-forward completed successfully.
    pause
    exit /b
)