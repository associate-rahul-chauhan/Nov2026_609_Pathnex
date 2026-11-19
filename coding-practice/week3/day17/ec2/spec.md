# Terraform EC2 Spec (day17/ec2)

## 1. What is Terraform?

Terraform is an Infrastructure as Code (IaC) tool. You describe the cloud resources you want in `.tf` files (declarative), and Terraform works out what to create, change or delete so that AWS matches the files.

Key ideas:
- **Provider**: plugin that talks to a cloud API (here `hashicorp/aws`).
- **Resource**: something Terraform creates and manages (EC2 instance, security group).
- **Data source**: something that already exists and is only read (default VPC, AMI).
- **Variable**: an input. **Output**: a value printed after apply.
- **State** (`terraform.tfstate`): Terraform's record of what it created. It compares state with your files to decide what to change.

## 2. Goal of this project

Create one EC2 virtual machine in the default VPC of `ap-southeast-2`:
- Amazon Linux 2023, `t3.micro`, tagged `my-first-terraform-ec2`
- Security group allowing SSH (22) inbound and all traffic outbound
- Print instance ID, public IP and public DNS

## 3. Workflow (steps we follow)

Run all commands inside `coding-practice/week3/day17/ec2`.

| Step | Command | What happens |
|---|---|---|
| 1. Write | edit `.tf` files | Describe the infrastructure. |
| 2. Configure credentials | `aws configure` (or env vars) | Terraform needs AWS access to run. |
| 3. Init | `terraform init` | Downloads the AWS provider (6.x) into `.terraform/` and creates a lock file. |
| 4. Format | `terraform fmt` | Tidies code style (optional). |
| 5. Validate | `terraform validate` | Checks syntax and references, no AWS calls. |
| 6. Plan | `terraform plan` | Shows what will be created/changed/destroyed. Nothing is changed yet. |
| 7. Apply | `terraform apply` | Type `yes`. Creates the resources, saves state, prints outputs. |
| 8. Verify | `terraform output`, AWS console | Check IP/DNS and that the instance is running. |
| 9. Destroy | `terraform destroy` | Deletes everything created, to avoid cost. |

## 4. Which file does what

| File | Responsibility | Contents |
|---|---|---|
| `provider.tf` | Which cloud and which version | `terraform` block pins `hashicorp/aws ~> 6.0`; `provider "aws"` sets region from `var.aws_region`. |
| `variable.tf` | Declares inputs | `aws_region`, `instance_type`, `instance_name` with type, description, default. |
| `terraform.tfvars` | Supplies input values | `ap-southeast-2`, `t3.micro`, `my-first-terraform-ec2`. Auto-loaded, overrides defaults. |
| `main.tf` | The infrastructure itself | Data sources, security group, EC2 instance (see section 5). |
| `output.tf` | Results shown after apply | `instance_id`, `public_ip`, `public_dns`. |

Terraform reads every `.tf` file in the folder together, so file names are only for organisation.

## 5. What `main.tf` does, in order

1. `data "aws_vpc" "default"`: finds the account's default VPC.
2. `data "aws_subnets" "default"`: lists subnets in that VPC.
3. `data "aws_ami" "amazon_linux"`: finds the newest Amazon Linux 2023 x86_64 image owned by Amazon.
4. `resource "aws_security_group" "ec2_sg"`: firewall in the default VPC. Inbound TCP 22 from `0.0.0.0/0`; outbound everything.
5. `resource "aws_instance" "learning_ec2"`: the VM. Uses the AMI from step 3, `var.instance_type`, the first subnet from step 2, a public IP, the security group from step 4, and tags (`Name`, `Environment`, `ManagedBy`).

## 6. Data flow

```
terraform.tfvars / variable.tf --> var.aws_region --> provider.tf (region)
                               --> var.instance_type, var.instance_name --> main.tf (aws_instance)

main.tf: default VPC --> subnets ----------------------+
         default VPC --> security group ---------------+--> aws_instance <-- AMI
                                                        |
                                                        +--> output.tf (id, public IP, DNS)
```

Terraform builds a dependency graph from these references, so the security group is created before the instance automatically.

## 7. Files Terraform generates (not written by us)

- `.terraform/`: downloaded provider plugins.
- `.terraform.lock.hcl`: locks exact provider versions (commit this).
- `terraform.tfstate` and `.backup`: state. Do not commit; they can contain sensitive data.

## 8. Known limitations

- SSH is open to the whole internet. Restrict `cidr_blocks` to your own IP for real use.
- No key pair is attached (`key_name`), so SSH login is not possible until one is added.
- Uses the default VPC and its first subnet, which is fine for learning but not for production.
