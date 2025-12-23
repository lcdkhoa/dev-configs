@echo on

echo "Port fowarding for Automated Testing"
kubectl config set-context --current --namespace=360f-core
kubectl port-forward deployments/wl-360-test-automation-service 5000:5000 -n 360f-core
pause