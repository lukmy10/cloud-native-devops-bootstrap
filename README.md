# Cloud-Native DevOps Bootstrap

🚀 **One-click end-to-end DevOps setup.** The entire infrastructure and platform lifecycle is fully orchestrated via Ansible (with Terraform executed internally) on DigitalOcean. The Kubernetes (K8s) cluster and Jenkins server are bootstrapped from scratch using a modular Bash script pipeline, automatically provisioning the application build jobs via the Jenkins API.

---

## 🏗️ Architecture & Workflow

1. **Infrastructure (Terraform inside Ansible):** Ansible acts as the single entry point, triggering Terraform under the hood to automatically provision DigitalOcean droplets and networking. Dynamic inventory is managed entirely in-memory.
2. **Platform Bootstrap (Ansible & Bash):** A comprehensive 11-step configuration playbook coordinates localized system preparations, network policies (Calico), and components via native Bash scripting layers.
3. **Programmatic Job Provisioning:** The pipeline utilizes the Jenkins Remote Access API to programmatically inject the Nginx build pipeline configuration template (`nginx.xml`) directly into the cluster.
4. **Summary & Output (Final Layer):** The automation process concludes by dynamically collecting and outputting all active node IP addresses, the Jenkins Web Portal URL, and administrator credentials directly to the console display.

---

## 📁 Repository Structure

```text
cloud-native-devops-bootstrap/
├── ansible/
│   └── bootstrap.yml               # The master playbook (Runs Terraform & orchestrates the setup)
├── scripts/                        # --- MODULAR PLATFORM PIPELINE ---
│   ├── install_apt_helm.sh         # Installs system dependencies and Helm package manager
│   ├── install_kubernetes.sh       # Provisions Kubernetes Control Plane nodes
│   ├── install_kubernetes_worker.sh# Joins worker nodes to the active K8s cluster
│   ├── install_calico.sh           # Configures Calico CNI networking plugin
│   ├── install_helm_jenkins.sh     # Automates the Jenkins platform deployment via Helm
│   ├── get_token.sh                # Retrieves secure programmatic access tokens
│   ├── job_build_api.sh            # Executes deployment triggers via Jenkins Remote Access API
│   ├── final.sh                    # Summarizes cluster state: outputs node IPs, Jenkins URL, and passwords
│   └── nginx.xml                   # Jenkins Job configuration XML template used to programmatically provision the Nginx build pipeline
└── terraform/                      # --- INFRASTRUCTURE AS CODE ---
    ├── main.tf                     # DigitalOcean resource templates (executed by Ansible)
    └── vars.auto.tfvars.example    # Variable template for API access tokens and SSH keys
```

---

## 🚀 Getting Started

### 1. Prerequisites
Ensure you have the following tools, credentials, and configurations ready before execution:
* **Ansible** (installed on your local control node)
* **Terraform** (installed on your local control node)
* **DigitalOcean Personal Access Token** (Read/Write API token generated from your DigitalOcean cloud console)
* **SSH Key Pair** (generated locally via `ssh-keygen`)

### 2. Configuration
Navigate to the `terraform/` folder, copy the template variable file, and populate it with your cloud credentials:

```bash
cd terraform
cp vars.auto.tfvars.example vars.auto.tfvars
```

Open `vars.auto.tfvars` and update the placeholders with your actual **DigitalOcean API Token** and public key location:

```hcl
digitalocean_token = "PUT YOUR ACTUAL TOKEN HERE"
public_key         = "~/.ssh/id_ed25519.pub"
```

### 3. One-Click Deployment
Return to the project root directory. The entire platform lifecycle—from server provisioning to final application pipeline rendering—is managed using a single entry point. Execute the primary playbook:

```bash
ansible-playbook ansible/bootstrap.yml
```

---

## 📄 License

This project is open-source and available under the terms of the **MIT License**.

---
*Note: The technical architecture and automation layers were engineered from scratch. AI tools were utilized to support documentation drafting and architectural review.*
