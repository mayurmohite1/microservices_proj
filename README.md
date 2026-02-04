# Expense Tracker — End-to-End DevOps Deployment

This repository contains an example microservices project (Expense Tracker) and complete DevOps infrastructure to deploy it into a Kubernetes cluster. It includes source for the frontend, backend, MongoDB, and Redis, plus Terraform configurations, Kubernetes manifests, and monitoring stacks.

Repository structure (high level):
- **`backend/`**: Node backend service (API, controllers, models, services).
- **`frontend/`**: Next.js frontend application.
- **`kubernetes/`**: Kubernetes manifests for backend, frontend, mongodb, redis, ingress and cluster helpers.
- **`terraform/`**: Terraform modules and root configs for provisioning cloud infrastructure.

## Table of contents
- Project overview
- Quick start (local / test cluster)
- Terraform (provisioning)
- Kubernetes (deploy manifests)
- Monitoring (Prometheus & Grafana)
- Frontend notes
- Useful commands
- Where to find more

## Project overview

This project demonstrates deploying a small, scalable microservices application composed of:
- A Node.js backend
- A Next.js frontend
- MongoDB for persistence
- Redis for caching

The delivery pipeline is intended for AWS EKS but the manifests can be applied to any conformant Kubernetes cluster (Minikube, kind, etc.) for testing.

## Quick start (test / dev)

Prerequisites:
- `kubectl` configured to target your cluster (Minikube, kind, or EKS)
- `docker` (for building images locally if needed)

1) Apply Kubernetes manifests:

```bash
cd kubernetes
kubectl apply -f .
```

This will create the namespaces, storage class, and the included services for `redis`, `mongodb`, `backend` and `frontend`.

2) Check resources:

```bash
kubectl get pods --namespace=development
kubectl get svc --namespace=development
```

Tip: set `NEXT_PUBLIC_API_URL` in the frontend config map to the backend service external IP or DNS.

## Terraform — Infrastructure as Code

Terraform configs live under `terraform/` and are used to provision shared resources and EKS infrastructure.

- Storage state (S3 & DynamoDB): `terraform/s3bucket_dynamo`
- Project infrastructure (VPC, EKS, controllers): `terraform/project_infrastructure`

Basic steps:

```bash
cd terraform/s3bucket_dynamo
terraform init
terraform plan
terraform apply --auto-approve

cd ../project_infrastructure
terraform init
terraform plan
terraform apply --auto-approve
```

Notes:
- Ensure `helm` is installed prior to running the project_infrastructure apply, as some addons are deployed via Helm.
- The `project_infrastructure` configuration installs controllers (ingress, storage) and a `monitoring` namespace with Prometheus & Grafana.

## Kubernetes manifests

After Terraform (if using EKS), run:

```bash
kubectl apply -f kubernetes
```

Walkthrough of deploy order (recommended for manual testing):
1. Create namespace: `kubectl apply -f kubernetes/namespace.yml`
2. Redis: `kubectl apply -f kubernetes/redis/`
3. MongoDB: `kubectl apply -f kubernetes/mongodb/`
4. Backend: `kubectl apply -f kubernetes/backend/`
5. Set `NEXT_PUBLIC_API_URL` value in `kubernetes/frontend/10_config_map.yml` to point to backend service
6. Frontend: `kubectl apply -f kubernetes/frontend/`

Useful commands:

```bash
kubectl get pods --namespace=development
kubectl get services --namespace=development
kubectl get svc -n monitoring
```

## Monitoring (Prometheus & Grafana)

Prometheus and Grafana are installed into the `monitoring` namespace (when using the provided Terraform + Helm setup).

To find where Grafana and Prometheus are reachable:

```bash
kubectl get svc -n monitoring
```

- The Grafana default login: `admin` / `prom-operator` (change after first login).
- Recommended dashboard to import: EKS dashboard ID 17119 (https://grafana.com/grafana/dashboards/17119-kubernetes-eks-cluster-prometheus/)
