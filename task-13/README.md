<img width="1004" height="198" alt="diagram-export-9-22-2025-8_01_46-PM" src="https://github.com/user-attachments/assets/1698a3c4-89b0-49a4-a544-614a90c1df4c" />


---

# 📘 CI/CD Pipeline Documentation: EC2 + Jenkins + Ansible + Docker

## 🧱 Infrastructure Overview

- **Cloud Provider**: AWS
- **Instance Type**: `t3.micro`
- **Networking**: Default VPC, subnet, and security group
- **Operating System**: Ubuntu 22.04 LTS (or your chosen OS)
- **Public IP**: (Insert IP or DNS here)
- **Access Method**: SSH with PEM key

---

## 🔧 Software Installation

### 1. **Update System**
```bash
sudo yum update -y
```

### 2. **Install Docker**
```bash
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### 3. **Install Ansible**
```bash
sudo yum install ansible -y
```

### 4. **Install Jenkins**
```bash
sudo yum update -y
sudo wget -O /etc/yum.repos.d/jenkins.repo  https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
sudo yum install java-21-amazon-corretto -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

---

## 🔐 Security Group Configuration

Ensure the EC2 security group allows:
- **Port 22** – SSH
- **Port 8080** – Jenkins UI
- **Port 80/443** – Web app (if applicable)

---

## 🧪 Jenkins Job Configuration

### Job Name: `Build-and-Deploy-App`

#### **Stage 1: Clone Git Repository**
- **Repository URL**: `https://github.com/your-org/your-repo.git`
- **Branch**: `main`
- **Credentials**: SSH key or GitHub token (if private)

#### **Stage 2: Trigger Ansible Playbook**
- **Build Step**: Execute shell
```bash
ansible-playbook playbook.yml
```

---

## 📜 Ansible Playbook: `deploy.yml`

```yaml
-# deploy_docker.yml
---
- name: Deploy Docker Container
  hosts: localhost # Define your target hosts in your inventory
  become: yes # Run tasks with elevated privileges

  tasks:
    - name: Build Docker image
      community.docker.docker_image:
        name: my_app_image
        build:
          path: . # Path to the directory containing your Dockerfile
        state: present
        source: build

    - name: Run Docker container
      community.docker.docker_container:
        name: my_app_container
        image: my_app_image:latest
        state: started
        ports:
          - "80:80" # Map host port 80 to container port 80
```

---

## 🐳 Dockerfile Example

```Dockerfile
# Example Dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y nginx
COPY index.html /var/www/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## ✅ Validation Steps

1. **Check Jenkins Console Output** for success.
2. **Verify Docker Container**:
   ```bash
   docker ps
   curl http://localhost:80
   ```
3. **Access Web App** via EC2 public IP: `http://<your-ec2-ip>:80`

---

## 🧠 Best Practices

- Use environment variables for secrets.
- Add Jenkins to the `docker` group:
  ```bash
  sudo usermod -aG docker jenkins
  ```
- Monitor EC2 resource usage—`t3.micro` is suitable for testing, not production.

---
