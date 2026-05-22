1. Create terraform code for VPC that is needed for EKS cluster.
2. Need to do VPC peering for default VPC. You can fetch details of that VPC. I have one instance in default VPC, want to use that as bastion and EKS k8s client where I run kubectl and this terraform code as well.
3. Consider the terraform structure here - https://github.com/raghudevopsb88/wmp-terraform-encrypt-n-network-v9 , make in same format. Also in EKS make sure we add all the necessary helm charts which I have done here. 
4. Cluster should be production ready with all the standards.
5. I am going to run this project inside EKS. https://github.com/raghudevopsb88/roboshop-microservices-documentation. 
6. So I want the DB components to be created as services in AWS. Get the services created and ready. 
7. For Apps prepare helm charts that can be deployed. Use image name as dummy, later we will change it.


