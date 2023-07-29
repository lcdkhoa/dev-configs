@echo on

echo "Port fowarding for qe-transformer-client"
kubectl port-forward deployments/qe-transformer-client 8080:8080 -n qe-transformer-client
pause