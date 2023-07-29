@echo on

echo "Port fowarding for qe-nextgen-client"
kubectl config set-context --current --namespace=qe-nextgen-client
kubectl port-forward deployments/qe-nextgen-client 5000:5000 -n qe-nextgen-client
pause