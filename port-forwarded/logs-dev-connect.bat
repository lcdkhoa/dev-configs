@echo on
kubectl logs deployment/foresightpro-microservice-nodejs-connect --namespace=foresightpro-backend-dev --container=foresightpro-microservice-nodejs-connect -f --timestamps=true --since=0