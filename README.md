# OCI-infra

## Needed environment variables

```bash
export TF_VAR_tenancy_ocid="<tenancy_ocid>"
export TF_VAR_user_ocid="<user_ocid>"
export TF_VAR_figerprint="<fingerprint>"
export TF_VAR_private_key_path="/path/to/private/key"
export TF_VAR_region="<region>"
export TF_VAR_compartment_id="<compartment_id>"
export TF_VAR_availability_domein="<availability_domain>"
export TF_VAR_subnet_id="<subent_id>"
export TF_VAR_image_id="<image_id>"
export TF_VAR_instance_display_name="<instance_display_name>"
export TF_VAR_ssh_public_key=$(cat /path/to/public/key)
```
