#!/bin/bash
# Script to destroy all networking resources to avoid charges
# Run this from the networking directory

set -e

REGION="eu-north-1"

echo "=========================================="
echo "Destroying Networking Resources"
echo "Region: ${REGION}"
echo "=========================================="
echo ""
echo "This will destroy:"
echo "  - VPC"
echo "  - Subnets (public and private)"
echo "  - NAT Gateway (main cost driver!)"
echo "  - Internet Gateway"
echo "  - Route Tables"
echo "  - Security Groups"
echo ""
echo "⚠ WARNING: This will destroy ALL networking resources!"
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

# Refresh state first
echo "Refreshing Terraform state..."
terraform refresh -input=false || echo "Refresh failed, continuing..."

# Destroy everything
echo "Running terraform destroy..."
terraform destroy -input=false -auto-approve

echo ""
echo "=========================================="
echo "Networking Resources Destroyed!"
echo "=========================================="
echo ""
echo "✓ All networking resources have been destroyed"
echo "✓ NAT Gateway charges will stop immediately"
