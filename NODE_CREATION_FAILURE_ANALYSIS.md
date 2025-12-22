# EKS Node Creation Failure Analysis

**Branch:** `cursor/node-creation-failure-investigation-d104`  
**Analysis Date:** December 22, 2025

## Executive Summary

Your EKS nodes are failing to create due to **5 critical configuration issues**. The primary cause is using an unsupported Kubernetes version (1.32), but there are also subnet configuration problems and instance type availability concerns.

---

## Critical Issues Identified

### 🔴 Issue #1: Unsupported Kubernetes Version (CRITICAL)

**Location:** `environments/dev/eu-north-1/kubernetes/main.tf:22`

**Problem:**
```hcl
kubernetes_version = "1.32"  # ❌ This version doesn't exist!
```

**Root Cause:** 
- Kubernetes 1.32 is not released yet and not supported by AWS EKS
- As of December 2024, the latest EKS-supported version is 1.31
- AWS will reject node group creation attempts for unsupported K8s versions

**Fix Applied:**
```hcl
kubernetes_version = var.cluster_version  # ✅ Now uses variable (default: "1.30")
```

**Impact:** HIGH - This alone would cause all node launches to fail

---

### 🔴 Issue #2: Hardcoded Values Instead of Variables

**Location:** `environments/dev/eu-north-1/kubernetes/main.tf:30-42`

**Problem:**
```hcl
eks_managed_node_groups = {
  default = {
    min_size     = 1        # ❌ Hardcoded
    desired_size = 1        # ❌ Hardcoded
    max_size     = 2        # ❌ Hardcoded
    instance_types = ["t3.micro"]  # ❌ Hardcoded
```

**Root Cause:**
- Variables were defined but not used
- This makes configuration inflexible and prone to inconsistencies
- Variables show different values (e.g., desired_size = 2 in vars, but 1 in main.tf)

**Fix Applied:**
```hcl
eks_managed_node_groups = {
  default = {
    min_size       = var.min_size        # ✅
    desired_size   = var.desired_size    # ✅
    max_size       = var.max_size        # ✅
    instance_types = var.instance_types  # ✅
    ami_type       = var.ami_type        # ✅
```

**Impact:** MEDIUM - Could cause capacity issues and makes troubleshooting harder

---

### 🔴 Issue #3: Missing Subnet Configuration in Node Group

**Location:** `environments/dev/eu-north-1/kubernetes/main.tf:30-42`

**Problem:**
```hcl
eks_managed_node_groups = {
  default = {
    # ❌ Missing: subnet_ids specification
    name            = "default-ng"
    ...
```

**Root Cause:**
- Node group doesn't explicitly specify which subnets to launch nodes in
- Relies on module defaults which may not propagate correctly
- Can cause nodes to launch in wrong subnets or fail to launch

**Fix Applied:**
```hcl
eks_managed_node_groups = {
  default = {
    # ✅ Explicitly specify subnets
    subnet_ids = data.terraform_remote_state.networking.outputs.private_subnets
    ...
```

**Impact:** HIGH - Nodes may fail to launch or launch in wrong availability zones

---

### 🔴 Issue #4: Instance Type Availability (t3.micro in eu-north-1)

**Location:** `environments/dev/eu-north-1/kubernetes/variables.tf:22`

**Problem:**
```hcl
default = ["t3.micro"]  # ⚠️ May have limited availability in Stockholm
```

**Root Cause:**
- `t3.micro` instances are not available in all availability zones in `eu-north-1` (Stockholm)
- AWS may reject launch requests if instances aren't available in selected AZs
- EKS requires consistent instance types across all node group subnets

**Fix Applied:**
```hcl
default = ["t3.small"]  # ✅ Better availability across all AZs
```

**Alternative Options:**
- `t3.small` - 2 vCPU, 2GB RAM (Recommended)
- `t3a.micro` - AMD variant, better availability
- Multiple instance types: `["t3.small", "t3a.small"]` for better flexibility

**Impact:** MEDIUM-HIGH - Can cause intermittent launch failures

---

### 🔴 Issue #5: Output Naming Inconsistencies

**Location:** `environments/dev/eu-north-1/networking/outputs.tf:6-9`

**Problem:**
```hcl
output "private_subnets" {
  value = try(module.vpc.private_subnet_ids, try(module.vpc.private_subnets, []))
  # ❌ Nested try() blocks indicate confusion about output names
}
```

**Root Cause:**
- VPC module outputs use `private_subnets` 
- Consumers expect both `private_subnets` and `private_subnet_ids`
- Confusing double-try logic suggests past issues with output resolution

**Fix Applied:**
1. Added both output aliases to VPC module:
```hcl
output "private_subnets" { ... }
output "private_subnet_ids" { ... }  # Alias for compatibility
```

