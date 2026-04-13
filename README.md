# Full-Stack News Application

A modern, full-stack News application utilizing React.js, Node.js (Express), and NewsAPI. The project leverages an ultra-secure Distroless containerized architecture using Docker, Nginx reverse proxies, and Infrastructure-as-Code deployments to AWS via Terraform.

---

## 🏗️ Architecture Overview

Our structure guarantees a minimal footprint and zero-CVE environment utilizing a highly secure multi-stage deployment model.

- **Frontend (`newsapps/`)**: 
  - A React.js Single Page Application.
  - Builds into a highly secure, Distroless **Chainguard Nginx** proxy container.
  - Internally proxy-routes all backend traffic hitting `/api/*` downwards to the backend container to bypass CORS restrictions completely.
- **Backend (`backend/`)**:
  - A Node.js Express server acting as a secure intermediary layer, safely keeping the NewsAPI tokens away from the frontend client.
  - Deploys using Google's completely stripped-down `gcr.io/distroless/nodejs20` environment.
- **Infrastructure (`infra/`)**:
  - Contains `.tf` files defining a complete High-Availability (HA) cloud architecture. It automatically provisions a Custom VPC, an Application Load Balancer, and an Auto Scaling Group of EC2 instances that autonomously install and run the Docker containers.

### 🛡️ The Nginx Reverse Proxy (Overcoming CORS & Hardcoded URLs)

One of the most persistent challenges when transitioning a frontend out of local development and into global container deployment revolves around **Cross-Origin Resource Sharing (CORS)** and **hardcoded `localhost` routing chains**. 

If a deployed React payload attempts to run a `fetch("http://localhost:5000/...")` command, the user's web browser will incorrectly attempt to search for the API on *their own personal computer's* port 5000—not your backend container! Conversely, if you hardcoded the exact AWS Production IP, web browsers would aggressively block the outbound request via CORS policies.

**The Unified Proxy Solution:**
To intelligently bypass this bottleneck, our frontend logic completely sidesteps explicit URLs. All frontend data fetches are converted to environment-agnostic **relative requests** (e.g., `/api/news...`). 

Because our deployed React application code is hosted on an embedded **Chainguard Nginx Reverse Proxy**, Nginx intercepts any outbound request that possesses an `/api/*` signature. It seamlessly "proxy passes" that request completely out-of-band directly over your private Docker bridged network to the Node.js Express server. 

The user's browser is tricked into believing the frontend React URL and the backend Database API belong to the exact same origin, which fully eliminates CORS errors and deeply secures your backend container from the public internet!

---

## 💻 Local Development Setup

If you want to run this cluster locally on your machine for testing, we use Docker Compose to coordinate the internal network.

### 1. Prerequisites
- [Docker Desktop](https://www.docker.com/) installed on your machine.

### 2. Running Locally
Navigate to the root directory where the `docker-compose.yml` resides.

```bash
# Build the Distroless Images and start them in the background
docker compose up --build -d
```
The localized network will bridge both containers together and host the graphical interface safely at `http://localhost:8080`.

---

## 🚀 AWS Cloud Deployment (Terraform)

Deploying to production is seamless and highly automated. Instead of manually SSHing into servers, manually installing, and configuring instances side-by-side, we use HashiCorp Terraform to provision a high-availability infrastructure. This includes an Auto Scaling Group behind an Application Load Balancer in a Custom VPC, where each node *installs its own dependencies and pulls your remote images completely autonomously*. 

### Step 1: Push Images to Docker Hub
Because our external AWS EC2 instance will boot up and pull images completely independently, you must first publish your code structures into a repository (Docker Hub) where the server can reach it from the perimeter network.

Ensure your `docker-compose.yml` image names reflect your Docker Hub username.

```bash
# Compile and package your source code locally
docker compose build

# Authenticate your terminal
docker login

# Upload the images to Docker Hub
docker compose push
```

### Step 2: Initialize Infrastructure as Code
Navigate into the `infra/` folder. This is where our architectural definition (`main.tf`) lives. 

```bash
cd infra

# Initialize Terraform (downloads the AWS provider plugins)
terraform init
```

### Step 3: Provision the Cloud Infrastructure
Run the overarching apply command. Terraform will present an execution plan showing precisely what resources it intends to create on your underlying AWS account.

```bash
# Review and execute server creation
terraform apply
```
*(Make sure your machine has AWS permissions initialized either via `aws configure` or explicit environment variables).*

### What exactly happens in the background during launch?
When you approve the Terraform blueprint, it will:
1. Establish a **Custom VPC** with dedicated subnets spread across multiple Availability Zones, ensuring high availability.
2. Generate Security Groups allowing web traffic via an **Application Load Balancer** and restricting direct container access.
3. Deploy an **Auto Scaling Group (ASG)** designed to dynamically scale from 1 to 3 instances, ensuring zero downtime and fault tolerance.
4. Securely inject a `user_data` startup script via a Launch Template. As each underlying EC2 instance comes online, it executes the bootstrap sequence:
    - Autonomously installs the Docker daemon.
    - Constructs the internal `newsapp-network` tunnel.
    - Accesses Docker Hub to pull and run the backend (`newsapp-backend`) and frontend (`newsapp-frontend`) containers natively using the specified configurations.
    - The system actively monitors node health using the Load Balancer and replaces unhealthy instances automatically.

### Step 4: Access your Live App!
Upon successful execution, Terraform will hand over an `Outputs` block dynamically extracted from the AWS API containing the exact `application_url` pointing to your Load Balancer's DNS name. It will generally print to the console mapping like this:

```bash
Outputs:

application_url = "newsapp-load-balancer-xxxxxxxxxx.eu-north-1.elb.amazonaws.com"
```
Navigate to the URL and your News app is successfully live, load-balanced, and operating securely across multiple availability zones!

### Managing Lifecycle
If you ever want to completely tear down the architecture, unbind the IP addresses, and successfully stop getting billed, use the clean destroy hook:

```bash
terraform destroy
```
