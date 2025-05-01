resource "aws_eks_cluster" "EKs_Cluster" {
  name = "EKS_Cluster"
## Acess Config For the Way of Auth Config Map mean the Kubectl to create Resource you need To get Config Map
## There are other way by Using API Use External Way as IAM for example 
access_config {
    authentication_mode = "CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
}

role_arn = aws_iam_role.eks_cluster_role.arn     ## Attech IAM Role to The Kubernates 
version  = "1.29"


## For AZ for normal you need at least two AZ and for High Avaliability you need 3 AZ 
vpc_config {
    subnet_ids = [
      aws_subnet.Zone1.id,
      aws_subnet.Zone2.id,
      aws_subnet.Zone3.id,
    ]
}
## To ensure that the cluster is base on it 
depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

}

resource "aws_eks_node_group" "EKS_NodeGroup" {
  cluster_name    = aws_eks_cluster.EKs_Cluster.name
  node_group_name = "EKS_Feedback"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids = [
      aws_subnet.Zone1.id,
      aws_subnet.Zone2.id,
      aws_subnet.Zone3.id,
    ]

  instance_types= ["t2.micro"]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

    depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_policy,
  ]
tags = {
  Name = "EKS_Feedback_Nodes"
}
}