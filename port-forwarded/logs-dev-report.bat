@echo on
kubectl logs deployment/wl-qe-report-engine --namespace=360f-core --container=wl-qe-report-engine -f --timestamps=true --since=0