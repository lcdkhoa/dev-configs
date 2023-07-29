@echo on

echo "Port fowarding for Automated Testing"
kubectl config set-context --current --namespace=ingress-nginx
kubectl port-forward deployments/nginx-ingress-ingress-nginx-controller 80:80 443:443 8443:8443 -n ingress-nginx
pause