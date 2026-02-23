complete end-to-end DevOps project design using GitHub Actions + Kubernetes + Helm + Trivy + Prometheus.

🚀 Final Architecture (GitHub Actions Version)
Developer Push → GitHub
        ↓
GitHub Actions Pipeline
        ↓
Build Docker Image (multi-stage, non-root)
        ↓
Trivy Security Scan
        ↓
Push to Docker Hub / GHCR
        ↓
Deploy via Helm to Kubernetes (Minikube / EKS)
        ↓
Prometheus monitors app
        ↓
Grafana dashboards

🧱 1️⃣ Project Structure
devops-project/
│
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── helm/
│   └── flask-app/
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml
│
└── README.md

🐳 2️⃣ Secure Dockerfile (Multi-Stage + Non-Root)
# -------- Stage 1: Build --------
FROM python:3.11-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# -------- Stage 2: Runtime --------
FROM python:3.11-slim

RUN useradd -m appuser

WORKDIR /app

COPY --from=builder /root/.local /home/appuser/.local
ENV PATH=/home/appuser/.local/bin:$PATH

COPY app.py .

USER appuser

EXPOSE 5000
CMD ["python", "app.py"]


✅ Multi-stage
✅ Non-root
✅ Slim base image
✅ No hardcoded secrets

⚙️ 3️⃣ GitHub Actions Pipeline

Create:

.github/workflows/ci-cd.yml

🔥 Full CI/CD Workflow
name: CI-CD Pipeline

on:
  push:
    branches:
      - main

env:
  IMAGE_NAME: flask-devops-app

jobs:
  build-scan-push-deploy:
    runs-on: ubuntu-latest

    steps:

    - name: Checkout Code
      uses: actions/checkout@v4

    # 🔐 Login to DockerHub
    - name: Docker Login
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    # 🐳 Build Docker Image
    - name: Build Docker Image
      run: |
        docker build -t ${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:${{ github.run_number }} ./app

    # 🔎 Trivy Scan
    - name: Run Trivy Vulnerability Scan
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:${{ github.run_number }}
        severity: HIGH,CRITICAL
        exit-code: 1

    # 🚀 Push Image
    - name: Push Docker Image
      run: |
        docker push ${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:${{ github.run_number }}

    # ☸ Deploy to Kubernetes
    - name: Setup Kubectl
      uses: azure/setup-kubectl@v4

    - name: Deploy using Helm
      run: |
        helm upgrade --install flask-app ./helm/flask-app \
        --set image.repository=${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }} \
        --set image.tag=${{ github.run_number }}

🔐 Required GitHub Secrets

Go to:

Repo → Settings → Secrets → Actions


Add:

DOCKER_USERNAME

DOCKER_PASSWORD

KUBECONFIG (base64 encoded if remote cluster)

☸ 4️⃣ Kubernetes Using Helm

Create Helm chart:

helm create flask-app

values.yaml
replicaCount: 2

image:
  repository: yourdockerhub/flask-devops-app
  tag: latest

resources:
  limits:
    cpu: "500m"
    memory: "512Mi"
  requests:
    cpu: "200m"
    memory: "256Mi"

Add Probes (deployment.yaml)
livenessProbe:
  httpGet:
    path: /health
    port: 5000
  initialDelaySeconds: 10
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /health
    port: 5000
  initialDelaySeconds: 5
  periodSeconds: 5

🔐 5️⃣ Secrets Management

Create Kubernetes Secret:

kubectl create secret generic app-secret \
  --from-literal=DB_PASSWORD=mysecret


Deployment.yaml:

env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: app-secret
        key: DB_PASSWORD

📊 6️⃣ Observability (Monitoring)

Install:

Prometheus

Grafana

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack


You’ll get:

Pod CPU/Memory

App metrics

Health dashboards

🎁 Bonus Options
☁️ If Using AWS

Deploy to EKS

Use Amazon CloudWatch

Store images in ECR

🔄 GitOps Upgrade (Very Impressive)

Use:

Argo CD

Flow:

Push to GitHub
↓
ArgoCD auto-syncs cluster
↓
Production deployment

📄 README.md Must Include
Architecture

Explain:

Why GitHub Actions (cloud-native CI)

Why Helm

Why Trivy

Why Prometheus

How to Run
1. Start Minikube
2. Install Helm
3. Push to main branch
4. Pipeline runs automatically
5. Access via NodePort

Security Decisions

Non-root container

Vulnerability scanning

Secrets in K8s

Resource limits

Limitations

No autoscaling

No TLS

Local cluster

🏆 This Project Shows Interviewers:

✅ CI/CD knowledge
✅ Docker security
✅ Kubernetes production best practices
✅ Observability
✅ DevSecOps (Trivy scan)
✅ GitOps readiness

🔥 Next Question For You

Are you deploying this:

1️⃣ On Minikube (local)
2️⃣ On KinD
3️⃣ On AWS EKS

Tell me your environment and I’ll give you exact deployment steps step-by-step 💪