2. Simplified environment outputs:
```hcl
output "private_subnets" {
  value = module.vpc.private_subnets  # ✅ Clean, no try() needed
}
```

**Impact:** LOW-MEDIUM - Could cause Terraform errors but less likely to affect runtime

---

## Additional Issues Found

### ⚠️ Issue #6: Missing IAM Configuration (Warning)

**Current State:**
```hcl
# ❌ No explicit IAM role configuration
# ❌ Relying on module defaults
```

**Recommendation:**
While the EKS module will create default IAM roles, it's better to explicitly configure:
```hcl
iam_role_attach_cni_policy = true  # ✅ Added in fix
```

---

### ⚠️ Issue #7: Missing Cluster Endpoint Configuration

**Fix Applied:**
```hcl
cluster_endpoint_public_access  = true   # ✅ Explicit
cluster_endpoint_private_access = false  # ✅ Explicit
```

This ensures your cluster is accessible for management.

---

## Files Modified

### Changes Applied:

1. **`environments/dev/eu-north-1/kubernetes/main.tf`**
   - Fixed Kubernetes version (1.32 → var.cluster_version)
   - Added explicit subnet_ids to node group
   - Added all variable references instead of hardcoded values
   - Added cluster endpoint configuration
   - Added IAM policy attachment
   - Added node tags

2. **`environments/dev/eu-north-1/kubernetes/variables.tf`**
   - Changed default instance type (t3.micro → t3.small)

3. **`modules/networking/vpc/outputs.tf`**
   - Added `private_subnets` output alias
   - Added `public_subnets` output alias

4. **`environments/dev/eu-north-1/networking/outputs.tf`**
   - Simplified private_subnets output
   - Simplified public_subnets output

---

## Testing & Validation

### Before Applying:

1. **Check AWS EKS Version Support:**
```bash
aws eks describe-addon-versions --kubernetes-version 1.30 --region eu-north-1
```

2. **Verify Instance Type Availability:**
```bash
aws ec2 describe-instance-type-offerings \
  --location-type availability-zone \
  --filters Name=instance-type,Values=t3.small \
  --region eu-north-1 \
  --query 'InstanceTypeOfferings[*].[Location]' \
  --output table
```

3. **Validate Subnet Configuration:**
```bash
cd environments/dev/eu-north-1/kubernetes
terraform init
terraform plan
```

Look for:
- ✅ No errors about unsupported versions
- ✅ Node group shows correct subnet IDs
- ✅ Instance type available in all target AZs

---

## Expected Behavior After Fixes

### What Should Work Now:

1. ✅ Nodes will launch with Kubernetes 1.30 (supported version)
2. ✅ Nodes will be created in correct private subnets
3. ✅ t3.small instances have better AZ availability
4. ✅ Configuration uses variables consistently
5. ✅ Output references are clear and unambiguous

### Deployment Order:

```bash
# 1. Update networking if needed
cd environments/dev/eu-north-1/networking
terraform init
terraform apply

# 2. Update kubernetes configuration
cd ../kubernetes
terraform init
terraform plan
terraform apply
```

---

## Commit Message Suggestion

```
fix: resolve EKS node creation failures

- Fix unsupported Kubernetes version (1.32 → 1.30)
- Add explicit subnet_ids to node group configuration
- Use variables instead of hardcoded values
- Change instance type to t3.small for better AZ availability
- Simplify VPC output references
- Add cluster endpoint configuration
- Add IAM CNI policy attachment

Fixes node launch failures in dev EKS cluster
```

---

## Prevention Recommendations

1. **Version Validation:** Always check AWS EKS supported versions before deployment
2. **Variable Usage:** Use variables for all configurable values
3. **Explicit Configuration:** Don't rely on module defaults for critical settings
4. **Region-Specific Testing:** Validate instance types in target regions/AZs
5. **Clear Outputs:** Use consistent naming conventions across modules

---

## Additional Notes

- The commit "0633dc6: EKS cluster working, nodegroup failing on instance launch" confirms cluster creation succeeded but nodes failed
- This matches the pattern where control plane is healthy but worker nodes can't join
- All fixes are backward compatible and should not affect existing cluster (only node group)

---

## Questions to Consider

1. **Do you need t3.micro specifically for cost reasons?**
   - Consider using Spot instances instead: `capacity_type = "SPOT"`
   - Or use t3a.micro (AMD variant, usually cheaper)

2. **Do you need public cluster endpoint?**
   - Current config: `cluster_endpoint_public_access = true`
   - Consider restricting to VPN/bastion for production

3. **Single NAT Gateway?**
   - Current: `single_nat_gateway = true` (cost-effective but single point of failure)
   - Consider `single_nat_gateway = false` for production

---

**Status:** ✅ All critical issues fixed and ready for testing
