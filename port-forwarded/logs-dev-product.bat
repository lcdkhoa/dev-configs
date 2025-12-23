@echo on
kubectl logs deployment/foresightpro-microservice.nodejs.products --namespace=foresightpro-backend-dev --container=wl-product-backend-pkg -f --timestamps=true --since=0