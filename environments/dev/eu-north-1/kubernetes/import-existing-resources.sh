#!/bin/bash
# Script to import existing EKS resources into Terraform state
# These resources were created in a previous partial apply attempt
# Run this from the kubernetes directory after 'terraform init'

# Don't exit on error - we want to continue even if one import fails
set +e

CLUSTER_NAME="dev-eks-cluster"

echo "Importing existing EKS resources into Terraform state..."
echo "Cluster name: ${CLUSTER_NAME}"
echo ""

# Import KMS alias
echo "Step 1: Importing KMS alias..."
KMS_ALIAS_NAME="alias/eks/${CLUSTER_NAME}"
if terraform import -input=false "module.eks.module.kms.aws_kms_alias.this[\"cluster\"]" "${KMS_ALIAS_NAME}" 2>&1; then
  echo "✓ KMS alias imported successfully"
else
  echo "⚠ KMS alias import failed (may already be imported or resource doesn't exist)"
fi
echo ""

# Import CloudWatch log group
echo "Step 2: Importing CloudWatch log group..."
LOG_GROUP_NAME="/aws/eks/${CLUSTER_NAME}/cluster"
if terraform import -input=false "module.eks.aws_cloudwatch_log_group.this[0]" "${LOG_GROUP_NAME}" 2>&1; then
  echo "✓ CloudWatch log group imported successfully"
else
  echo "⚠ CloudWatch log group import failed (may already be imported or resource doesn't exist)"
fi
echo ""

echo "Import process complete!"
echo "Next steps:"
echo "  1. Run 'terraform plan' to verify the state is correct"
echo "  2. If plan looks good, run 'terraform apply' to continue"
