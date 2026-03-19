##Step-1: Create Ec2 instance with instance type t3.small and storage 20 gb

## Prerequisites

Before setting up the EKS cluster, install the following tools:

### 1. Install kubectl
kubectl is a command-line tool used to manage Kubernetes clusters.

Installation guide:
https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html

### 2. Install eksctl
eksctl is a CLI tool used to create and manage EKS clusters.

Installation guide:
https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html

### 3. Configure AWS Credentials
Before using eksctl, configure AWS CLI with your security credentials.

Run the following command:

aws configure

Provide the following details:
- AWS Access Key
- AWS Secret Access Key
- Default Region (example: us-east-1)
- Output format (json)

###Step-2: Create Cluster 

eksctl create cluster   --name robotshop-cluster   --region us-east-1   --nodegroup-name robotshop-nodegroup   --node-type t3.small   --nodes 2   --nodes-min 1   --nodes-max 3

###Step-3: Configure IAM OIDC provider
-->Why We Configure IAM OIDC(OpenID Connect) Provider

By default, pods running inside Kubernetes cannot call AWS APIs.
For example, a pod cannot directly:
Create an Application Load Balancer
Access S3 buckets
Update Route53 records
Write logs to CloudWatch
To allow this securely, AWS provides IRSA (IAM Roles for Service Accounts).
OIDC enables this mechanism.

##1.Export Cluster Name and assign oidc_id
export cluster_name=robotshop-cluster
oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

##2.Check if there is an IAM OIDC provider configured already
aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4

##3. If not, run the below command.
export AWS_DEFAULT_REGION=us-east-1
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve

###Step-4: Setup ALB Add-On

##1.Download IAM policy.
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json

##2. Create IAM Policy
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

##3. Create IAM Role
eksctl create iamserviceaccount   --cluster robotshop-cluster   --namespace kube-system   --name aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole   --attach-policy-arn arn:aws:iam::016817716696:policy/AWSLoadBalancerControllerIAMPolicy   --approve

###Step-5:Deploy ALB controller

##1.Install the helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

##2.Add helm repo
helm repo add eks https://aws.github.io/eks-charts

##3.Update the repo.
helm repo update eks
--you should see like
 Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "eks" chart repository
Update Complete. ⎈Happy Helming!⎈


##4.Install the chart
 helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=robotshop-cluster \--set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=us-east-1 --set vpcId=<your-vpc-id>^C

##5.Verify that the deployments are running.

kubectl get deployment -n kube-system aws-load-balancer-controller

###Step-6:  EBS CSI Plugin configuration (The Amazon EBS CSI Driver is used in Kubernetes/EKS to dynamically provision and manage Amazon EBS volumes as persistent storage for pods)

##1.The Amazon EBS CSI plugin requires IAM permissions to make calls to AWS APIs on your behalf.

##2.Create an IAM role and attach a policy. AWS maintains an AWS managed policy or you can create your own custom policy. You can create an IAM role and attach the AWS managed policy with the following command. Replace my-cluster with the name of your cluster. The command deploys an AWS CloudFormation stack that creates an IAM role and attaches the IAM policy to it.

eksctl create iamserviceaccount \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster <YOUR-CLUSTER-NAME> \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --role-only \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --approve

##3.Run the following command. Replace with the name of your cluster, with your account ID.

eksctl create addon --name aws-ebs-csi-driver --cluster <YOUR-CLUSTER-NAME> --service-account-role-arn arn:aws:iam::<AWS-ACCOUNT-ID>:role/AmazonEKS_EBS_CSI_DriverRole --force

###Step-7: Install the Helm Chart

##1.Initially Clone the GitHub Repo:
GitHub URL : RobotShop-Project
git clone https://github.com/uniquesreedhar/RobotShop-Project.git

##2.Then Navigate to the path where chart.yaml exists

cd RobotShop-Project/EKS/helm

##3. Create a namespace and then install the helm chart.

kubectl create ns robot-shop
helm install robot-shop --namespace robot-shop .

##4. Ensure all the pods are running if not troubleshoot the issues

kubectl get pods -n robot-shop

###Step 7: Create Ingress

cd /RobotShop-Project/EKS/helm
 kubectl apply -f ingress.yaml
 
This will create a Load Balancer on the AWS console.

Paste the DNS-name on your favourite browser and access the application





