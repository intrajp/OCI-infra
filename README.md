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
* **`dns/`**: Manages the OCI DNS Zone and records (depends on `load_balancer`).

## 🗂️ Directory Structure

This repository is organized into independent Terraform root modules, which are linked using `terraform_remote_state`.

* **`network/`**: Manages the core network infrastructure (VCN, Subnets, Gateways, Security Lists).
* **`compute/`**: Manages the VM instances (depends on `network`).
* **`load_balancer/`**: Manages the Load Balancer (depends on `network` and `compute`).
* **`database/`**: Manages the Autonomous Database (depends on `network` for `compartment_id` only).
* **`dns/`**: Manages the OCI DNS Zone and records (depends on `load_balancer`).

---

## 📋 1. Prerequisites

1.  **Terraform:** v1.0+
2.  **OCI Account:** An OCI user with API keys configured.
3.  **OCI Object Storage Bucket:** A private bucket is required to store the Terraform state files (`.tfstate`).
4.  Custom Images for public instance and private instance. Public instance is for bastion only so no problem, but private instance needs Nginx and sqlplus installed. No need to explain about Nginx, so I will explain about how I installed sqlplus.
    I installed these two packages and created a custom image.

    oracle-instantclient-basic-23.9.0.25.07-1.el9.x86_64.rpm
    oracle-instantclient-sqlplus-23.9.0.25.07-1.el9.x86_64.rpm
---

## ⚙️ 2. Configuration

### 1. Backend Configuration

You must edit the `backend.tf` file in **each** directory (`network/`, `compute/`, `load_balancer/`, `database/`, and `dns/`) to match your OCI environment.

```hcl
# Example: backend.tf
terraform {
  backend "oci" {
    bucket    = "bucket-20251111-1910" # ⬅️ Your bucket name
    namespace = "nrdrpcgfpznz"           # ⬅️ Your Object Storage namespace
    # key = "..." (This is unique for each directory)
    # ...
  }
}
```

### 2. Environment Variables

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

# --- Domain name ---
export TF_VAR_domain_name="<your domain name>" # e.g. letsgopc.net
```

## 🚀 3. Deployment Steps

Resources must be deployed in order of dependency.

### Step 1: Deploy Compartments (The Foundation)

```Bash
cd compartments 
terraform init
terraform apply
```

### Step 2: Deploy Network

```Bash
cd network
terraform init
terraform apply
```

### Step 3: Deploy Compute

```Bash
cd ../compute
terraform init
terraform apply
```

### Step 4: Deploy Load Balancer
(The complex one. Depends on network, compute, dns, and iam)

```Bash
cd ../load_balancer
terraform init
terraform apply
```

### Step 5: Deploy DNS

```Bash
cd ../dns
terraform init
terraform apply
```

### Step 6: Deploy Database

```Bash
cd ../database
terraform init
terraform apply
```

When apply completed, db_id will be printed out 

## ➡️ 4. Access & Post-Deployment

### 1. DNS Delegation (CRITICAL ONE-TIME MANUAL STEP)

After deploying the `dns/` module (Step 4), you must **delegate your domain's nameservers** to OCI. This is a **one-time** setup.

1.  Run `terraform output` inside the `dns/` directory to get your 4 OCI nameservers.

    ```bash
    $ terraform output oci_nameservers
    [
      "ns1.p201.dns.oraclecloud.net.",
      "ns2.p201.dns.oraclecloud.net.",
      ...
    ]
    ```

2.  Log in to your domain registrar (e.g., Squarespace, Google Domains).
3.  Find the Nameserver (NS) settings for your domain (`myawesomeservice.net`).
4.  Remove all existing nameservers (like `ns-cloud-b1.googledomains.com`).
5.  Add the **4 OCI nameservers** from your Terraform output.

Once DNS propagates (minutes to hours), OCI will automatically manage your A records. If you destroy/re-apply the load balancer, just re-run `terraform apply` in the `dns/` directory to update the IP.

### 2. Web Access
`http://<load_balancer_public_ip>`
(You can confirm the IP with `terraform output load_balancer_public_ip` in the `load_balancer` directory.)

### 3. SSH Access
Using `ProxyJump` in your `~/.ssh/config` is recommended for easy access.

Example:
```Bash
Host OCI-bastion
  HostName <PublicIP of public instance> 
  User opc
  IdentityFile </path/to/private_key> 
  ProxyCommand none
  ForwardAgent yes

Host private-vm
  HostName <PrivateIP of private instance> 
  User opc
  ProxyJump OCI-bastion
  IdentityFile </path/to/private_key> 
```

### 4. Database ACL Configuration (CRITICAL MANUAL STEP)

The Autonomous Database is deployed with a *public* endpoint, but its firewall (Access Control List) blocks all traffic by default.

Because the private instances connect via a **Service Gateway (SGW)**, not the NAT Gateway, you must add the **Virtual Cloud Network (VCN)** to the ACL.

1.  Go to the OCI Console -> Autonomous Database -> `MyTerraformADB`.
2.  On the database details page, scroll down to the **Network** section.
3.  Click [Edit] for the **Access Control List (ACL)**.
4.  Change the `IP notation type` from "IP address" to **"Virtual Cloud Network"**.
5.  Select your VCN (e.g., `MyVcn`) from the dropdown.
6.  (Recommended) Click [Add access control rule] and also add your local PC's public IP (using the "IP address" type) to connect with tools like SQL Developer.
7.  Click [Save].

### 5. Connect to Database from private instance

