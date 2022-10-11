# general-controller-poc
A poc with decoupled "Cluster Select" funtion from nephio-controller-poc

## Build
```
export CGO_ENABLED=0
make docker-build
```
## Push image
```
make docker-push
```

## Apply CRDs and Deploy controller
> NOTE: Make sure your kubectl cmd is executable  
> and target k8s cluster CRED is in ~/.kube/config
```
make deploy
```
