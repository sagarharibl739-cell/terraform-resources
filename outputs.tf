output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "nlb_dns_name" {
  description = "Public DNS name of the Network Load Balancer."
  value       = aws_lb.nlb.dns_name
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
}

output "ec2_instance_id" {
  description = "EC2 web instance ID."
  value       = aws_instance.web.id
}
