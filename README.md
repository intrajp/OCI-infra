# OCI 3-Tier Web Architecture with Terraform

This project deploys a standard 3-tier web architecture on Oracle Cloud Infrastructure (OCI) using Terraform. The infrastructure is modularized into `network`, `compute`, and `load_balancer` components, which are provisioned and managed as separate Terraform states.

## 🏗️ Architecture

This configuration provisions the following cloud resources:

* **Network:** A single VCN with one public subnet and one private subnet.
    * **Public Subnet:** Hosts the Load Balancer and the Bastion (jump) host.
    * **Private Subnet:** Hosts the private web server instances.
* **Compute:** Two virtual machines.
    * `public_instance`: A bastion host providing a secure SSH entry point.
    * `private_instance`: A private web server (e.g., Nginx) that only accepts traffic from the Load Balancer.
* **Load Balancer:** A public, flexible Load Balancer that distributes HTTP (port 80) traffic to the backend set (`private_instance`).

## 🗂️ Directory Structure

This repository is organized into independent Terraform root modules, which are linked using `terraform_remote_state`.

* **`network/`**: Manages the core network infrastructure (VCN, Subnets, Gateways, Security Lists).
* **`compute/`**: Manages the VM instances (depends on `network`).
* **`load_balancer/`**: Manages the Load Balancer (depends on `network` and `compute`).

---

## 📋 1. Prerequisites

1.  **Terraform:** v1.0+
2.  **OCI Account:** An OCI user with API keys configured.
3.  **OCI Object Storage Bucket:** A private bucket is required to store the Terraform state files (`.tfstate`).

---

## ⚙️ 2. Configuration

### 1. Backend Configuration

You must edit the `backend.tf` file in **each** directory (`network/`, `compute/`, `load_balancer/`) to match your OCI environment.

```hcl
# Example: backend.tf
terraform {
  backend "oci" {
    bucket    = "intrajp_oci_certificates" # ⬅️ Your bucket name
    namespace = "nrdrpcgfpznz"           # ⬅️ Your Object Storage namespace
    # key = "..." (This is unique for each directory)
    # ...
  }
}
```

## 2. Environment Variables

This project uses environment variables (not .tfvars files) to supply sensitive or environment-specific values.

Tip: Save these export commands in a file named env.sh and run source env.sh before using Terraform.

```Bash
# --- OCI Provider Authentication (Required) ---
export TF_VAR_tenancy_ocid="<tenancy_ocid>"
export TF_VAR_user_ocid="<user_ocid>"
export TF_VAR_fingerprint="<fingerprint>"
export TF_VAR_private_key_path="/path/to/private/key"
export TF_VAR_region="<region>"

# --- Shared Infrastructure (Used by all modules) ---
export TF_VAR_compartment_id="<compartment_id>"

# --- Network Configuration (Used in network/) ---
export TF_VAR_vcn_cidr_block="10.0.0.0/16"
export TF_VAR_public_subnet_cidr_block="10.0.1.0/24" # Public
export TF_VAR_private_subnet_cidr_block="10.0.2.0/24" # Private
export TF_VAR_source_cidr_for_ssh="<YOUR_HOME_PUBLIC_IP>/32" # Your IP for SSH access

# --- Compute Configuration (Used in compute/) ---
export TF_VAR_availability_domain="<availability_domain>"
export TF_VAR_image_id="<image_id>"
export TF_VAR_ssh_public_key=$(cat /path/to/public/key)
export TF_VAR_instance_display_name="<instance_display_name>"

# --- Database Configuration (Used in database/) ---
export TF_VAR_db_admin_password="Your_Secure_Password123#"
```

## 3. Deployment Steps

Resources must be deployed in order of dependency.

Step 1: Deploy Network

```Bash
cd network
terraform init
terraform apply
```

Step 2: Deploy Compute

```Bash
cd ../compute
terraform init
terraform apply
```

Step 3: Deploy Load Balancer

```Bash
cd ../load_balancer
terraform init
terraform apply
```

On completion, the load_balancer_public_ip will be displayed in the outputs.

## 4. Cleanup (Destroy)

To destroy all resources, you must proceed in the reverse order of deployment.

```Bash
cd load_balancer && terraform destroy
cd ../compute && terraform destroy
cd ../network && terraform destroy
```
