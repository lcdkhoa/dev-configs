@echo on

echo "Port fowarding for Auth service"
kubectl port-forward deployments/wl-auth 3020:3020 -n foresightpro-backend-dev
pause