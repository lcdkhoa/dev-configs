@echo on
kubectl logs deployment/wl-portcontrol --namespace=foresightpro-backend-dev --container=wl-portcontrol -f --timestamps=true --since=0
pause