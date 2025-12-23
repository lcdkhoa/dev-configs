@echo on

echo "Port fowarding for qe-transformer"
kubectl port-forward deployments/wl-transformer 8080:8080 -n 360f-core
pause