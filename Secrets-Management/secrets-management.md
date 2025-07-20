# External Secrets Operator Setup

## 1. Use Case for AWS Secrets Manager

Use AWS Secrets Manager to store secrets like:

- `myapp/db-password`
- `myapp/external-api-key`

This keeps secrets:
- Encrypted at rest  
- Auditable  
- Manageable via IAM  

---

## 2. Using External Secrets Operator (ESO) to Sync Secrets to Kubernetes

The External Secrets Operator automates pulling secrets from AWS Secrets Manager into Kubernetes Secret resources.

### Install ESO via Helm

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --create-namespace
```

---

## 3. AWS IAM Permissions for ESO

Attach the following IAM policy to the role used by ESO via Pod Identity in your EKS cluster:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-1:xxxxxxxxx:secret:myapp/*"
    }
  ]
}
```

---

## 4. Creating an ExternalSecret Manifest

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: myapp-secrets
  namespace: myapp-ns
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: myapp-env-secrets
    creationPolicy: Owner
  data:
    - secretKey: DB_PASSWORD
      remoteRef:
        key: myapp/db-password
    - secretKey: EXTERNAL_API_KEY
      remoteRef:
        key: myapp/external-api-key
```

---

## 5. Using the Synced Secret in Your Node.js Deployment

This injects the synced Kubernetes secret as environment variables:

```yaml
envFrom:
  - secretRef:
      name: myapp-env-secrets
```
