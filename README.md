# Simple Blue Green Deployment Showcase
## Prerequisites
- This example makes use of OpenShift cluster with ArgoCD installed from the Red Hat OpenShift GitOps operator.
- This example assumes you have cluster wide permissions
- If you run into the issue where you cannot sync applications in OpenShift GitOps, try running the following command for your ArgoCD namespace such as `openshift-gitops`
``` 
oc adm policy add-role-to-user admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller -n <namespace_name> 
```

## Instructions
Run the command to create the application
``` 
oc apply -f https://raw.githubusercontent.com/junwei567/blue-green-deployment/main/bgd-app.yaml
```

Verify your deployment is working with the following command
``` 
oc get pods -n bgd
```
You should see 4 pods running

Verify the routing for your deployments
``` 
oc describe service blue-service
```
More specifically, ensure that the endpoints are different for your blue and green services.
``` 
oc describe service blue-service | grep Endpoints
oc describe service green-service | grep Endpoints
```

To switch your traffic with blue to the green deployment, change these values in green-service.yaml
``` 
apiVersion: v1
kind: Service
metadata:
  name: green-service
  namespace: bgd
spec:
  selector:
    app: bgd-v2
    env: green
  ports:
  - protocol: TCP
    port: 8006
    targetPort: 8080
```

Refresh and sync your application from ArgoCD.
Verify the routing for your deployments again to see that the endpoints for blue service have been change to the endpoints for green service. 
``` 
oc describe service blue-service | grep Endpoints
oc describe service green-service | grep Endpoints
```
