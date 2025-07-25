# Azure DevOps Pipeline Documentation

## Overview

This pipeline automates the build, test, security scanning, and deployment of a Node.js application to AWS EKS clusters using Helm. It includes environment-specific stages for Development and Test, with support for secure secret management and Docker-based deployments.

## Trigger Conditions

- **Branches:** `development`, `test`, `master`
- **Path filters:** `src/`, `helm/`
- **Batch:** `true` (to combine concurrent changes into a single run)

## Pipeline Stages

### 1. Build Stage (`build`)

- **Azure Key Vault:** Loads secrets from `keyvault-name-dev`
- **Node.js Setup:** Installs Node.js 18.x
- **Dependency Install:** Runs `npm ci`
- **Testing:** Runs `npm test`
- **Secret Scan:** Runs TruffleHog on `src/`
- **Build:** Runs `npm run build`
- **Docker Image Build:** Builds image with metadata
- **Docker Push:** Pushes image to Azure Container Registry (ACR)
- **Trivy Scan (optional):** Runs security scan on Docker image

### 2. Deploy to Dev (`deploy_dev`)

- **Condition:** Branch = `development` **OR** `deploy_dev = true`
- **Azure Key Vault:** Loads secrets from `keyvault-name-dev`
- **Token Replacement:** Replaces values in Helm config using `replacetokens@5`
- **AWS CLI:** Updates `kubeconfig` for target EKS cluster
- **Helm Upgrade:** Deploys app to Dev using `helm upgrade --install`

### 3. Deploy to Test (`deploy_test`)

- **Condition:** Branch = `test` **OR** `deploy_test = true`
- **Azure Key Vault:** Loads secrets from `keyvault-name-test`
- **Token Replacement:** Replaces values in Helm config using `replacetokens@5`
- **AWS CLI:** Updates `kubeconfig` for target EKS cluster
- **Helm Upgrade:** Deploys app to Test using `helm upgrade --install`

## Security Practices

- **Azure Key Vault:** Secure secret management
- **TruffleHog:** Prevents hardcoded secrets
- **Trivy:** Identifies Docker image vulnerabilities (`CRITICAL`, `HIGH`)
- **Token Replacement:** Dynamic injection of environment config
