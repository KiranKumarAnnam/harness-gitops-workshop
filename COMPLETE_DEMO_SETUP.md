# Complete CI/CD Demo Pipeline - Setup Guide

## Overview
This pipeline demonstrates the complete Harness CI/CD capabilities with:
- **CI**: Automated build on GitHub commits
- **DEV**: Auto-deploy on successful build
- **QA**: Auto-deploy after DEV success
- **PROD**: Manual approval with Canary or Blue/Green deployment
- **Rollback**: Automatic rollback on failure
- **GitOps**: Drift detection and sync (when enabled)

## Architecture Flow

```
GitHub Commit
    ↓
Build & Test (CI)
    ↓
Deploy to DEV (Auto)
    ↓
Deploy to QA (Auto)
    ↓
Production Approval ✋
    ↓
Deploy to PROD (Canary 25% → 50% → 100%)
    OR
Deploy to PROD (Blue/Green Swap)
```

## Prerequisites

### 1. Create Namespaces in OpenShift
```bash
oc create namespace podinfo-dev
oc create namespace podinfo-qa
oc create namespace podinfo-prod
```

### 2. Verify Delegate is Running
```bash
oc get pods -n gitness-demo | grep delegate
# Should show: kubernetes-delegate-xxx Running
```

### 3. Verify GitOps Agent (if enabled)
```bash
oc get pods -n gitness-demo | grep gitops
# Should show 6 pods running
```

## Setup Steps

### Step 1: Create Environments

**QA Environment:**
```bash
cd cli-manifests
# Apply QA environment
harness environment apply --file environment-qa.yaml
```

**Production Environment:**
```bash
# Apply Production environment
harness environment apply --file environment-prod.yaml
```

### Step 2: Create Infrastructure Definitions

**QA Infrastructure:**
```bash
harness infrastructure apply --file infrastructure-qa.yaml
```

**Production Infrastructure:**
```bash
harness infrastructure apply --file infrastructure-prod.yaml
```

### Step 3: Update Service with New Manifests

Update the `podinfo_service` to include both deployment strategies:

**Option 1: Via Harness UI**
1. Go to Services → `podinfo_service`
2. Click on "Manifests"
3. Add two manifest files:
   - `k8s-manifests/deployment-canary.yaml`
   - `k8s-manifests/deployment-bluegreen.yaml`
4. Add values files:
   - `k8s-manifests/values-dev.yaml`
   - `k8s-manifests/values-qa.yaml`
   - `k8s-manifests/values-prod.yaml`

**Option 2: Via CLI** (if available)
```bash
harness service update --identifier podinfo_service \
  --add-manifest k8s-manifests/deployment-canary.yaml \
  --add-manifest k8s-manifests/deployment-bluegreen.yaml \
  --add-values k8s-manifests/values-dev.yaml \
  --add-values k8s-manifests/values-qa.yaml \
  --add-values k8s-manifests/values-prod.yaml
```

### Step 4: Create the Pipeline

**Via Harness UI:**
1. Navigate to Pipelines
2. Click "Create Pipeline"
3. Choose "Import From Git" or "YAML"
4. Paste the content from `cli-manifests/complete-demo-pipeline.yaml`
5. Save the pipeline

**Via CLI** (if available):
```bash
harness pipeline apply --file cli-manifests/complete-demo-pipeline.yaml
```

## Running the Pipeline

### Test 1: Full Automated Flow (DEV + QA)
1. Make a code change in GitHub (or trigger manually)
2. Pipeline will:
   - ✅ Build Docker image
   - ✅ Deploy to DEV automatically
   - ✅ Deploy to QA automatically
   - ⏸️ Wait for Production approval

### Test 2: Canary Deployment to Production
1. When pipeline reaches Production approval:
   - Review the approval request
   - Approve for Production deployment
2. Pipeline will:
   - Deploy 25% canary
   - Wait for verification
   - Approve → Deploy 50% canary
   - Wait for verification
   - Approve → Deploy 100% (full rollout)

