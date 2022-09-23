# wyze-migrate

# Core Infrastructure

Based on [Anthony Simon's one man architecture](https://anthonynsimon.com/blog/one-man-saas-architecture/)

# Resource Overview

1. VPC with a public and private subnet in each of three availability zones (us-east-2a, us-east-2b and us-east-2c)
1. NAT gateways for each of the private subnets
1. EKS cluster located within the private subnets
1. Roles to allow the EKS worker nodes to modify DNS records (for Route53)
1. A network load balances (this resource is provisioned by the NGINX ingress controller, not terraform)
1. An elastic container registry to pull docker images from

# Spinning Up The Infrastructure

The entire infrastructure can be spun up as follows:

1. Install kubectl, eksctl, terraform, kubeseal and the aws cli
1. In the .aws folder of your home directory (~ or $HOME), replace the aws_access_key_id and aws_secret_access_key with the creds I sent in Discord
1. From within the terraform directory, run `teraform apply` and, barring errors, type `yes`
1. A successful apply will produce a kubeconfig_loomis file. Copy the contents of this file into the config file in your $HOME/.kube directory.
1. In the manifests directoy, run `kubectl apply -f . --recursive`
1. Finally, from the terraform directory run and execute the resultant commands:
   - `terraform output -raw delete`
   - `terraform output -raw associate`
   - `terraform output -raw create`
   - The previous commands set up an OIDC provider. This lets AWS authenticate worker nodes and gives them access to modify DNS records, which is used to dynamically set routes to the load balancer. In other words, setting a K8s ingress to from www.loomistechnologies.com to api.loomistechnologies.com will automatically configure the DNS records and reissue a TLS cert.

# Creating a New Project

Every project (website, poster, etc.) will have its own K8s namespace and (if exposed to the internet) ingress YAML. Both of these will be declared within the app folder in an ingress.yaml file. The K8s namespace allows for isolated internal routing (poster applications can use bolt://neo4j.poster.svc.cluster:7687, for example) and the ingress connects our primary web-facing services to the outside world.

# Setting Secrets

Secrets are encrypted by kubeseal. Create a raw secret file, then use `kubeseal <namespace.raw.secrets -o yaml > namespace.sealed.secrets.yaml`. The resulting namespace.sealed.secrets.yaml can be used in the desired project and committed to github safely.

Raw secret template (MAKE SURE TO SAVE AS <project>.secrets.raw):

```
apiVersion: v1
kind: Secret
metadata:
  name: <name>
  namespace: <namespace>
type: kubernetes.io/basic-auth
stringData:
  username: admin
  password: t0p-Secret
```

# Helpful K8s Commands

Get service accounts for external-dns: `kubectl get sa external-dns -o yaml`

Reconcile flux with kustomization: `flux reconcile kustomization --with-source <source>`
