# Deployment Documentation

## Prerequisites

Before proceeding with the deployment, ensure the following prerequisites are met:

*   **AWS Account & CLI:** You must have an active AWS account and the AWS Command Line Interface (CLI) configured with appropriate credentials and permissions to interact with your AWS resources.
*   **Terraform Installed:** Ensure that Terraform is installed on your local machine. The version should be compatible with the configurations provided. You can download and install Terraform from the [official Terraform website](https://www.terraform.io/downloads).
*   **Domain Registrar Access:** Access to the management interface of your domain registrar (e.g., Namecheap, GoDaddy) is necessary to update Name Server (NS) records for your domains.
*   **Parent Domain in Route 53:** For environments other than `prod` (e.g., `integration`, `staging`), your base domain (e.g., `yuriypikh.site`) must have its hosted zone managed by AWS Route 53. This is crucial for delegating subdomains.

## Important Notes

*   **Route 53 Hosted Zone Creation & Delegation:**
    *   The `route53_cert` module, when deployed for each environment (`integration`, `staging`, `prod`), creates **two separate Route 53 hosted zones**: one for your application's domain (e.g., `app.integration.yuriypikh.site`) and one for your API's domain (e.g., `api.integration.yuriypikh.site`).
    *   After Terraform successfully creates these hosted zones, AWS will provide a unique set of Name Servers (NS) for each zone.
    *   It is **crucial** to update the NS records in your parent domain's DNS management (either at your domain registrar or within your `yuriypikh.site` Route 53 hosted zone) to point to these AWS-provided NS records. This delegation is essential for ACM certificate validation and correct DNS resolution.

## Deployment Steps

Let's use the `integration` environment as an example. Remember to replace `integration` with `staging` or `prod` when deploying to other environments.

1.  **Navigate to the Environment Directory:**

    ```bash
    cd environments/integration # Or environments/staging or environments/prod
    ```

2.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

3.  **Apply the Configuration:**

    ```bash
    terraform apply -auto-approve
    ```

4.  **Obtain Name Server (NS) Records:**

    Once `terraform apply` completes successfully, obtain the Name Servers for both your API and application domains from the outputs of the `route53_cert` configuration for the current environment. You can run:

    ```bash
    terraform output zone_name_servers # For API domain
    terraform output zone_name_servers_route53_cert_app # For Application domain
    ```

    The output will look similar to this (example for integration):

    ```text
    zone_name_servers = [
      "ns-XXX.awsdns-XX.org",
      "ns-YYY.awsdns-YY.net",
      "ns-ZZZ.awsdns-ZZ.co.uk",
      "ns-AAA.awsdns-AA.com",
    ]

    zone_name_servers_route53_cert_app = [
      "ns-BBB.awsdns-BB.org",
      "ns-CCC.awsdns-CC.net",
      "ns-DDD.awsdns-DD.co.uk",
      "ns-EEE.awsdns-EE.com",
    ]
    ```

5.  **Delegate DNS - CRITICAL STEP:**

    *   **For `integration` and `staging` environments (subdomains):**
        *   Assuming your `yuriypikh.site` domain's hosted zone is already in AWS Route 53.
        *   Go to the `yuriypikh.site` hosted zone in the AWS Route 53 console.
        *   **For the API domain (e.g., `api.integration.yuriypikh.site`):** Create a new `NS` record set.
            *   **Name:** `api.integration` (or `api.staging` for staging)
            *   **Type:** `NS - Name server`
            *   **Value:** Paste the NS records obtained from `terraform output zone_name_servers`.
        *   **For the Application domain (e.g., `app.integration.yuriypikh.site`):** Create a new `NS` record set.
            *   **Name:** `app.integration` (or `app.staging` for staging)
            *   **Type:** `NS - Name server`
            *   **Value:** Paste the NS records obtained from `terraform output zone_name_servers_route53_cert_app`.

    *   **Special Case for `prod` environment:**
        *   **For the Application domain (`yuriypikh.site`):**
            *   Go to your **domain registrar** where `yuriypikh.site` is registered.
            *   Change the existing Name Server records for `yuriypikh.site` to use the NS records obtained from `terraform output zone_name_servers_route53_cert_app`.
        *   **For the API domain (`api.yuriypikh.site`):**
            *   After the `yuriypikh.site` hosted zone is managed by Route 53 (via the step above), navigate to the `yuriypikh.site` hosted zone in the AWS Route 53 console.
            *   Create a new `NS` record set.
                *   **Name:** `api`
                *   **Type:** `NS - Name server`
                *   **Value:** Paste the NS records obtained from `terraform output zone_name_servers`.

    *   **DNS Propagation:** DNS changes can take time to propagate (a few minutes to 48 hours).

6.  **Wait for ACM Certificate Validation:**

    AWS ACM will automatically attempt to validate the SSL/TLS certificates using the DNS records. This can take several minutes. Monitor the status in the AWS Certificate Manager console.

7.  **Test Your Endpoints:**

    *   **Frontend:** `https://<your_application_domain>` (e.g., `https://app.integration.yuriypikh.site` or `https://yuriypikh.site`)
    *   **Backend:** `https://<your_api_domain>` (e.g., `https://api.integration.yuriypikh.site` or `https://api.yuriypikh.site`)

8.  **To Destroy the Infrastructure (for an environment):**

    ```bash
    cd environments/integration # Or staging/prod
    terraform destroy -auto-approve
    ```

    Remember to remove/revert the NS record changes at your domain registrar/Route 53 if you destroy the infrastructure and no longer want AWS to manage DNS for those domains.