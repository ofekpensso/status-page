# 🚀 Enterprise Cloud-Native Status Page

A complete, production-ready DevOps pipeline and cloud infrastructure for a highly available Status Page application. This project demonstrates modern cloud-native practices, including Infrastructure as Code (IaC), GitOps, Shift-Left Security, and comprehensive CI/CD automation.

---

<p align="center">
  <img src="https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white" />
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" />
  
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" />
  <img src="https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white" />
  
  <img src="https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white" />
  <img src="https://img.shields.io/badge/Argo_CD-FF7F00?style=for-the-badge&logo=argo&logoColor=white" />
  
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" />
  <img src="https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white" />

  <img src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white" />
  <img src="https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white" />
  <img src="https://img.shields.io/badge/Loki-F46800?style=for-the-badge&logo=grafana&logoColor=white" />
</p>

## 🏗️ Architecture Overview

Our environment is built on AWS and Kubernetes, ensuring high availability, security, and scalability.

**AWS VPC Infrastructure:**
![AWS VPC Infrastructure](./screenshot/vpc-project.jpg)

**Kubernetes Application Architecture:**
![Status Page Architecture](./screenshot/status-page-architecture.jpg)

**User Traffic Flow (Cache Hit/Miss Logic):**
![Traffic Flowchart](./screenshot/traffic-flowchart.png)

### 🛠️ Tech Stack & Tools

**Cloud & Infrastructure:**
* **AWS:** EKS (Kubernetes), ECR (Container Registry), RDS (PostgreSQL), ElastiCache (Redis), ALB, Route 53.
* **IaC:** Terraform (Provisioning the entire AWS infrastructure).

**Containerization & Orchestration:**
* **Docker & Buildx:** Multi-stage, cached container builds.
* **Kubernetes (K8s):** Deployments, Services, Ingress, HPA (Horizontal Pod Autoscaler).
* **Helm:** Package manager for K8s manifests and templating.

**CI/CD & GitOps:**
* **GitHub Actions:** Continuous Integration, testing, and building.
* **Argo CD:** Continuous Deployment actively syncing cluster state with Git.

**Security & Observability:**
* **Trivy:** Container vulnerability scanning.
* **AWS OIDC:** Secretless authentication between GitHub and AWS.
* **Prometheus & Grafana:** Cluster monitoring and resource metrics.

---

## 🔄 CI/CD Pipeline (The GitOps Way)

Our deployment pipeline is fully automated, enforcing code quality and security before any code reaches the production cluster.

**The Complete CI/CD Flow:**
![CI/CD Pipeline](./screenshot/cicd-pipeline.png)

### 1. Continuous Integration (GitHub Actions)
1. **Shift-Left Testing:** Runs `helm lint` to validate infrastructure YAML and executes Django unit tests within ephemeral PostgreSQL/Redis service containers.
2. **Secretless Auth:** Uses AWS OIDC to authenticate securely.
3. **Optimized Build:** Utilizes Docker Buildx with GitHub caching to reduce build times by up to 80%.
4. **DevSecOps:** Scans the built image with **Trivy** for Critical/High CVEs.
5. **Publish & Update:** Pushes the secure image to Amazon ECR and uses `yq` to safely update the `image.tag` in the Helm `values.yaml` file, committing the new state back to Git.

### 2. Continuous Deployment (Argo CD)
* **Drift Detection:** Argo CD detects the new commit in the repository.
* **Automated Sync:** Pulls the new state and instructs the EKS cluster to pull the new image from ECR.
* **Rolling Update:** Kubernetes performs a zero-downtime deployment, utilizing Readiness and Liveness probes to ensure application health before routing traffic.

**Argo CD Live Sync Status:**

---

## 🛡️ Security & Best Practices Implemented

* **Least Privilege:** Kubernetes pods are configured with a strict `securityContext` (`runAsNonRoot: true`, dropping all capabilities).
* **High Availability:** Pod Anti-Affinity rules ensure application replicas are spread across different physical EC2 nodes.
* **Resource Management:** Strict CPU and Memory `requests` and `limits` are defined to prevent node starvation and enable the HPA.
* **State Isolation:** Application configuration is completely separated from the image.

---

## 📊 Monitoring & Observability

To ensure infrastructure stability and optimize resource allocation, the cluster is monitored using the Prometheus stack.

**Infrastructure Health (Node Exporter):**
![Node Exporter Dashboard](./screenshot/node-exporter.jpg)

**Application Pod Metrics (Compute Resources):**
![Compute Resources Dashboard](./screenshot/compute-resources.jpg)

---
*Developed as a comprehensive showcase of modern DevOps engineering practices.*
