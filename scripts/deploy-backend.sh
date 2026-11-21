#!/usr/bin/env bash
set -euo pipefail

# Required env var: REDIS_HOST. Optional: AWS_REGION, CLUSTER_NAME
: "${REDIS_HOST:?REDIS_HOST is required}"
AWS_REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${CLUSTER_NAME:-starttech-cluster}"
REPO="starttech-backend-api"

cd "$(dirname "$0")/.."

ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="$ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com"
TAG=$(git rev-parse --short HEAD)

aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$REGISTRY"
docker build --platform linux/amd64 -t "$REGISTRY/$REPO:$TAG" backend
docker push "$REGISTRY/$REPO:$TAG"

aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION"

sed "s|ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com|$REGISTRY|; s|IMAGE_TAG|$TAG|; s|REDIS_HOST_PLACEHOLDER|$REDIS_HOST|" k8s/deployment.yaml | kubectl apply -f -
kubectl apply -f k8s/service.yaml -f k8s/ingress.yaml
kubectl rollout status deployment/backend-api --timeout=300s
