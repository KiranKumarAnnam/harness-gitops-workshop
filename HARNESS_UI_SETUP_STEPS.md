# Harness UI Setup Steps - Complete Guide

## 🎯 Overview

You need to complete these steps in Harness UI to run your complete CI/CD pipeline:

1. ✅ **Already Done**: DEV environment, podinfo service, connectors
2. 🔧 **To Do**: Create QA & PROD environments, update service manifests, import new pipeline

---

## 📋 Step-by-Step Instructions

### **Step 1: Create QA Environment** (5 minutes)

1. **Navigate to Environments:**
   - Click on **"Environments"** in left sidebar
   - Click **"+ New Environment"**

2. **Fill in QA Environment Details:**
   ```
   Name: QA Environment
   Identifier: qa_environment
   Description: QA testing environment
   Environment Type: Pre-Production
   Tags: 
     - env: qa
     - type: non-production
   ```

3. **Add Variables** (click "Add Variable"):
   ```
   Variable 1:
   Name: namespace
   Type: String
   Value: podinfo-qa
   Description: Kubernetes namespace for QA
   
   Variable 2:
   Name: replicas
   Type: String
   Value: 3
   Description: Number of replicas for QA
   ```

4. **Save Environment**

---

### **Step 2: Create QA Infrastructure** (3 minutes)

1. **Inside QA Environment:**
   - Click **"Infrastructure Definitions"** tab
   - Click **"+ New Infrastructure"**

2. **Fill in Details:**
   ```
   Name: OpenShift QA Infrastructure
   Identifier: openshift_qa_infra
   Deployment Type: Kubernetes
   ```

3. **Configure Infrastructure:**
   ```
   Infrastructure Type: Kubernetes Direct
   Connector: Select your Kubernetes delegate connector
   Namespace: podinfo-qa
   Release Name: release-<+INFRA_KEY_SHORT_ID>
   ```

4. **Save Infrastructure**

---

### **Step 3: Create Production Environment** (5 minutes)

1. **Navigate to Environments:**
   - Click **"+ New Environment"**

2. **Fill in Production Details:**
   ```
   Name: Production Environment
   Identifier: prod_environment
   Description: Production environment with enhanced monitoring
   Environment Type: Production
   Tags:
     - env: production
     - type: production
     - criticality: high
   ```

3. **Add Variables:**
   ```
   Variable 1:
   Name: namespace
   Type: String
   Value: podinfo-prod
   Description: Kubernetes namespace for Production
   
   Variable 2:
   Name: replicas
   Type: String
   Value: 4
   Description: Number of replicas for Production
   
   Variable 3:
   Name: require_approval
   Type: String
   Value: true
   Description: Require manual approval for deployments
   ```

4. **Save Environment**

---

### **Step 4: Create Production Infrastructure** (3 minutes)

1. **Inside Production Environment:**
   - Click **"Infrastructure Definitions"** tab
   - Click **"+ New Infrastructure"**

2. **Fill in Details:**
   ```
   Name: OpenShift Production Infrastructure
   Identifier: openshift_prod_infra
   Deployment Type: Kubernetes
   ```

3. **Configure Infrastructure:**
   ```
   Infrastructure Type: Kubernetes Direct
   Connector: Select your Kubernetes delegate connector
   Namespace: podinfo-prod
   Release Name: release-<+INFRA_KEY_SHORT_ID>
   ```

4. **Save Infrastructure**

---

### **Step 5: Update podinfo_service with New Manifests** (10 minutes)

#### **5a. Add Canary Deployment Manifest**

1. **Navigate to Services:**
   - Click **"Services"** in left sidebar
   - Find and click **"podinfo_service"** (or your existing service)

2. **Go to Manifests Tab:**
   - Click **"Configuration"** → **"Manifests"**
   - Click **"+ Add Manifest"**

3. **Add Canary Deployment:**
   ```
   Manifest Type: K8s Manifest
   Manifest Identifier: deployment_canary
   Manifest Source: Github
   
   Git Connector: github_connector (your existing connector)
   Repository: harness-gitops-workshop
   Branch: main
   File Path: k8s-manifests/deployment-canary.yaml
   ```

4. **Save Manifest**

#### **5b. Add Blue-Green Deployment Manifest**

1. **Click "+ Add Manifest"** again

2. **Add Blue-Green Deployment:**
   ```
   Manifest Type: K8s Manifest
   Manifest Identifier: deployment_bluegreen
   Manifest Source: Github
   
   Git Connector: github_connector
   Repository: harness-gitops-workshop
   Branch: main
   File Path: k8s-manifests/deployment-bluegreen.yaml
   ```

3. **Save Manifest**

#### **5c. Add Values Files**

