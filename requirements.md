1. Create terraform code for VPC that is needed for EKS cluster.
2. Need to do VPC peering for default VPC. You can fetch details of that VPC. I have one instance in default VPC, want to use that as bastion and EKS k8s client where I run kubectl and this terraform code as well.
3. Consider the terraform structure here - https://github.com/raghudevopsb88/wmp-terraform-encrypt-n-network-v9 , make in same format. Also in EKS make sure we add all the necessary helm charts which I have done here. 
4. Cluster should be production ready with all the standards.
5. I am going to run this project inside EKS. https://github.com/raghudevopsb88/roboshop-microservices-documentation. 
6. So I want the DB components to be created as EC2 only in AWS. For this DB you can still use the code in https://github.com/raghudevopsb88/roboshop-v1.git. Later I will move them to services.
7. For Apps prepare helm charts that can be deployed. Use image name as dummy, later we will change it. Prepare the code to deploy them.
8. Hoping finally three modules will come. vpc, ec2, eks.
9. EKS should compirise of all the standards of secruity. Additionally add addon like eks-pod-identity-agent. Also helm charts like cluster-autoscaler, trafik, argocd, prometheus-stack, external-dns. These helm charts are already there inside https://github.com/raghudevopsb88/wmp-terraform-encrypt-n-network-v9 as reference.


