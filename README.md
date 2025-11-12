# 🛍️ Multi-Cloud E-commerce Platform (AWS)  
**A scalable, secure e-commerce app built with Terraform, Kubernetes, and DevOps automation.**

---

## 🧭 Project Overview  
This project aims to build a **multi-cloud e-commerce platform** that demonstrates:  
- Cloud infrastructure design with Terraform.  
- Containerized microservices using Docker and Kubernetes (EKS).  
- CI/CD pipelines with GitHub Actions.  
- Security, monitoring, and cost optimization best practices.

The goal is to replicate real-world cloud architecture challenges while showcasing problem-solving skills and technical depth.

---

## 🛠️ Tech Stack  
| Component          | Tools/Technologies Used                             |
|-------------------|-----------------------------------------------------|
| **Cloud Provider**   | AWS (EC2, RDS, S3, VPC, EKS)                        |
| **IaC**            | Terraform                                           |
| **Containerization** | Docker, Kubernetes (EKS)                           |
| **CI/CD**          | GitHub Actions                                      |
| **Frontend**       | React (optional)                                    |
| **Backend**        | Node.js/Python (Microservices)                     |
| **Database**       | RDS (PostgreSQL)                                    |
| **Monitoring**     | AWS CloudWatch, Prometheus + Grafana (optional)   |

---

## 🗺️ Roadmap  
This project is in progress. Here's what’s been completed and planned:

### ✅ Completed So Far  
- [x] Set up AWS Free Tier account and configured CLI.  
- [x] Created basic Terraform script for VPC and subnet.  
- [x] Structured GitHub repository with directories for IaC, app code, and documentation.

### 🚀 Next Steps  
1. **Phase 1: Infrastructure as Code (Terraform)**  
   - Create RDS instance with backups.  
   - Add S3 bucket for static assets (e.g., product images).  

2. **Phase 2: Application Development**  
   - Build React frontend with product catalog and checkout flow.  
   - Implement Node.js microservices for order processing and cart management.  

3. **Phase 3: Containerization & Orchestration**  
   - Dockerize app and deploy to EKS cluster.  

4. **Phase 4: DevOps Automation**  
   - Set up GitHub Actions for CI/CD pipeline.  

5. **Phase 5: Monitoring & Security**  
   - Enable AWS CloudWatch for logs and metrics.  
   - Implement IAM roles, encryption, and WAF rules.

---

## 🛠️ How to Use This Repo  
> ⚠️ **Important**: This project is a personal learning initiative. For testing, ensure you’re using AWS Free Tier (or Azure/GCP if preferred) to avoid costs.

### 📦 Prerequisites  
- [AWS CLI](https://aws.amazon.com/cli/) configured with your account.  
- [Terraform](https://learn.hashicorp.com/terraform/install/apt) installed.  
- [Docker](https://www.docker.com/) and `kubectl` for Kubernetes.  
- A GitHub account (for CI/CD).

### 🧪 Local Development (Optional)  
1. Clone the repo:  
   ```bash
   git clone https://github.com/element665/Cloud_Project.git
   cd multi-cloud-ecommerce-platform
   ```
2. Run Terraform to create infrastructure (see `/terraform/README.md` for steps).  
3. Use Docker to test app components locally (requires `docker-compose.yml`).  

---

## 📁 Key Components  
- **`/terraform`** – Infrastructure as code (VPC, RDS, S3).  
- **`/app/frontend`** – React-based product catalog (WIP).  
- **`/app/backend`** – Node.js microservices for order/cart logic (WIP).  
- **`/k8s`** – Kubernetes manifests for deploying to EKS (WIP).  
- **`/ci-cd`** – GitHub Actions workflows for CI/CD (WIP).  
- **`/docs`** – Architecture diagrams and technical documentation.

---

## 🚧 Challenges Faced  
- **Terraform State Management**: Learned how to handle state files and avoid conflicts.  
- **Kubernetes Networking**: Debugging issues with service discovery in EKS (still a work in progress).  
- **Cost Optimization**: Exploring spot instances and auto-scaling to reduce AWS bill.

---

## 📌 Contributing  
This project is a personal initiative, but contributions are welcome!  
- Fork the repo and submit PRs for bug fixes or feature additions.  
- Add your thoughts to `/docs/notes.md` if you’re working on the project.

---

## 📜 License  
This project is open-source and released under the **MIT License**. See `LICENSE` file for details.

---

## 📩 Contact  
For questions, feedback, or collaboration:  
- Email: element665@gmail.com  
- Portfolio: peterimkus.com  
- LinkedIn: https://www.linkedin.com/in/peterrimkus/

---

### 🔗 Useful Links  
- [AWS Free Tier](https://aws.amazon.com/free/)  
- [Terraform Docs](https://developer.hashicorp.com/terraform)  
- [EKS Getting Started Guide](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)  
- [GitHub Actions Docs](https://docs.github.com/en/actions)

---
