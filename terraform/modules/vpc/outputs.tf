output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "secondary_vpc_cidr" {
  value = var.secondary_vpc_cidr
}

output "all_vpc_cidr_blocks" {
  value = compact([aws_vpc.main.cidr_block, var.secondary_vpc_cidr])
}

output "eks_subnet_ids" {
  value = length(aws_subnet.eks) > 0 ? aws_subnet.eks[*].id : aws_subnet.app[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  value = aws_subnet.app[*].id
}

output "db_subnet_ids" {
  value = aws_subnet.db[*].id
}

output "subnet_ids" {
  value = {
    public = aws_subnet.public[*].id
    app    = aws_subnet.app[*].id
    db     = aws_subnet.db[*].id
    eks    = length(aws_subnet.eks) > 0 ? aws_subnet.eks[*].id : aws_subnet.app[*].id
  }
}
