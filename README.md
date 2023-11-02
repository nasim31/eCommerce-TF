# eCommerce-TF
IaC repo for AWS infrastructure

# Terraform Project
 
This project uses Terraform for infrastructure provisioning. Follow the steps below to initialize, validate, plan, apply, and destroy the infrastructure.
 
## Prerequisites
 
Make sure you have [Terraform](https://www.terraform.io/downloads.html) installed on your machine.
 
## Usage
 
1. **Initialize Terraform:**
   ```bash
   terraform init
   ```
 
   This command initializes your working directory, downloading the required providers and modules.
 
2. **Validate Terraform configuration:**
   ```bash
   terraform validate
   ```
 
   Ensure that your Terraform configurations are syntactically correct and internally consistent.
 
3. **Plan infrastructure changes:**
   ```bash
   terraform plan -out=tfplan
   ```
 
   Generate an execution plan to preview changes before applying them.
 
4. **Apply changes:**
   ```bash
   terraform apply tfplan
   ```
 
   Apply the changes described in the execution plan. Confirm by typing `yes` when prompted.
 
5. **Destroy infrastructure:**
   ```bash
   terraform destroy
   ```
 
   Destroy the created infrastructure. Confirm by typing `yes` when prompted.
