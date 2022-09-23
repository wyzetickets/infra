resource "aws_iam_role" "iam-external-dns" {
  name = "iam-external-dns"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_policy" "external-dns-policy" {
  name        = "external-dns-policy"
  description = "Policy for external DNS."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "route53:ChangeResourceRecordSets",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external-dns-attach" {
  role       = aws_iam_role.iam-external-dns.name
  policy_arn = aws_iam_policy.external-dns-policy.arn
}

resource "aws_iam_policy" "eks-cluster-autoscaler-policy" {
  name        = "eks-cluster-autoscaler-policy"
  description = "Policy for cluster autoscaling."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}