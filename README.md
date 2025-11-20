# Cloud Resume Challenge: A Serverless Web Application

![CI/CD Pipeline Status](https://github.com/element665/Cloud_Project/actions/workflows/deploy.yml/badge.svg)

This project is a comprehensive, cloud-native resume website built on Amazon Web Services (AWS). It goes beyond a simple static site by incorporating a serverless backend, Infrastructure as Code (IaC), and a fully automated CI/CD pipeline. The goal is to demonstrate practical, hands-on expertise in modern cloud engineering and DevOps principles.

**Live Demo:** [**www.element665.site**](https://www.element665.site)

---

## Architectural Diagram

The entire infrastructure is provisioned and managed by Terraform. The application follows a serverless, event-driven architecture designed for high availability, scalability, and cost-efficiency.

```
                               +-----------------+
                               |      User       |
                               +-----------------+
                                       |
                                       | HTTPS (element665.site)
                                       v
+-------------------------------------------------------------------------+
|                                   AWS Cloud                             |
|                                                                         |
|  +------------------+      +------------------+      +---------------+  |
|  |    Route 53      |----->|   CloudFront     |----->|  S3 Bucket    |  |
|  | (DNS Management) |      | (CDN for speed   |      | (Static HTML, |  |
|  +------------------+      |  and security)   |      |  CSS, JS)     |  |
|                            +------------------+      +---------------+  |
|                                       |                                 |
|                                       | API Call (/api/visit)           |
|                                       v                                 |
|                               +--------------------+                    |
|                               |  API Gateway       |                    |
|                               | (REST API Endpoint)|                    |
|                               +--------------------+                    |
|                                       |                                 |
|                                       v                                 |
|                               +------------------+                      |
|                               |  Lambda Function |                      |
|                               | (Python/Node.js) |                      |
|                               +------------------+                      |
|                                       |                                 |
|                                       | Read/Write                      |
|                                       v                                 |
|                               +------------------+                      |
|                               |  DynamoDB Table  |                      |
|                               | (Visitor Count)  |                      |
|                               +------------------+                      |
|                                                                         |
+-------------------------------------------------------------------------+
```

---

## Key Features & Skills Demonstrated

This project showcases proficiency across several core competencies required for a Cloud Engineer role:

*   **Serverless Computing:** The backend logic for the visitor counter is handled by an **AWS Lambda** function, eliminating the need for server management and enabling pay-per-use execution.
*   **Infrastructure as Code (IaC):** The entire cloud infrastructure is defined and managed using **Terraform**. This ensures the environment is repeatable, version-controlled, and can be deployed or destroyed with a single command.
*   **CI/CD Automation:** A complete CI/CD pipeline is built with **GitHub Actions**. Every `git push` to the `main` branch automatically triggers a workflow that:
    1.  Sets up the environment and authenticates with AWS.
    2.  Validates and applies the Terraform infrastructure changes.
    3.  Builds and packages the backend Lambda function.
    4.  Deploys the frontend assets to the S3 bucket.
    5.  Invalidates the CloudFront cache to ensure users see the latest version.
*   **Cloud Storage & Content Delivery:** The static website (HTML, CSS, JS) is hosted in an **AWS S3** bucket. An **AWS CloudFront** distribution sits in front of the S3 bucket to provide low-latency content delivery to users globally via its edge network.
*   **API Development & Management:** An **API Gateway** provides a stable, secure RESTful endpoint for the frontend to communicate with the Lambda function.
*   **Database Management:** A **DynamoDB** NoSQL database is used to store and retrieve the visitor count, demonstrating experience with serverless databases.
*   **Networking & DNS:** **Amazon Route 53** is used to manage the custom domain, routing traffic to the CloudFront distribution.
*   **Security Best Practices:**
    *   **IAM Roles & Policies:** The Principle of Least Privilege is applied. The Lambda function has a specific IAM role with fine-grained permissions to only access the DynamoDB table it needs.
    *   **HTTPS:** An SSL/TLS certificate is provisioned via **AWS Certificate Manager (ACM)** and enforced by the CloudFront distribution, ensuring all traffic is encrypted.
    *   **Secure Credential Management:** AWS credentials are not hard-coded but are stored securely as GitHub Secrets and accessed via OIDC.

---

## Technology Stack

*   **Cloud Provider:** AWS
*   **IaC:** Terraform
*   **CI/CD:** GitHub Actions
*   **Frontend:** HTML, CSS, JavaScript
*   **Backend:** Python (with Boto3)
*   **Services:**
    *   Amazon S3
    *   Amazon CloudFront
    *   Amazon Lambda
    *   Amazon API Gateway
    *   Amazon DynamoDB
    *   Amazon Route 53
    *   AWS Certificate Manager (ACM)
    *   AWS IAM

---

## Getting Started

### Prerequisites

*   An AWS Account
*   A registered domain name
*   Terraform installed
*   GitHub Account

### Deployment Steps

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
    cd YOUR_REPO
    ```
2.  **Configure GitHub Secrets:**
    *   Set up OIDC between your GitHub repository and your AWS account.
    *   Add your AWS Role ARN as a secret named `AWS_ROLE_ARN`.
3.  **Configure Terraform Variables:**
    *   In the `terraform/` directory, create a `terraform.tfvars` file.
    *   Add your domain name: `domain_name = "your-domain.com"`
4.  **Push to `main`:**
    *   Commit and push your changes to the `main` branch. The GitHub Actions workflow will automatically provision the infrastructure and deploy the application.

---

## Future Improvements

This project provides a solid foundation. Potential future enhancements include:

*   **Add Unit & Integration Tests:** Implement Pytest for the Lambda function and integrate it into the CI/CD pipeline to run on every commit.
*   **Implement Observability:** Add structured logging to the Lambda function and create a CloudWatch Dashboard to monitor API requests, errors, and function performance.
*   **Enhance Security:** Implement a Web Application Firewall (WAF) on the CloudFront distribution to protect against common web exploits.
*   **Cost Monitoring:** Set up AWS Budgets and billing alarms to monitor and control costs.
