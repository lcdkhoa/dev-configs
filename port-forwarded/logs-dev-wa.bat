@echo on
kubectl logs deployment/wl-wa --namespace=foresightpro-backend-dev --container=wl-wa -f --timestamps=true --since=0
pause