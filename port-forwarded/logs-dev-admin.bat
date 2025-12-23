@echo on
kubectl logs deployment/wl-admin-backend-pkg --namespace=foresightpro-backend-dev --container=wl-admin-backend-pkg -f --timestamps=true --since=0