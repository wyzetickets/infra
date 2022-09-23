data "aws_eks_cluster" "cluster" {
  name = module.local-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.local-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  #load_config_file       = false
}

module "local-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = module.vpc.name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  worker_groups = [
    {
      instance_type = "c5a.large"
      asg_min_size  = 1
      asg_max_size  = 5
    }
  ]
}

data "aws_region" "current" {}

output "delete" {
  value = "eksctl delete iamserviceaccount external-dns --cluster ${module.vpc.name}"
}

output "associate" {
  value = "eksctl utils associate-iam-oidc-provider --region=${data.aws_region.current.name} --cluster=${module.vpc.name} --approve"
}

output "create" {
  value = "eksctl create iamserviceaccount --name external-dns --namespace default --cluster ${module.vpc.name} --attach-policy-arn ${aws_iam_policy.external-dns-policy.arn} --approve --override-existing-serviceaccounts"
}

output "cluster-autoscaler" {
  value = "eksctl create iamserviceaccount --name cluster-autoscaler --namespace kube-system --cluster ${module.vpc.name} --attach-policy-arn ${aws_iam_policy.eks-cluster-autoscaler-policy.arn} --approve --override-existing-serviceaccounts"
}

output "cluster-autoscaler-attach-policy" {
  value = "kubectl annotate serviceaccount cluster-autoscaler -n kube-system eks.amazonaws.com/role-arn=${aws_iam_policy.eks-cluster-autoscaler-policy.arn}"
}

# eksctl create iamserviceaccount \
#   --cluster=<my-cluster> \
#   --namespace=kube-system \
#   --name=cluster-autoscaler \
#   --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/<AmazonEKSClusterAutoscalerPolicy> \
#   --override-existing-serviceaccounts \
#   --approve