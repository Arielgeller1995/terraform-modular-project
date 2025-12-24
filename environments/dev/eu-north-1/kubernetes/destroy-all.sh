#!/bin/bash
# Script to destroy all EKS resources to avoid charges
# Run this from the kubernetes directory

set -e

CLUSTER_NAME="dev-eks-cluster"
REGION="eu-north-1"

echo "=========================================="
echo "Destroying EKS Cluster and All Resources"
echo "Cluster: ${CLUSTER_NAME}"
echo "Region: ${REGION}"
echo "=========================================="
echo ""

# Step 1: Destroy node groups first (they depend on the cluster)
echo "Step 1: Checking for node groups..."
NODE_GROUPS=$(aws eks list-nodegroups --cluster-name ${CLUSTER_NAME} --region ${REGION} --query 'nodegroups[]' --output text 2>/dev/null || echo "")

if [ -n "$NODE_GROUPS" ]; then
  echo "Found node groups: $NODE_GROUPS"
  for NODE_GROUP in $NODE_GROUPS; do
    echo "  Deleting node group: $NODE_GROUP"
    aws eks delete-nodegroup --cluster-name ${CLUSTER_NAME} --nodegroup-name ${NODE_GROUP} --region ${REGION} || echo "  Failed to delete node group (may not exist)"
  done
  
  echo "Waiting for node groups to be deleted (this may take 5-10 minutes)..."
  for NODE_GROUP in $NODE_GROUPS; do
    aws eks wait nodegroup-deleted --cluster-name ${CLUSTER_NAME} --nodegroup-name ${NODE_GROUP} --region ${REGION} || echo "  Node group deletion completed or timed out"
  done
else
  echo "No node groups found"
fi
echo ""

# Step 2: Use Terraform destroy
echo "Step 2: Running Terraform destroy..."
echo "This will destroy:"
echo "  - EKS Cluster"
echo "  - Node Groups"
echo "  - IAM Roles"
echo "  - Security Groups"
echo "  - KMS Keys/Aliases"
echo "  - CloudWatch Log Groups"
echo ""

# First, try to refresh state
echo "Refreshing Terraform state..."
terraform refresh -input=false || echo "Refresh failed, continuing..."

# Destroy everything
echo "Running terraform destroy..."
terraform destroy -input=false -auto-approve

echo ""
echo "=========================================="
echo "Cleanup Complete!"
echo "=========================================="
echo ""
echo "Verifying resources are deleted..."

# Verify cluster is gone
if aws eks describe-cluster --name ${CLUSTER_NAME} --region ${REGION} 2>/dev/null; then
  echo "⚠ WARNING: Cluster still exists! Manual deletion may be needed."
else
  echo "✓ Cluster deleted successfully"
fi

# Check for remaining node groups
REMAINING_NODES=$(aws eks list-nodegroups --cluster-name ${CLUSTER_NAME} --region ${REGION} --query 'nodegroups[]' --output text 2>/dev/null || echo "")
if [ -n "$REMAINING_NODES" ]; then
  echo "⚠ WARNING: Node groups still exist: $REMAINING_NODES"
else
  echo "✓ All node groups deleted"
fi

echo ""
echo "Done! All resources should be destroyed."
