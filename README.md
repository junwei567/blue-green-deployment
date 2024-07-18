# Simple Blue Green Deployment Showcase

ArgoCD is a GitOps agent that pulls updated code from Git repositories and deploys it directly to our OpenShift resources. 
It manages both infrastructure configuration and application updates in one system.

## Prerequisites
- This example assumes you have cluster-wide admin permissions.
- Have ArgoCD installed from the Red Hat OpenShift GitOps operator in your OpenShift cluster.
- If you run into the issue where you cannot sync applications in OpenShift GitOps, try running the following command for your ArgoCD namespace such as `openshift-gitops`.
``` 
oc adm policy add-role-to-user admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller -n <namespace_name> 
```

## Instructions
Run the command to create the application.
``` 
oc apply -f https://raw.githubusercontent.com/junwei567/blue-green-deployment/main/bgd-app.yaml
```

Verify your deployment is working with the following command.
``` 
oc get pods -n bgd
```
You should see 4 pods running, verify the routing for your deployments.
``` 
oc describe service blue-service
```
More specifically, ensure that the endpoints are different for your blue and green services.
``` 
$ oc describe service blue-service | grep Endpoints
Endpoints:    10.130.0.13:8080,10.131.0.12:8080
$ oc describe service green-service | grep Endpoints
Endpoints:    10.129.0.13:8080,10.130.0.18:8080
```

To switch your traffic from blue to the green deployment, change these values below in blue-service.yaml.
What we are doing is changing the label so that the service will target the Green deployment pods.

``` 
apiVersion: v1
kind: Service
metadata:
  name: blue-service
  namespace: bgd
spec:
  selector:
    app: bgd-v2
    env: green
  ports:
  - protocol: TCP
    port: 8005
    targetPort: 8080
```

Refresh and sync your application from ArgoCD.
Verify the routing for your deployments again to see that the endpoints for blue service have been change to the endpoints for green service. 
``` 
$ oc describe service blue-service | grep Endpoints
Endpoints:    10.129.0.13:8080,10.130.0.18:8080
$ oc describe service green-service | grep Endpoints
Endpoints:    10.129.0.13:8080,10.130.0.18:8080
```