1. **Click "Values.yaml" tab** (in Manifests section)

2. **Add DEV values:**
   ```
   Click "+ Add Values"
   
   Values Identifier: values_dev
   Values Source: Github
   Git Connector: github_connector
   Branch: main
   File Path: k8s-manifests/values-dev.yaml
   ```

3. **Add QA values:**
   ```
   Click "+ Add Values"
   
   Values Identifier: values_qa
   Values Source: Github
   Branch: main
   File Path: k8s-manifests/values-qa.yaml
   ```

4. **Add PROD values:**
   ```
   Click "+ Add Values"
   
   Values Identifier: values_prod
   Values Source: Github
   Branch: main
   File Path: k8s-manifests/values-prod.yaml
   ```

5. **Save Service**

---

### **Step 6: Update Artifact Configuration** (5 minutes)

1. **In podinfo_service, go to "Artifacts" section**

2. **Edit Primary Artifact:**
   ```
   Artifact Source: Docker Registry
   Artifact Identifier: podinfo_docker
   Docker Registry: docker_hub_connector
   Image Path: kannam/podinfo
   Tag: <+input>
   
   IMPORTANT: Change this to allow pipeline to specify tag
   ```

3. **Save Artifact Configuration**

---

### **Step 7: Create the Complete Demo Pipeline** (10 minutes)

1. **Navigate to Pipelines:**
   - Click **"Pipelines"** in left sidebar
   - Click **"+ Create a Pipeline"**

2. **Pipeline Setup:**
   ```
   Name: Complete CI/CD Demo Pipeline
   Setup: Start from scratch
   ```

3. **Switch to YAML View:**
   - Click on **"YAML"** button (top right)
   - Click **"Edit YAML"**

4. **Copy Pipeline YAML:**
   - Open file: `cli-manifests/complete-demo-pipeline.yaml`
   - Copy the ENTIRE contents
   - Paste into Harness YAML editor

5. **Save Pipeline**

6. **Validate:**
   - Check for any red errors
   - If there are connector reference errors, update them to match your actual connector identifiers

---

### **Step 8: Create OpenShift Namespaces** (5 minutes)

**In your terminal (PowerShell):**

```powershell
# Login to OpenShift (if not already)
oc login <your-cluster-url>

# Create QA namespace
oc create namespace podinfo-qa

# Create Production namespace
oc create namespace podinfo-prod

# Verify all namespaces exist
oc get namespace | Select-String "podinfo"
```

**Expected output:**
```
podinfo-dev    Active   Xd
podinfo-qa     Active   0m
podinfo-prod   Active   0m
```

---

### **Step 9: Run Your First Complete Pipeline** (30 minutes)

1. **Open Pipeline:**
   - Go to **Pipelines** → **Complete CI/CD Demo Pipeline**
   - Click **"Run"**

2. **Configure Run:**
   ```
   Branch: main
   Deployment Strategy: canary (default)
   ```

3. **Click "Run Pipeline"**

4. **Watch Execution:**
   - ✅ Build Stage - ~5 minutes
   - ✅ Deploy to DEV - ~3 minutes (automatic)
   - ✅ Deploy to QA - ~3 minutes (automatic)
   - ⏸️ **Production Approval** - WAITING FOR YOU

5. **Monitor in Terminal:**
   ```powershell
   # Watch DEV deployment
   oc get pods -n podinfo-dev -w
   
   # Watch QA deployment
   oc get pods -n podinfo-qa -w
   
   # Watch PROD deployment
   oc get pods -n podinfo-prod -w
   ```

6. **When Pipeline Reaches Production Approval:**
   - Review the approval request in Harness UI
   - Add a comment: "Approved for production deployment"
   - Click **"Approve"**