### Test 3: Blue/Green Deployment to Production
1. Set pipeline variable `deploymentStrategy = bluegreen`
2. Trigger pipeline
3. Pipeline will:
   - Deploy green environment (no traffic)
   - Verify green is healthy
   - Approve → Switch traffic to green
   - Blue remains for instant rollback

### Test 4: Test Rollback in QA
1. Manually introduce a failure in QA:
   ```bash
   oc scale deployment podinfo --replicas=0 -n podinfo-qa
   ```
2. Trigger pipeline
3. QA health check will fail
4. Automatic rollback will trigger
5. Verify rollback:
   ```bash
   oc rollout history deployment/podinfo -n podinfo-qa
   ```

### Test 5: Test Production Rollback (Canary)
1. During canary deployment, simulate failure:
   ```bash
   # During canary 25% phase
   oc delete pod -l app=podinfo,harness.io/track=canary -n podinfo-prod
   ```
2. Canary verification will fail
3. Automatic rollback will trigger
4. Production returns to previous stable version

### Test 6: Quick Blue/Green Rollback
1. After blue/green swap, if issues detected:
2. Click "Rollback" in Harness UI
3. Traffic instantly switches back to blue (old version)
4. Zero downtime rollback

## GitOps Integration (When Module Enabled)

### Create GitOps Application

**File: `cli-manifests/gitops-app-podinfo.yaml`**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: podinfo-gitops
  namespace: gitness-demo
spec:
  project: default
  source:
    repoURL: https://github.com/KiranKumarAnnam/harness-gitops-workshop
    targetRevision: main
    path: k8s-manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: podinfo-dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

Apply:
```bash
oc apply -f cli-manifests/gitops-app-podinfo.yaml
```

### Test GitOps Drift Detection
1. Manually change deployment:
   ```bash
   oc scale deployment podinfo --replicas=10 -n podinfo-dev
   ```
2. GitOps agent will detect drift
3. Auto-sync will restore to desired state (2 replicas)
4. View in Harness GitOps UI

## Monitoring and Verification

### Check Pipeline Execution
```bash
# Via UI: Pipelines → Complete CI/CD Demo Pipeline → Executions
```

### Check Deployments
```bash
# DEV
oc get pods -n podinfo-dev
oc get deployment podinfo -n podinfo-dev
oc get route podinfo -n podinfo-dev

# QA
oc get pods -n podinfo-qa
oc get deployment podinfo -n podinfo-qa
oc get route podinfo -n podinfo-qa

# Production
oc get pods -n podinfo-prod
oc get deployment podinfo -n podinfo-prod
oc get route podinfo -n podinfo-prod
```

### Check Rollout History
```bash
# View deployment history
oc rollout history deployment/podinfo -n podinfo-prod

# View specific revision
oc rollout history deployment/podinfo --revision=2 -n podinfo-prod
```

### Test Application
```bash
# Get route URL
ROUTE=$(oc get route podinfo -n podinfo-prod -o jsonpath='{.spec.host}')

# Test endpoints
curl http://$ROUTE/
curl http://$ROUTE/healthz
curl http://$ROUTE/readyz
curl http://$ROUTE/version
```

## Demo Script for Presentation

### Act 1: The Problem (Current State with Jenkins + Octopus)
**Show:**
- Jenkins dashboard (build only)
- Octopus Deploy dashboard (deployment only)
- Explain: Two separate tools, manual coordination, complex setup

### Act 2: The Solution (Harness Unified Platform)
**Show:**
- Harness pipeline YAML
- Highlight: Single pipeline, automated flow, built-in approvals

### Act 3: Live Demo - CI/CD Flow
1. **Make code change** in GitHub
2. **Watch pipeline execute:**
   - Build stage completes
   - DEV auto-deploys
   - QA auto-deploys
   - Production waits for approval
3. **Approve Production**
4. **Watch Canary deployment:**
   - 25% deployed
   - Metrics verified
   - 50% deployed
   - 100% complete

### Act 4: Advanced Features
1. **Show Rollback:**
   - Introduce failure
   - Automatic rollback triggers
   - Application restored

