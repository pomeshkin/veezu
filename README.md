# Overview - Chaotic Backend Deployment
This repo contains:
- application helm charts
- terraform code wrapped by terragrunt
- documentation

## Initial setup
1. Install [tenv](https://github.com/tofuutils/tenv/releases/)
2. Execute `tenv tf install 1.14.0`
3. Execute `tenv tg install 0.93.9`
4. Setup AWS profiles `[veezu-prod]`

## How to apply terragrunt
1. Change directory to `veezu/terragrunt`
2. Execute `terragrunt run --all init`
3. Execute `terragrunt run --all plan`
4. Execute `terragrunt run --all apply`

## How to access application (AWS ALB)
- [https://prod.veezu.pomeshk.in/](https://prod.veezu.pomeshk.in/)
- [https://prod.veezu.pomeshk.in/health/live](https://prod.veezu.pomeshk.in/health/live)
- [https://prod.veezu.pomeshk.in/health/ready](https://prod.veezu.pomeshk.in/health/ready)
- [https://prod.veezu.pomeshk.in/probe/data](https://prod.veezu.pomeshk.in/probe/data)

## Terragrunt structure

## TODO items
- Setup monitoring and logging
- Complete documentation
