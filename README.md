# OCI 3-Tier Web Architecture with Terraform

This project deploys a standard 3-tier web architecture on Oracle Cloud Infrastructure (OCI) using Terraform. The infrastructure is modularized into `network`, `compute`, `load_balancer`, and `database` components, which are provisioned and managed as separate Terraform states.

## 🏗️ Architecture

This configuration provisions the following cloud resources:

* **Network:** A single VCN with one public subnet and one private subnet.
    * **Public Subnet:** Hosts the Load Balancer and the Bastion (jump) host.
    * **Private Subnet:** Hosts the private web server instances.
* **Compute:** Two virtual machines.
    * `public_instance`: A bastion host providing a secure SSH entry point.
    * `private_instance`: A private web server (e.g., Nginx) that connects to the database.
* **Load Balancer:** A public, flexible Load Balancer that distributes HTTP (port 80) traffic to the `private_instance`.
* **Database:** A public, "Always Free" Autonomous Database (OLTP) for the application backend.

## 🗂️ Directory Structure

This repository is organized into independent Terraform root modules, which are linked using `terraform_remote_state`.

* **`network/`**: Manages the core network infrastructure (VCN, Subnets, Gateways, Security Lists).
* **`compute/`**: Manages the VM instances (depends on `network`).
* **`load_balancer/`**: Manages the Load Balancer (depends on `network` and `compute`).
* **`database/`**: Manages the Autonomous Database (depends on `network` for `compartment_id` only).

---

## 📋 1. Prerequisites

1.  **Terraform:** v1.0+
2.  **OCI Account:** An OCI user with API keys configured.
3.  **OCI Object Storage Bucket:** A private bucket is required to store the Terraform state files (`.tfstate`).

---

## ⚙️ 2. Configuration

### 1. Backend Configuration

You must edit the `backend.tf` file in **each** directory (`network/`, `compute/`, `load_balancer/`, and `database/`) to match your OCI environment.

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

2. Environment Variables

This project uses environment variables (not .tfvars files) to supply sensitive or environment-specific values.

Tip: Save these export commands in a file named env.sh and run source env.sh before using Terraform.

```Bash
# --- OCI Provider Authentication (Required) ---
export TF_VAR_tenancy_ocid="<YOUR_TENANCY_OCID>"
export TF_VAR_user_ocid="<YOUR_USER_OCID>"
export TF_VAR_fingerprint="<YOUR_API_KEY_FINGERPRINT>"
export TF_VAR_private_key_path="<YOUR_PRIVATE_KEY_PATH>"
export TF_VAR_region="ap-tokyo-1"

# --- Shared Infrastructure (Used by all modules) ---
export TF_VAR_compartment_id="<YOUR_COMPARTMENT_OCID>"

# --- Network Configuration (Used in network/) ---
export TF_VAR_vcn_cidr_block="10.0.0.0/16"
export TF_VAR_subnet_cidr_block="10.0.1.0/24" # Public
export TF_VAR_private_subnet_cidr_block="10.0.2.0/24" # Private
export TF_VAR_source_cidr_for_ssh="<YOUR_HOME_PUBLIC_IP>/32" # Your IP for SSH access

# --- Compute Configuration (Used in compute/) ---
export TF_VAR_availability_domain="<YOUR_AD_1>"
export TF_VAR_image_bastion_id="<YOUR_CUSTOM_IMAGE_OCID>" # Oracle Linux image
export TF_VAR_image_private_id="<YOUR_CUSTOM_IMAGE_OCID>" # Nginx and sqlplus preinstalled image
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"
export TF_VAR_instance_display_name="Terraform-Instance"

# --- Database Configuration (Used in database/) ---
export TF_VAR_db_admin_password="<Your_Secure_Password123#>" # Must be complex
export TF_VAR_db_name="mydemodb"
```

🚀 3. Deployment Steps

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

Step 4: Deploy Database

```Bash
cd ../database
terraform init
terraform apply
```

When apply completed, db_id will be printed out 

## ➡️ 4. Access & Post-Deployment

### 1. Web Access
`http://<load_balancer_public_ip>`
(You can confirm the IP with `terraform output load_balancer_public_ip` in the `load_balancer` directory.)

### 2. SSH Access
(No change) Using `ProxyJump` in your `~/.ssh/config` is recommended for easy access.

### 3. Database ACL Configuration (CRITICAL MANUAL STEP)

The Autonomous Database is deployed with a *public* endpoint, but its firewall (Access Control List) blocks all traffic by default.

Because the private instances connect via a **Service Gateway (SGW)**, not the NAT Gateway, you must add the **Virtual Cloud Network (VCN)** to the ACL.

1.  Go to the OCI Console -> Autonomous Database -> `MyTerraformADB`.
2.  On the database details page, scroll down to the **Network** section.
3.  Click [Edit] for the **Access Control List (ACL)**.
4.  Change the `IP notation type` from "IP address" to **"Virtual Cloud Network"**.
5.  Select your VCN (e.g., `MyVcn`) from the dropdown.
6.  (Recommended) Click [Add access control rule] and also add your local PC's public IP (using the "IP address" type) to connect with tools like SQL Developer.
7.  Click [Save].

🧹 5. Cleanup (Destroy)

To destroy all resources, you must proceed in the reverse order of deployment.

```Bash
cd database && terraform destroy
cd ../load_balancer && terraform destroy
cd ../compute && terraform destroy
cd ../network && terraform destroy
```
