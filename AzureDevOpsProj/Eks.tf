resource "aws_eks_cluster" "EKs_Cluster" {
  name = "EKS_Cluster"
## Acess Config For the Way of Auth Config Map mean the Kubectl to create Resource you need To get Config Map
## There are other way by Using API Use External Way as IAM for example 
access_config {
    authentication_mode = "CONFIG_MAP"
}

role_arn = aws_iam_role.eks_cluster.arn      ## Attech IAM Role to The Kubernates 
version  = "1.31"


## For AZ for normal you need at least two AZ and for High Avaliability you need 3 AZ 
vpc_config {
    subnet_ids = [
      aws_subnet.Zone1.id,
      aws_subnet.Zone2.id,
      aws_subnet.Zone3.id,
    ]
## To ensure that the cluster is base on it 
depends_on = [
    aws_iam_role_policy_attachment.Test_EKS,
]
}
}

resource "aws_eks_node_group" "EKS_NodeGroup" {
  cluster_name    = aws_eks_cluster.EKs_Cluster.name
  node_group_name = "EKS_Feedback"
  node_role_arn   = aws_iam_role.EKS_Role.arn
  subnet_ids      = aws_subnet.example[*].id

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
    aws_iam_role_policy_attachment.eks_worker_node_policy_attachment,
    aws_iam_role_policy_attachment.eks_cni_policy_attachment,
  ]

  