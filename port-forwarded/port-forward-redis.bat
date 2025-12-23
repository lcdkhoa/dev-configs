@echo on

echo "Port fowarding for redis"
kubectl config set-context --current --namespace=foresightpro-backend-dev
kubectl port-forward deployments/foresightpro-redis-server-side 6379:6380 -n foresightpro-backend-dev --address 127.0.0.1
pause