#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-starttech-cluster}"
AWS_REGION="${AWS_REGION:-us-east-1}"

aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION"
kubectl rollout undo deployment/backend-api
kubectl rollout status deployment/backend-api --timeout=300s
