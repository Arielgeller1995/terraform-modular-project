# Destroy All Resources to Avoid Charges

This guide will help you destroy all AWS resources to stop incurring charges.

## ⚠️ Important Cost Notes

**Main cost drivers:**
- **NAT Gateway**: ~$0.045/hour (~$32/month) + data transfer costs
- **EKS Cluster**: ~$0.10/hour (~$73/month) 
- **EC2 Instances** (node groups): Depends on instance type (t3.small = ~$0.02/hour)
- **EBS Volumes**: ~$0.10/GB/month

**Total estimated monthly cost if left running: ~$100-150/month**

## Destruction Order

**IMPORTANT:** Destroy resources in this order:

1. **Kubernetes resources first** (depends on networking)
2. **Networking resources second** (can be destroyed independently)

## Step 1: Destroy Kubernetes Resources

```bash
cd environments/dev/eu-north-1/kubernetes

# Option A: Use the destroy script
./destroy-all.sh

# Option B: Manual terraform destroy
terraform destroy -auto-approve
```

## Step 2: Destroy Networking Resources

```bash
cd environments/dev/eu-north-1/networking

# Option A: Use the destroy script
./destroy-networking.sh

# Option B: Manual terraform destroy
terraform destroy -auto-approve
```

## Quick One-Liner (if you're confident)

```bash
# Destroy Kubernetes
cd environments/dev/eu-north-1/kubernetes && terraform destroy -auto-approve

# Destroy Networking
cd ../networking && terraform destroy -auto-approve
```

## Verification

After destruction, verify resources are gone:

```bash
# Check for EKS clusters
aws eks list-clusters --region eu-north-1

# Check for NAT Gateways (main cost driver)
aws ec2 describe-nat-gateways --region eu-north-1 --filter "Name=state,Values=available"

# Check for running EC2 instances
aws ec2 describe-instances --region eu-north-1 --filters "Name=instance-state-name,Values=running"
```

## If Terraform Destroy Fails

If terraform destroy fails, you may need to manually delete resources via AWS Console or CLI:

1. **EKS Cluster**: AWS Console → EKS → Delete cluster (node groups must be deleted first)
2. **NAT Gateway**: AWS Console → VPC → NAT Gateways → Delete
3. **EC2 Instances**: AWS Console → EC2 → Terminate instances

## Notes

- NAT Gateway charges stop immediately upon deletion
- EKS cluster charges stop when cluster is deleted
- Some resources (like EBS volumes) may persist if not explicitly deleted
- VPCs themselves are free, but components (NAT, data transfer) cost money