2. **Show Blue/Green:**
   - Explain zero-downtime
   - Show instant rollback capability

3. **Show GitOps (if enabled):**
   - Manually scale deployment
   - Show drift detection
   - Show auto-healing

### Act 5: ROI and Value
**Current State:**
- Jenkins license: $30K-$40K/year
- Octopus Deploy license: $60K-$80K/year  
- Maintenance: $95K-$100K/year
- **Total: $185K-$220K/year**

**With Harness:**
- Harness license: $75K/year
- Unified platform, less maintenance
- **Savings: $110K-$145K/year (60-66%)**

**Additional Benefits:**
- 40% faster deployments
- AI-powered error detection (AIDA)
- Built-in governance and compliance
- Progressive delivery (canary, blue/green)
- Automatic rollback
- Unified CI/CD/GitOps

## Troubleshooting

### Pipeline Fails at Build Stage
```bash
# Check Docker Hub credentials
harness connector test --identifier docker_hub_connector

# Check GitHub connectivity
harness connector test --identifier github_connector
```

### Deployment Fails (Namespace not found)
```bash
# Create missing namespace
oc create namespace <namespace-name>

# Verify namespace exists
oc get namespace
```

### Canary Pods Not Starting
```bash
# Check pod status
oc get pods -n podinfo-prod -l harness.io/track=canary

# Check pod logs
oc logs -n podinfo-prod -l harness.io/track=canary

# Check events
oc get events -n podinfo-prod --sort-by='.lastTimestamp'
```

### Rollback Not Working
```bash
# Check rollout history
oc rollout history deployment/podinfo -n <namespace>

# Manual rollback
oc rollout undo deployment/podinfo -n <namespace>

# Rollback to specific revision
oc rollout undo deployment/podinfo --to-revision=2 -n <namespace>
```

### GitOps Not Syncing
```bash
# Check GitOps agent pods
oc get pods -n gitness-demo | grep gitops

# Check application status
oc get application podinfo-gitops -n gitness-demo

# Force sync
oc patch application podinfo-gitops -n gitness-demo \
  --type merge -p '{"operation":{"sync":{}}}'
```

## Key Features Demonstrated

### ✅ Continuous Integration
- Automated builds on Git commits
- Docker image creation and push
- Unit and integration tests

### ✅ Continuous Deployment
- Multi-environment deployment (DEV/QA/PROD)
- Automated progression through environments
- Environment-specific configurations

### ✅ Approval Workflows
- Manual approval gates
- Role-based approvals
- Approval notifications

### ✅ Progressive Delivery
- Canary deployments (25% → 50% → 100%)
- Blue/Green deployments
- Traffic shifting

### ✅ Automatic Rollback
- Health check failures trigger rollback
- Instant rollback on any failure
- Maintains application stability

### ✅ GitOps (When Enabled)
- Drift detection
- Auto-healing
- Git as single source of truth

### ✅ Observability
- Pipeline execution history
- Deployment tracking
- Rollback history
- Email notifications

## Next Steps

1. ✅ Test all deployment scenarios
2. ✅ Practice demo flow (5-act structure)
3. ✅ Prepare backup plans for each test
4. ✅ Create comparison slides (Jenkins+Octopus vs Harness)
5. ✅ Test rollback scenarios multiple times
6. ✅ Verify GitOps when module enabled
7. ✅ Prepare ROI calculations with real numbers
8. ✅ Get approval workflows configured with actual users

## Success Criteria

- [ ] Pipeline builds successfully
- [ ] DEV deployment completes automatically
- [ ] QA deployment completes automatically
- [ ] Production approval workflow functions
- [ ] Canary deployment works (25% → 50% → 100%)
- [ ] Blue/Green deployment works
- [ ] Rollback works in all environments
- [ ] Health checks function correctly
- [ ] Email notifications sent
- [ ] GitOps drift detection works (if enabled)
- [ ] Can demonstrate end-to-end in < 15 minutes

## Contact and Support

- Harness Support: support@harness.io
- Documentation: https://docs.harness.io
- Community: https://community.harness.io
