# WordPress on AWS with Terraform

Infrastructure as Code project that provisions a complete WordPress stack on AWS with **Terraform**, split into reusable modules.

![Terraform](https://img.shields.io/badge/Terraform-%E2%89%A5%201.5-7B42BC?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-eu--west--3-FF9900?logo=amazonaws)

## Architecture

```
                    Internet
                        │
                ┌───────▼────────┐
                │ Internet GW    │
                └───────┬────────┘
   VPC 10.20.0.0/16     │
  ┌─────────────────────┼──────────────────────────────┐
  │  Public subnet AZ-a │           Public subnet AZ-b │
  │  ┌──────────────────▼───┐                          │
  │  │ EC2 (Amazon Linux)   │  SG "web": HTTP/HTTPS in │
  │  │ Apache + PHP +       │                          │
  │  │ WordPress (user_data)│                          │
  │  └───────┬──────────────┘                          │
  │          │ EBS gp3 volume (10 GB)                  │
  │          │                                         │
  │          │ MySQL 3306 (only from SG "web")         │
  │  ┌───────▼─────────────────────────────────────┐   │
  │  │ RDS MySQL 8.0 — Multi-AZ, not public        │   │
  │  └─────────────────────────────────────────────┘   │
  └────────────────────────────────────────────────────┘
```

## Modules

| Module | What it creates |
|---|---|
| `modules/networking` | VPC, Internet Gateway, 2 public subnets across 2 AZs, route table, security groups (`web`, `database`) |
| `modules/ec2` | EC2 instance on the latest Amazon Linux 2023 AMI (looked up dynamically), bootstrapped with `install_wordpress.sh` |
| `modules/ebs` | Additional gp3 EBS volume (10 GB) created in the instance's AZ and attached to it |
| `modules/rds` | DB subnet group and RDS MySQL 8.0 instance (Multi-AZ, `publicly_accessible = false`) |

The root module wires them together: the RDS endpoint and credentials are injected into the EC2 `user_data` through `templatefile()`, so WordPress is configured automatically on first boot.

## Security choices

- The database password is a **sensitive, non-nullable variable**: it is never committed and never has a default value.
- The database security group only accepts MySQL traffic **from the web server's security group**, not from an IP range.
- RDS is **not publicly accessible**.

## Usage

Prerequisites: Terraform ≥ 1.5 and AWS credentials configured (`aws configure` or environment variables).

```bash
export TF_VAR_db_password='choose-a-strong-password'

terraform init
terraform validate
terraform plan
terraform apply

terraform output wordpress_url   # open this URL in a browser
terraform destroy                # clean up to avoid AWS costs
```

### Main variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `eu-west-3` | AWS region (Paris) |
| `project_name` | `wordpress-exam` | Prefix used for resource names and tags |
| `vpc_cidr` | `10.20.0.0/16` | VPC CIDR block |
| `public_subnet_cidrs` | `["10.20.1.0/24", "10.20.2.0/24"]` | One subnet per AZ |
| `instance_type` | `t3.micro` | EC2 instance type |
| `db_name` / `db_username` | `wordpress` / `wpadmin` | Database settings |
| `db_password` | *(required)* | Sensitive, pass it with `TF_VAR_db_password` |

### Outputs

- `wordpress_url`: public URL of the WordPress site
- `rds_endpoint`: database endpoint

## Next improvements

Things I would add to take this to production level:

- Move RDS into **private subnets** (and add a NAT gateway for outbound traffic from private resources).
- Store the Terraform state remotely in **S3 with DynamoDB locking**.
- Read the database password from **AWS Secrets Manager** instead of a variable.
- Put an **Application Load Balancer** and an Auto Scaling Group in front of the web tier.
- Add a CI pipeline running `terraform fmt -check`, `validate` and `plan` on every pull request.

---
Built by [Imad Sabri](https://www.linkedin.com/in/imadsabri-859a70212) as part of my DevOps training.
