@echo on

echo "Port fowarding for redis"
kubectl port-forward pod/rabbitmq-6bb878f4bb-5prl4 15672:15672 -n=rabbitmq
pause