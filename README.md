# 🚀 Enterprise-Grade Status Page: Cloud Infrastructure & GitOps

Welcome to the infrastructure repository for the Status Page project. This repository contains the complete Infrastructure as Code (IaC) and GitOps deployment configurations for a highly available, scalable, and secure web application deployed on AWS.

> **Note on Application Code:** For instructions on how to run, test, and build the application code locally, please refer to the [Application README](./app/README.md).

---

## 🏗️ Architecture Overview

The system is designed with a modern cloud-native architecture, utilizing AWS managed services and Kubernetes for resilient container orchestration.

### Core Technologies (Tech Stack)

- **Cloud Provider:** AWS (EKS, EC2, Route 53, ACM, ALB, IAM, S3)  
- **Infrastructure as Code (IaC):** Terraform  
- **Container Orchestration:** Kubernetes (EKS - `t3.large` nodes for high availability)  
- **Continuous Deployment (GitOps):** Argo CD  
- **Continuous Integration:** GitHub Actions  
- **Ingress & Routing:** AWS Load Balancer Controller  
- **Secrets Management:** External Secrets Operator (fetching from AWS Secrets Manager)  
- **Observability:** Kube-Prometheus-Stack (Prometheus, Grafana, Alertmanager) & Loki  

---

## ✨ Key Infrastructure Highlights

### 1. 🔄 GitOps with Argo CD

The entire Kubernetes state is managed declaratively via Argo CD. Any changes pushed to the `main` branch of this repository are automatically synchronized and applied to the EKS cluster, ensuring a single source of truth and eliminating configuration drift.

---

### 2. 📈 Auto-Scaling (HPA & Cluster Autoscaler)

The application handles traffic spikes automatically:

- **Horizontal Pod Autoscaler (HPA):**  
  Scales the application pods based on CPU and memory utilization metrics.

- **Cluster Autoscaler (IRSA enabled):**  
  Communicates directly with AWS Auto Scaling Groups to dynamically add or remove `t3.large` EC2 instances (`min_size: 2` for HA) when pods are pending or resources are underutilized.

---

### 3. 🔒 Secure Secrets Management

Zero secrets are stored in plain text or Git. The **External Secrets Operator** securely fetches database credentials (RDS/Redis) from AWS Secrets Manager and injects them directly into the Kubernetes pods at runtime.

---

### 4. 🌐 Networking, DNS & SSL

- **Route 53 & ACM:** Automated DNS delegation and free SSL certificate generation.  
- **AWS ALB Controller:** Automatically provisions an Application Load Balancer, routing HTTPS traffic (port 443) from `oag-status-page-devops.site` directly to the cluster services, including automatic HTTP-to-HTTPS redirection.

---

### 5. 📊 Observability & Monitoring

A robust monitoring stack is deployed alongside the application:

- **Prometheus & Grafana:** Collecting and visualizing real-time cluster metrics and application health.  
- **Loki & Promtail:** Centralized log aggregation.  
- **Alertmanager:** Configured to notify the team on critical alerts (e.g., node resource exhaustion or pod crash loops).

---

## 📂 Repository Structure

```
├── terraform/                # Terraform modules (EKS, IAM, Route53, ACM)
├── k8s/
│   ├── status-page/          # Helm chart / Kubernetes manifests for the app
│   │   ├── values.yaml       # Dynamic configurations (Ingress host, auto-scaling thresholds)
│   │   ├── deployment.yaml   # App deployments
│   │   ├── hpa.yaml          # Horizontal Pod Autoscaler config
│   │   ├── ingress.yaml      # ALB Ingress configuration with SSL
│   │   └── secret-store.yaml # External Secrets configuration
│   └── argocd/               # Argo CD application definitions
└── app/                      # Application source code and local README
```

