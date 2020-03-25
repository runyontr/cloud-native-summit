# Demo


## EKS Terraform Hooked to KUDO

```bash
export AWS_PROFILE=decops tf apply
```

zk count = 3
prefix = SOMETHING


Rollout the apply

## KUDO

KUDO Overview


Exploration of Service

Describe Blue/Green and Canary updated
Each Parameter can have a different rollout


### App

AWS EKS cluster

Zookeeper Instance

App provides 2 part message:
1) String prefix
   BLUE/GREEN
2) zookeeper connection string
   CANARY


Watcher pod for logging results



### Scale Zookeeper

Two screens, one 

```bash
kubectl logs -f watcher
```

```bash
watch kubectl get pods,instances
```