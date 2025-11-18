# Cloud Engineer Portfolio Project

This project demonstrates the creation and deployment of a cloud-native application on AWS, showcasing skills relevant for a cloud engineering role.

## Project Summary

The goal is to build a serverless web application with a CI/CD pipeline for automated deployments.

### Key Accomplishments:

*   **Python Runtime Upgrade:** Updated the AWS Lambda function from Python 3.9 to 3.14.
*   **Infrastructure as Code (IaC):**
    *   Created a `terraform/main.tf` file to manage the AWS Lambda function and its corresponding IAM role.
    *   This ensures the infrastructure is version-controlled and can be deployed consistently.
*   **CI/CD Pipeline:**
    *   Implemented a GitHub Actions workflow (`.github/workflows/deploy.yml`).
    *   The workflow automatically triggers on a `git push` to the `main` branch.
    *   It initializes, validates, and applies the Terraform configuration to deploy changes to AWS.
*   **Git Repository:**
    *   Initialized a local Git repository.
    *   Connected the local repository to the remote GitHub repository: `https://github.com/element665/Cloud_Project.git`.

### Next Steps:

*   Complete the initial `git push` to trigger the CI/CD pipeline for the first time.
*   Enhance the frontend to interact with the backend API.
*   Add automated testing to the CI/CD workflow.