7. **Watch Canary Deployment:**
   - ✅ 25% canary deployed
   - ⏸️ Verify metrics (automatic)
   - ⏸️ Approve 50% (you'll approve)
   - ✅ 50% canary deployed
   - ⏸️ Verify metrics (automatic)
   - ⏸️ Approve 100% (you'll approve)
   - ✅ Full rollout complete!

---

## 🔍 Verification Steps

### **After Pipeline Completes:**

```powershell
# Check all deployments
oc get deployments -n podinfo-dev
oc get deployments -n podinfo-qa
oc get deployments -n podinfo-prod

# Check all pods
oc get pods -n podinfo-dev
oc get pods -n podinfo-qa
oc get pods -n podinfo-prod

# Check routes (if created)
oc get routes -n podinfo-dev
oc get routes -n podinfo-qa
oc get routes -n podinfo-prod

# Test application (replace with your route)
$DEV_ROUTE = (oc get route podinfo -n podinfo-dev -o jsonpath='{.spec.host}')
Invoke-WebRequest -Uri "http://$DEV_ROUTE/healthz" -UseBasicParsing
```

---

## ⚠️ Common Issues & Fixes

### **Issue 1: Service Not Found**
**Error:** "Service podinfo_service not found"
**Fix:** Update pipeline YAML with your actual service identifier:
```yaml
serviceRef: podinfo_service  # Change to your actual service ID
```

### **Issue 2: Environment Not Found**
**Error:** "Environment qa_environment not found"
**Fix:** Ensure you created the environments with exact identifiers:
- `qa_environment`
- `prod_environment`
- `dev_environment` (should already exist)

### **Issue 3: Infrastructure Not Found**
**Error:** "Infrastructure openshift_qa_infra not found"
**Fix:** Ensure infrastructure definitions created with exact identifiers:
- `openshift_qa_infra`
- `openshift_prod_infra`
- `openshift_dev_infra` (should already exist)

### **Issue 4: Connector Errors**
**Error:** "Connector docker_hub_connector not found"
**Fix:** Update pipeline YAML to match your actual connector identifiers

### **Issue 5: Namespace Not Found**
**Error:** "namespace 'podinfo-qa' not found"
**Fix:** Run the namespace creation commands from Step 8

### **Issue 6: Manifest Not Found**
**Error:** "Path k8s-manifests/deployment-canary.yaml not found"
**Fix:** Ensure all manifest files are committed and pushed to GitHub:
```powershell
cd c:\Users\kiran.annam\PycharmProjects\harness\gitness_demo\harness-gitops-workshop
git add k8s-manifests/
git commit -m "Add canary and blue-green manifests"
git push origin main
```

---

## 📊 What to Expect

### **Timeline:**
```
00:00 - Pipeline triggered
00:05 - Build complete, deploying to DEV
00:08 - DEV deployment complete, deploying to QA
00:11 - QA deployment complete, waiting for PROD approval
[MANUAL APPROVAL]
00:15 - Canary 25% deployed
00:18 - Canary 25% verified, waiting for approval
[MANUAL APPROVAL]
00:20 - Canary 50% deployed
00:23 - Canary 50% verified, waiting for approval
[MANUAL APPROVAL]
00:25 - Full rollout complete!
```

### **Pod Counts:**
- DEV: 2 replicas
- QA: 3 replicas
- PROD: 4 replicas (after full canary rollout)

---

## 🎯 Quick Checklist

Before running pipeline:
- [ ] QA environment created with identifier `qa_environment`
- [ ] QA infrastructure created with identifier `openshift_qa_infra`
- [ ] PROD environment created with identifier `prod_environment`
- [ ] PROD infrastructure created with identifier `openshift_prod_infra`
- [ ] Service updated with canary and blue-green manifests
- [ ] Service updated with values files (dev, qa, prod)
- [ ] Pipeline imported and saved
- [ ] Namespaces created in OpenShift (podinfo-qa, podinfo-prod)
- [ ] All manifest files pushed to GitHub
- [ ] Connectors tested and working

---

## 🚀 After Successful Run

### **Test Additional Scenarios:**

1. **Test Rollback in QA:**
   ```powershell
   # Scale down QA to trigger failure
   oc scale deployment podinfo --replicas=0 -n podinfo-qa
   
   # Trigger pipeline again - watch automatic rollback
   ```

2. **Test Blue-Green Deployment:**
   - Edit pipeline variable: `deploymentStrategy = bluegreen`
   - Run pipeline
   - Watch blue-green swap in action

3. **Test GitOps (when module enabled):**
   ```powershell
   # Apply GitOps application
   oc apply -f cli-manifests/gitops-app-podinfo.yaml
   
   # Create drift
   oc scale deployment podinfo --replicas=10 -n podinfo-dev
   
   # Watch auto-healing
   oc get pods -n podinfo-dev -w
   ```

---

## 📞 Need Help?

If you encounter issues:
1. Check Harness execution logs for detailed error messages
2. Verify all identifiers match exactly (case-sensitive)
3. Ensure GitHub files are committed and pushed
4. Check OpenShift namespace permissions
5. Verify connectors are connected and working

**Remember:** The documentation files (`IMPLEMENTATION_SUMMARY.md`, `COMPLETE_DEMO_SETUP.md`) have detailed troubleshooting sections!

---

## ✅ Success Indicators

You'll know everything is working when:
- ✅ Pipeline builds Docker image successfully
- ✅ DEV deployment completes automatically
- ✅ QA deployment completes automatically
- ✅ Production approval appears
- ✅ Canary deployment progresses through 25%→50%→100%
- ✅ All pods are running in all namespaces
- ✅ Applications are accessible via routes

**Good luck! You're minutes away from a complete end-to-end demo! 🎉**
