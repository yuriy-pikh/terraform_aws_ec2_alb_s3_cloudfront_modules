# Deployment Documentation

This document outlines the prerequisites and steps required to deploy the infrastructure using Terraform.

## Prerequisites

Before proceeding with the deployment, ensure the following prerequisites are met:

* **AWS Account & CLI:** You must have an active AWS account and the AWS Command Line Interface (CLI) configured with appropriate credentials and permissions to interact with your AWS resources.
* **Terraform Installed:** Ensure that Terraform is installed on your local machine. The version should be compatible with the configurations provided. You can download and install Terraform from the [official Terraform website](https://www.terraform.io/downloads).
* **Domain Registrar Access:** Access to the management interface of your domain registrar (e.g., Namecheap, GoDaddy) is necessary to update Name Server (NS) records for your domains.
* **Parent Domain (Optional but Recommended):** It is recommended to have a Route 53 hosted zone for the parent domain. While the current setup creates separate hosted zones for subdomains or the main domain directly, managing a parent zone simplifies DNS delegation.

## Important Notes

* **Region for ACM Certificates (Frontend):** ACM (AWS Certificate Manager) certificates intended for use with CloudFront must be created in the `us-east-1` region. The current configuration defaults all environments to `us-east-1`, ensuring compatibility. If you intend to deploy an environment to a different AWS region, you will need to configure the `aws_frontend` module to use a provider alias specifically for the `us-east-1` region when creating the ACM certificate resource.
* **S3 Bucket Names:** Amazon S3 bucket names must be globally unique across all AWS accounts. The bucket names derived from your domain names should generally satisfy this requirement.
* **Terraform State:** The current configuration does not define a remote backend (such as an S3 bucket with DynamoDB locking) for storing Terraform state. Consequently, the state will be stored locally in the `terraform.tfstate` file within each environment directory. For team collaboration or production deployments, it is highly recommended to configure a remote backend to ensure state consistency and prevent data loss.
* **Route 53 Zone Creation & Delegation:**
    * Each Terraform module (`aws_backend`, `aws_frontend`) is configured to create its own Route 53 hosted zone based on the `domain_name_api` and `domain_name_app` variables, respectively.
    * After Terraform successfully creates these hosted zones, AWS will provide a unique set of Name Servers (NS) for each zone.
    * It is **crucial** to update the NS records at your domain registrar (or within the DNS management interface of your parent domain's hosted zone) to point to these AWS-provided NS records. This delegation is essential for ACM certificate validation and for ensuring that DNS queries for your domains are correctly resolved to your AWS resources.

## Deployment Steps

The following steps outline the deployment process for each environment (integration, staging, production). You will need to repeat these steps for each environment you wish to deploy.

Let's use the `integration` environment as an example. Remember to replace `integration` with `staging` or `prod` when deploying to other environments.

1.  **Navigate to the Environment Directory:**

    ```bash
    cd environments/integration
    ```

2.  **Initialize Terraform:**

    This command initializes the Terraform working directory by downloading the necessary provider plugins (in this case, the AWS provider).

    ```bash
    terraform init
    ```

3.  **Review the Plan:**

    This command generates an execution plan, showing you the resources that Terraform will create, modify, or destroy in your AWS environment. It's crucial to review this plan carefully before applying it to understand the changes that will be made.

    ```bash
    terraform plan -var-file="terraform.tfvars"
    # Or simply `terraform plan` if `terraform.tfvars` is the only .tfvars file
    # or if you are relying on default variable values.
    ```

4.  **Apply the Configuration:**

    This command applies the changes described in the execution plan, effectively building the infrastructure in your AWS account. You will be prompted to confirm the action before Terraform proceeds.

    ```bash
    terraform apply -var-file="terraform.tfvars"
    # Or simply `terraform apply`
    ```

    Type `yes` when prompted to confirm the deployment.

5.  **Obtain Name Server (NS) Records:**

    Once the `terraform apply` command completes successfully, it will output important information, including the Name Servers for the Route 53 hosted zones that have been created. You will typically see outputs similar to the following:

    ```text
    Outputs:

    aws_backend.route53_name_servers_info = <<EOT
    Copy the following name servers to your domain registrar (e.g. Namecheap) to delegate DNS to AWS Route 53.
    After this, ACM validation and routing through your ALB will work.

    Name servers:
    ns-XXX.awsdns-XX.org.
    ns-YYY.awsdns-YY.net.
    ns-ZZZ.awsdns-ZZ.co.uk.
    ns-AAA.awsdns-AA.com.
    EOT

    aws_frontend.route53_name_servers_info = <<EOT
    Copy the following name servers to your domain registrar (e.g. Namecheap) to delegate DNS to AWS Route 53.
    After this, ACM validation and routing through your ALB will work.

    Name servers:
    ns-BBB.awsdns-BB.org.
    ns-CCC.awsdns-CC.net.
    ns-DDD.awsdns-DD.co.uk.
    ns-EEE.awsdns-EE.com.
    EOT
    ```

6.  **Delegate DNS - CRITICAL STEP:**

    This step is essential for your domains to resolve correctly to your AWS infrastructure and for ACM certificate validation to succeed.

    * **For `domain_name_app` (e.g., `app.integration.yuriypikh.site`):**
        * Go to your domain registrar where `app.integration.yuriypikh.site` (or its parent zone if you are managing subdomains) is registered.
        * Update or create NS (Name Server) records for `app.integration.yuriypikh.site` to point to the Name Servers provided in the `aws_frontend.route53_name_servers_info` output for the current environment.

    * **For `domain_name_api` (e.g., `api.integration.yuriypikh.site`):**
        * Similarly, go to your domain registrar (or the DNS management interface of the relevant zone).
        * Update or create NS records for `api.integration.yuriypikh.site` to point to the Name Servers provided in the `aws_backend.route53_name_servers_info` output for the current environment.

    * **Special Case for `prod` environment (or if `domain_name_app` is a root domain like `yuriypikh.site`):**
        * **Frontend (`domain_name_app = "yuriypikh.site"`):**
            * Go to your domain registrar where `yuriypikh.site` is registered.
            * Change the existing Name Server records for `yuriypikh.site` to use the NS records output by `aws_frontend.route53_name_servers_info` for the `prod` environment.
        * **Backend (`domain_name_api = "api.yuriypikh.site"`):**
            * The `aws_backend` module has created a separate hosted zone specifically for `api.yuriypikh.site`.
            * You need to delegate the `api` subdomain from the `yuriypikh.site` zone, which is now managed by Route 53 due to the `aws_frontend` module's deployment in the `prod` environment.
            * In the AWS Route 53 console, find the hosted zone for `yuriypikh.site`.
            * Create a new record set with the following details:
                * **Name:** `api`
                * **Type:** `NS - Name server`
                * **Value:** The list of 4 Name Servers provided by `aws_backend.route53_name_servers_info` for the `prod` environment.
                * **TTL:** Use a reasonable Time-To-Live value (e.g., `172800` seconds / 2 days, or `3600` seconds / 1 hour).

    * **DNS Propagation:** Keep in mind that DNS changes can take some time to propagate across the internet. This process can range from a few minutes to up to 48 hours, although it is often much faster.

7.  **Wait for ACM Certificate Validation:**

    Once the DNS delegation is correctly configured, AWS ACM will automatically attempt to validate the SSL/TLS certificates for your domains using the DNS records created by Terraform. This validation process can take anywhere from a few minutes to an hour. You can monitor the status of your certificates in the AWS Certificate Manager console. The deployment of your CloudFront distribution (for the frontend) will typically wait for this certificate validation to complete.

8.  **Upload Website Content:**

    To upload your website content (e.g., `index.html`) to the S3 bucket created for this environment, use the following command:

    ```bash
    aws s3 cp index.html s3://<your_frontend_bucket_name>/index.html
    ```

    Replace `<your_frontend_bucket_name>` with the actual name of the S3 bucket created by the `aws_frontend` module for this **specific environment** (e.g., `app.integration.yuriypikh.site-web`). You can find the bucket name in the Terraform state file or in the AWS S3 console after the deployment is complete.


9.  **Test Your Endpoints:**

    After the ACM certificates have been validated and the CloudFront distribution (if applicable) has been deployed, you should be able to access your applications via the following endpoints:

    * **Frontend:** `https://<your_domain_name_app>` (e.g., `https://app.integration.yuriypikh.site`)
    * **Backend:** `https://<your_domain_name_api>` (e.g., `https://api.integration.yuriypikh.site`). Note that this endpoint, based on the description, will likely only display a default "Hello World" message from the EC2 instances behind the Application Load Balancer (ALB) as no specific application logic has been defined in this configuration.

10.  **To Destroy the Infrastructure (for an environment):**

    **Warning:** This action will permanently delete all AWS resources managed by Terraform within the specified environment. Exercise extreme caution when running this command.

    ```bash
    cd environments/integration # Or staging/prod
    terraform destroy -var-file="terraform.tfvars"
    # Or simply `terraform destroy`
    ```

    Type `yes` when prompted to confirm the destruction of the infrastructure.

    Remember to manually remove or revert the NS record changes you made at your domain registrar if you destroy the infrastructure and no longer want AWS to manage DNS for those domains.