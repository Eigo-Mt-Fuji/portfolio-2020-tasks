# PortfolioTasks

**TODO: Add description**

## 使い方

### インフラ

|:環境:|:手順:|
|:----:|:----:|
|dev|[こちら](#dev環境インフラ更新手順)|

### dev環境インフラ更新手順

```bash
export AWS_PROFILE=efgriver
cd terraform/
terraform init -backend=true
terraform plan -out=terraform.plan 
terraform apply "terraform.plan"
```