To connect the Autonomous Database from private instance, you have to have a wallet.

1. Go to 'Oracle AI Database -> MyTerraformADB -> Database connection'
2. Download wallet to your local machine.
3. Set password as 'Your_Secure_Password123#' and click 'Download'
4. Send wallet to private instance from your local machine like this.
   $ scp Wallet_mydemodb.zip private-vm:~/
5. Go to private-vm and unzip the file.

   ```Bash
   [opc@tf-private ~]$ unzip Wallet_mydemodb.zip -d ~/wallet
   ```

6. Edit wallet location to /home/opc/wallet 

   ```Bash
   [opc@tf-private ~]$ vim ~/wallet/sqlnet.ora 

   #WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="?/network/admin")))
   WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="/home/opc/wallet")))
   SSL_SERVER_DN_MATCH=yes
   ```

7. Export TNS_ADMIN like this.

   ```Bash
   [opc@tf-private ~]$ export TNS_ADMIN=~/wallet
   ```

8. Connect with sqlplus 
   Now you could connect like this, right?

   ```Bash
   [opc@tf-private ~]$ sqlplus admin@mydemodb_high
  
   SQL*Plus: Release 23.0.0.0.0 - Production on Wed Nov 5 20:43:00 2025
   Version 23.9.0.25.07

   Copyright (c) 1982, 2025, Oracle.  All rights reserved.

   Enter password:Your_Secure_Password123#

   Connected to:
   Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
   Version 19.29.0.1.0

   SQL>
   ```

### 6. HTTPS/SSL Configuration (Manual Certbot Setup)

After deployment, the Load Balancer is configured for TCP passthrough on ports 80 and 443 (SSL/TLS is handled by Nginx, not the LB). You must manually install Let's Encrypt certificates on the `private_instance` using `certbot`.

1.  **Log in to the private instance (Bastion Jump):**
    ```bash
    # (Assuming you have ~/.ssh/config setup)
    ssh private-vm
    ```

2.  **Install Certbot & Nginx Plugin:**
    Certbot is not in the default Oracle Linux 10 repos. You must find and enable the EPEL repository first.
    ```bash
    # Install the EPEL repo package (ol10_addons may be needed)
    sudo dnf install -y oracle-epel-release-el10
    
    # Enable the specific EPEL repo
    sudo dnf config-manager --enable ol10_u0_developer_EPEL
    
    # Install certbot and the nginx plugin
    sudo dnf install -y certbot python3-certbot-nginx
    ```

3.  **Configure Nginx `server_name`:**
    `certbot` needs to find a `server_name` that matches your domain.
    ```bash
    sudo vim /etc/nginx/nginx.conf
    ```
    Inside the `server { ... }` block (the one listening on port 80), change the default `server_name _;` to your domain:
    For example, if your domain is letsgopc.net,
    ```nginx
    server_name letsgopc.net www.letsgopc.net;
    ```
    Test the config before proceeding:
    ```bash
    sudo nginx -t
    ```

4.  **Open the OS Firewall:**
    The OCI Security Lists are open, but the VM's internal firewall must also be opened.
    ```bash
    sudo firewall-cmd --add-service=https --permanent
    sudo firewall-cmd --reload
    ```

5.  **Run Certbot:**
    This command will fetch the certificate, automatically update your Nginx config for SSL, and (if you choose) set up the redirect.
    ```bash
    sudo certbot --nginx -d letsgopc.net -d www.letsgopc.net
    ```
    * Enter your email address.
    * Agree to the Terms of Service (`Y`).
    * When asked to **Redirect**, choose option **`2`**.

6.  **Enable Auto-Renewal:**
    This ensures your certificate renews automatically before it expires.
    ```bash
    sudo systemctl start certbot-renew.timer
    sudo systemctl enable certbot-renew.timer
    ```

Your site for example, at `http://letsgopc.net` should now be force-redirected to `https://letsgopc.net` with a valid lock icon.

## 🧹 5. Cleanup (Destroy)

To destroy all resources, you must proceed in the **reverse order** of deployment.

**Note:** The Autonomous Database is protected from accidental deletion by a `prevent_destroy` flag. You must manually remove this protection *before* you can destroy it.

### Step 1: Destroy Database (Protected)
1.  Navigate to the `database/` directory.
2.  Edit `database/main.tf`.
3.  Comment out (or delete) the `lifecycle { prevent_destroy = true }` block inside the `oci_database_autonomous_database` resource.
4.  Run `terraform apply` to update the state (this removes the protection).
5.  Now, run `terraform destroy` to delete the database.

### Step 2: Destroy DNS

```bash
cd ../dns
terraform destroy
```

### Step 3: Destroy Load Balancer 

```bash
cd ../load_balancer
terraform destroy
```

### Step 4: Destroy Compute 

```bash
cd ../compute
terraform destroy
```

### Step 5: Destroy Network 

```bash
cd ../network
terraform destroy
```

### Step 6: Destroy Compartment 

```bash
cd ../compartment
terraform destroy
```

### Hint
You had better only destroy 'compute' which makes your bill small and re-creation fast.

If you do, please re-create 'load_balancer' after you have re-created 'compute'.

Then re-do the process of certbot e.g., 'sudo certbot --nginx -d letsgopc.net -d www.letsgopc.net' selecting option 2 (renew and replace the certificate).

Just database is in the public subnet, you can set your host machine's public IP so that you can play with. 

In that case, your host machine needs sqlplus installed. After install, you have to download Wallet and set the path and env properly to login.
