# EKS High-Availability Demo

## Demo Scope

- DevOps

  This is a demo using Infrastucture as Code (IaC) to create CodePipeline & CodeBuild (in devops folder) and to create EKS cluster (in infrastructure folder). I use terraform framework as terraform provides comprehensive ecosystem support, additional to aws provider, including helm provider, kubernetes probvider, null provider and more.

- Deployment Resources

  The code demonstrates how replica, HPA/VPA and node autoscaler work in AWS EKS.

- Load Test

  The demo uses busybox as load generator, which makes CPU pressure on existing resources.

## Repository Structure

- `/devops` contains the terraform code to generate CodePipeline and CodeBuild for the demo.
- `/infrastructure` contains the terraform to generate cloud resources (e.g. VPC, EKS cluster, IAM resources) and kubernetes baseline (e.g. helm chart for AWS Karpenter node autoscaler)
- `devops-buildspec.yml` can be consumede by a manual created CodeBuild project and it is not included in my automation scripts
- `cloud-resource-buildspec.yml` will be executed everytime push code to main branch in the manually created CodeCommit project
- `/k8s-yaml` this directory holds the demo kuberntes resources.



## Concepts in the Demo

### 1. Infrastructure as Code (terraform)

### 2. GitOps (CodeCommit with CodePipeline and Code Build)

### 3. Software Dependencies Management in Kubernetes (Helmchart)



## How to Run the Demo

### 1. Prerequisites

- You have a test environment ready. 

  Usually it is required for the interested parties to run through the demo in an AWS cloud account. It can also be achieved by using an AWS lab environment if one has.

- You have created a IAM user/role with proper privileges configured.

  Typically, for the user/role that is used only for resource deployment, it would be better to assign an administrator role without console login possibility. On the contrary, when you allocate an user/role/group to a dedicated person or group, the minimum privilege rule should be applied to avoid unexpected actions.

- You have a console login user/role with at least CodeCommit, CodeBuild and CodePipeline privileges.

  This user/role is a typical operation administrator role in the development team and he/she is responsible for setting up  development repositories and coordinating with development experts to establish CI/CD process. 

- [Local Setup - Optional] If you plan to run demo code locally

  To verify the demo locally, the local setup should be prepared. You should install the aws cli, terraform cli, helm cli, kubectl locally.

### 2. Preparation

- [Manually] As a baseline/foundation of the demo, you should prepare a CodeCommit / Github repository to hold the code, and you should have configured a login that can push changes (commits) to the repository. In this demo, I would highly recommend you to work with CodeCommit as I created the trigger in terraform code using CodeCommit.
- [Manually] In the CodeBuild, I used system manager parameter store to keep Access Key and Access Secret. If you plan to do the same, store them with proper key names (starts with `/CodeBuild/`).
- [Optional] Create a CodeBuild to run terraform code under `devops`. The build specification should be pointed to file `devops-buildspec.yml`

### 3. Places that You Should Update

- If you have configured the environment variables under different names or places, please update them in the `*-buildspec.yml` `env` sections

- If you plan to run the terraform code locally, please make sure the terraform cli versions are aligned between your local machine and the build server. The version that will be installed in the build server can be found in `*-buildspec.yml` under `phases -> install -> commands` section. Otherwise, you cannot run the code from both local machine and build server.

- Provider verions

  ```HCL
      aws = {
        source  = "hashicorp/aws"
        version = "~> 4.19.0" -> replace with {your-prefered-version}
      }
  ```

- Backend storage S3 bucket name and path in each terraform projects

  ```HCL
    backend "s3" {
      bucket = "yagr-tf-state-log" -> replace with {your-bucket-name}
      key    = "event/20220714-hangzhou/devops" -> replace with {your-bucket-path}
      region = "us-east-1" -> replace with {your-prefered-region}
    }
  ```

- Source Block in `main.tf` under `/devops`

  ```
    stage {
      name = "Source"
  
      action {
        name             = "Source"
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeCommit" -> if you prefer another git repo other than CodeCommit
        version          = "1"
        output_artifacts = ["source_output"]
  
        configuration = {
          RepositoryName          = "0714-eks" -> replace with {your-repo-name}
          BranchName              = "main" -> replace with {your-repo-branch}, could be any existing branch
          PollForSourceChanges    = "false"
        }
      }
    }
  ```

- Role Names and Resource Names

- Terraform lock

  You can optionally add lock in dynamoDB for running into conflicts. This can be found in terraform offical documents

### 4. Demo One by One

#### Step1: Run the terraform code under `devops`

```shell
# If you prefer to run it locally, not from manually created CodeBuild which we mentioned in the Preparation section with [Optional]
terraform init
terraform plan
terraform apply --auto-approve
```

#### Step 2: Commit code and see if the data pipeline generated in Step 1 is triggered.

If it works fine, you should see the following commands are triggered in the build server.

```shell
terraform init
terraform plan
terraform apply --auto-approve
```

And VPC/EKS resources are created in your account

#### Step 3: Verify the EKS cluster 

```shell
# aws eks update-kubeconfig --name event_0714 --kubeconfig ~/.kube/config-event-0714 --region ap-southeast-1 --alias config-event-0714
# export KUBE_CONFIG_PATH=~/.kube/config-event-0714
# kubectl cluster-info

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

aws eks update-kubeconfig --name {cluster-name} --kubeconfig ~/.kube/{kubeconfig-filename} --region {cluster-region} --alias {alias-as-kubeconfig-context}
export KUBE_CONFIG_PATH=~/.kube/{kubeconfig-filename}
kubectl cluster-info
```

### 5. Clean Up

Run the below command under `/devops` and `/infrastructure` respectively

```shell
# Run the below command under devops and infrastructure respectively
terraform init
terraform destroy --auto-approve
```



## What Next?

### 1. Try out Different Infrastructure as Code Technics

- [AWS CDK](https://aws.amazon.com/cdk/) (it generates AWS cloudformation templates/stacks)
- [Pulumi (vs Terraform)](https://www.pulumi.com/docs/intro/vs/terraform/)
- [Terragrunt](https://terragrunt.gruntwork.io/) a powerful wrapper for Terraform

### 2. Pickup You Own Git Repo and CI/CD Tools 

- Github/Gitlab/Gitee/Gerrit...
- Jenkins/Github Actions/Gitlab Runner/Travis CI...

### 3. Involve Other Resources

- Additionally to VPC/EKS. there are more other resources that can be integrated. Just do it.

### 4. Integrate with Microservices Concepts

- Understand service domain and work with domain api gateways
- Setup Observability - tracing, logging, monitoring
  - Prometheus
  - Cloud Monitors
  - Opensearch
- Collect valid KPI for your services and keep improving it

### 