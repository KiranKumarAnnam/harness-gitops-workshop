# Complete CI/CD Pipeline with Helm Charts - Harness Setup Guide

## 🎯 Overview - Helm Chart Approach

This guide shows how to configure Harness to use **Helm charts** (like your organization does) instead of raw Kubernetes manifests.

---

## 📦 Understanding Manifests vs Helm Charts

### **Manifests (Plain YAML)**
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: podinfo
spec:
  replicas: 2  # Hardcoded
  template:
    spec:
      containers:
      - name: podinfo
        image: kannam/podinfo:latest  # Hardcoded
```

**Issues:**
- ❌ Hardcoded values
- ❌ Duplicate files per environment
- ❌ No templating
- ❌ Hard to manage across teams

### **Helm Charts (Templated)**
```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "podinfo.fullname" . }}
spec:
  replicas: {{ .Values.replicaCount }}  # From values file
  template:
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"  # From values
```

**Benefits:**
- ✅ Templated and reusable
- ✅ Environment-specific values files
- ✅ Shared libraries (helpers)
- ✅ Package and version management
- ✅ Industry standard

---

## 🏢 Your Organization's Typical Setup

```
shared-helm-charts-repo/           # Shared library repo
├── library-charts/
│   ├── common/                    # Common templates
│   │   ├── _deployment.tpl
│   │   ├── _service.tpl
│   │   └── _ingress.tpl
│   └── monitoring/
│       └── _prometheus.tpl
└── Chart.yaml

service-repo/                       # Your microservice repo
├── src/                           # Application code
├── helm/
│   ├── Chart.yaml
│   ├── values.yaml                # Default values
│   ├── values/
│   │   ├── dev.yaml              # DEV overrides
│   │   ├── qa.yaml               # QA overrides
│   │   ├── uat.yaml              # UAT overrides
│   │   └── prod.yaml             # PROD overrides
│   └── templates/
│       ├── deployment.yaml        # Uses shared library templates
│       ├── service.yaml
│       └── _helpers.tpl
└── Jenkinsfile                    # Currently in Jenkins
```

---

## 🚀 Configure Harness for Helm (Step-by-Step)

### **Step 1: Update Service to Use Helm Chart**

1. **Navigate to Services:**
   - Go to **Services** → **podinfo_service**
   - Click **Configuration** → **Manifests**

2. **Add Helm Chart:**
   - Click **+ Add Manifest**
   - Select **Manifest Type: Helm Chart**
   
3. **Configure:**
   ```
   Manifest Identifier: podinfo_helm_chart
   Manifest Source: Github
   Git Connector: github_connector
   Branch: main
   Chart Path: apps/podinfo/charts/podinfo
   Helm Version: V3
   
   Values Files:
   - apps/podinfo/charts/podinfo/values/dev.yaml
   - apps/podinfo/charts/podinfo/values/prod.yaml
   - apps/podinfo/charts/podinfo/values/production.yaml
   
   Command Flags:
   --set image.tag=<+artifact.tag>
   --set image.repository=kannam/podinfo
   ```

### **Step 2: Test Helm Chart Locally**

```powershell
# Navigate to chart directory
cd apps/podinfo/charts/podinfo

# Test rendering
helm template podinfo . --values values/dev.yaml `
  --set image.repository=kannam/podinfo `
  --set image.tag=latest

# Dry-run deployment
helm upgrade --install podinfo . `
  --namespace podinfo-dev `
  --values values/dev.yaml `
  --set image.repository=kannam/podinfo `
  --set image.tag=latest `
  --dry-run --debug
```

---

## 📊 Jenkins vs Harness with Helm

### **Current Jenkins (Shell Scripts):**
```groovy
stage('Deploy to DEV') {
    steps {
        sh """
            helm upgrade --install podinfo ./helm \
              --namespace dev \
              --values helm/values/dev.yaml \
              --set image.tag=${BUILD_NUMBER} \
              --wait --timeout 5m
        """
    }
}
```

### **Harness (Declarative):**
```yaml
- step:
    type: K8sRollingDeploy  # Harness detects Helm automatically!
    name: Deploy to DEV
    # No shell scripts needed!
```

**Harness automatically runs:**
```bash
helm upgrade --install podinfo ./chart \
  --namespace podinfo-dev \
  --values values/dev.yaml \
  --set image.tag=<from-artifact> \
  --wait
```

---

## 🔐 Connecting to Nexus Helm Repository

If your org stores charts in Nexus:

**Create Connector:**
```
Connectors → + New Connector → HTTP Helm Repo

Name: Nexus Helm Repository
URL: https://nexus.company.com/repository/helm/
Authentication: Username + Token
```

**In Service:**
```yaml
manifests:
  - manifest:
      type: HelmChart
      spec:
        store:
          type: Http
          spec:
            connectorRef: nexus_helm_repository
        chartName: podinfo
        chartVersion: 1.0.0
```

---

## ✅ Quick Action Items

### **Commit New Values Files:**
```powershell
cd c:\Users\kiran.annam\PycharmProjects\harness\gitness_demo\harness-gitops-workshop

git add apps/podinfo/charts/podinfo/values/
git commit -m "Add environment-specific Helm values (dev, qa, prod)"
git push origin main
```

### **Update Harness Service:**
1. Remove raw manifest files (if added)
2. Add Helm chart manifest (see Step 1 above)
3. Save service

### **Test Pipeline:**
- Pipeline works exactly the same
- Harness detects Helm and uses `helm upgrade --install`
- Canary/blue-green work automatically with Helm

---

## 🎉 Summary

| Feature | Raw Manifests | Helm Charts |
|---------|---------------|-------------|
| **Templating** | ❌ | ✅ |
| **Reusability** | ❌ | ✅ |
| **Shared Libraries** | ❌ | ✅ |
| **Rollback** | Manual | `helm rollback` |
| **Org Standard** | ❌ | ✅ |

**Your organization already uses Helm with Jenkins. Harness works the same way, just better!** 🚀
