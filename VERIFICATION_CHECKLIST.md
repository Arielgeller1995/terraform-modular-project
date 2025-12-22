# ✅ EKS Node Creation - Verification Checklist

## Pre-Deployment Checks

### 1. Review Changes
```bash
cd /workspace
git status
git diff
```

**Verify:**
- [ ] Kubernetes version changed from 1.32 → var.cluster_version (1.30)
- [ ] Node group uses variables instead of hardcoded values
- [ ] subnet_ids explicitly added to node group
- [ ] Instance type changed to t3.small
- [ ] IAM CNI policy attachment added

---

### 2. Check AWS Region Availability

**Verify t3.small availability in all AZs:**
```bash
aws ec2 describe-instance-type-offerings \
  --location-type availability-zone \
  --filters Name=instance-type,Values=t3.small \
  --region eu-north-1 \
  --query 'InstanceTypeOfferings[*].[Location]' \
  --output table
```

**Expected:** Should show eu-north-1a, eu-north-1b, eu-north-1c

---

### 3. Verify EKS Version Support

```bash
aws eks describe-addon-versions \
  --kubernetes-version 1.30 \
  --region eu-north-1 \
  --query 'addons[].addonName' \
  --output table
```

**Expected:** Should list vpc-cni, kube-proxy, coredns, etc.

---

### 4. Check Current Infrastructure State

**Check networking state:**
```bash
cd environments/dev/eu-north-1/networking
terraform output
```

**Verify outputs include:**
- [ ] vpc_id
- [ ] private_subnets (should be a list of subnet IDs)
- [ ] public_subnets

**If networking not deployed yet:**
```bash
terraform init
terraform plan
terraform apply
```

---

## Deployment Steps

### Step 1: Initialize Kubernetes Environment
```bash
cd /workspace/environments/dev/eu-north-1/kubernetes
terraform init -upgrade
```

**Expected:** 
```
Initializing modules...
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

---

### Step 2: Run Terraform Plan
```bash
terraform plan -out=tfplan
```

**Review plan output - Look for:**

✅ **Good signs:**
```
# module.eks.aws_eks_cluster.this[0] will be created/updated
# module.eks.aws_eks_node_group.this["default"] will be created

  + kubernetes_version = "1.30"
  + instance_types     = ["t3.small"]
  + subnet_ids         = [subnet-xxxxx, subnet-yyyyy, ...]
```

❌ **Bad signs (STOP if you see these):**
```
Error: Unsupported argument
Error: Invalid version
Error: Invalid reference to remote state
```

---

### Step 3: Apply Changes
```bash
terraform apply tfplan
```

**Monitor for:**
- Cluster creation/update: ~10-15 minutes
- Node group creation: ~5-10 minutes
- Nodes joining cluster: ~3-5 minutes

---

### Step 4: Verify Node Health

**Wait for nodes to be Ready:**
```bash
# Get kubeconfig
aws eks update-kubeconfig \
  --region eu-north-1 \
  --name dev-eks-cluster

# Check nodes
kubectl get nodes
```

**Expected output:**
```
NAME                                          STATUS   ROLES    AGE   VERSION
ip-10-0-1-123.eu-north-1.compute.internal    Ready    <none>   2m    v1.30.x
```

**Check node details:**
```bash
kubectl describe node <node-name>
```

Look for:
- [ ] Status: Ready
- [ ] No SchedulingDisabled
- [ ] Running pods (CoreDNS, kube-proxy, AWS node)

---

## Troubleshooting

### If Nodes Still Fail to Launch

#### 1. Check Node Group Events
```bash
aws eks describe-nodegroup \
  --cluster-name dev-eks-cluster \
  --nodegroup-name default-ng \
  --region eu-north-1 \
  --query 'nodegroup.health.issues'
```

#### 2. Check CloudWatch Logs
```bash
aws logs tail /aws/eks/dev-eks-cluster/cluster --follow
```

#### 3. Check EC2 Launch Issues
```bash
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name <asg-name> \
  --region eu-north-1 \
  --max-records 10
```

#### 4. Common Issues & Solutions

| Error | Solution |
|-------|----------|
| `Unhealthy: LaunchFailure` | Check instance type availability in AZ |
| `Unhealthy: ResourceLimitExceeded` | Check service quotas |
| `Unhealthy: InsufficientFreeAddresses` | Check VPC subnet capacity |
| `Nodes not joining cluster` | Check security groups allow pod networking |
| `CannotPullImage` | Check NAT Gateway is working |

---

## Rollback Plan (If Needed)

### If deployment fails:

1. **Save error output:**
```bash
terraform show > deployment_error.log
kubectl get nodes -o yaml > nodes_status.yaml
```

2. **Check what was created:**
```bash
aws eks list-clusters --region eu-north-1
aws eks list-nodegroups --cluster-name dev-eks-cluster --region eu-north-1
```

3. **Destroy failed resources:**
```bash
terraform destroy -target=module.eks.aws_eks_node_group.this
```

4. **Revert changes:**
```bash
git stash
# Or
git reset --hard HEAD~1
```

---

## Success Criteria

### ✅ Deployment Successful When:

- [ ] `terraform apply` completes without errors
- [ ] Node group shows "ACTIVE" status in AWS console
- [ ] `kubectl get nodes` shows nodes in "Ready" status
- [ ] System pods are running: `kubectl get pods -n kube-system`
- [ ] Can deploy test pod: `kubectl run nginx --image=nginx`
- [ ] Test pod can pull images (confirms NAT Gateway working)

---

## Post-Deployment

### 1. Document Configuration
```bash
# Save current state
terraform output > current_outputs.txt
kubectl get nodes -o wide > cluster_nodes.txt
```

### 2. Tag Resources (Optional)
```bash
aws eks tag-resource \
  --resource-arn arn:aws:eks:eu-north-1:ACCOUNT:cluster/dev-eks-cluster \
  --tags "LastUpdated=$(date +%Y-%m-%d),UpdatedBy=$USER"
```

### 3. Update Documentation
- Document instance type change (t3.micro → t3.small)
- Note cost implications (~$15/month per node vs ~$7.50)
- Record Kubernetes version (1.30)

---

## Cost Optimization Tips (Optional)

### After successful deployment:

**Option 1: Use Spot Instances (60-90% cheaper)**
```hcl
capacity_type = "SPOT"
instance_types = ["t3.small", "t3a.small", "t2.small"]  # Multiple types for better availability
```

**Option 2: Use Fargate for some workloads**
- No node management required
- Pay only for pod compute time
- Good for batch/scheduled jobs

**Option 3: Cluster Autoscaler**
- Scale to 0 when not in use
- Save costs during non-business hours

---

## Questions Before Proceeding?

1. **Do you have sufficient AWS service quotas?**
   - Check: EC2 vCPU limits
   - Check: VPC Elastic IP limits (if not using single NAT)

2. **Do you have monitoring set up?**
   - CloudWatch Container Insights?
   - Prometheus/Grafana?

3. **Is this a production cluster?**
   - Consider multi-AZ node groups
   - Consider multiple NAT Gateways
   - Consider private cluster endpoint

---

**Ready to deploy?** Follow steps 1-4 above! 🚀
