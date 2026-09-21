# WordPress Terraform final project

Set the database password without committing it, then run:

```bash
export TF_VAR_db_password='choose-a-strong-password'
terraform init
terraform validate
terraform plan
terraform apply
terraform output wordpress_url
terraform destroy
```

