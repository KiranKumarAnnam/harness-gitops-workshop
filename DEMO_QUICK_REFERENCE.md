# Quick Demo Reference - Complete CI/CD Pipeline

## 🚀 Quick Start Commands

### Setup (Run Once)
```bash
# Login to OpenShift
oc login <your-cluster-url>

# Run setup script
cd shell-scripts
bash setup-demo-environment.sh
```

## 📋 Pre-Demo Checklist

- [ ] All namespaces created: `oc get ns | grep podinfo`
- [ ] Delegate connected: `oc get pods -n gitness-demo | grep delegate`
- [ ] Environments created in Harness (QA, PROD)
- [ ] Infrastructure definitions created
- [ ] Pipeline imported and saved
- [ ] Docker Hub and GitHub connectors tested
- [ ] Have terminal window ready with oc commands
- [ ] Have Harness UI open on Pipelines page

## 🎬 Demo Flow (15 minutes)

### Part 1: The Problem (2 min)
**Show Jenkins + Octopus screenshots**
- "Currently using Jenkins for CI, Octopus for CD"
- "Two separate tools, manual coordination"
- "Complex setup, high maintenance"
- "Total cost: $185K-$220K/year"

### Part 2: The Solution (3 min)
**Show Harness Pipeline YAML**
```yaml
# Highlight these sections:
- Build Stage (CI)
- DEV Deployment (Auto)
- QA Deployment (Auto)
- PROD Approval + Canary
- Automatic Rollback
```

**Key points:**
- ✅ Single unified platform
- ✅ Automated multi-environment flow
- ✅ Built-in approvals and governance
- ✅ Progressive delivery (canary/blue-green)
- ✅ AI-powered error detection
- ✅ Cost: $75K/year (60% savings)

### Part 3: Live Demo - Full Pipeline (5 min)

**Trigger Pipeline:**
1. Click "Run Pipeline"
2. Select branch: `main`
3. Click "Run"

**Watch Execution:**
```bash
# In terminal, monitor deployments
watch -n 2 'oc get pods -n podinfo-dev && echo "---" && oc get pods -n podinfo-qa'
```

**Narrate:**
- ✅ "Build stage running - compiling and testing code"
- ✅ "Build complete - Docker image pushed to registry"
- ✅ "Deploying to DEV automatically..."
- ✅ "DEV healthy - auto-promoting to QA..."
- ✅ "QA deployment complete - waiting for production approval"

### Part 4: Production Deployment with Canary (3 min)

**Approve Production:**
1. Click "Approve" on Production Approval step
2. Add comment: "Approved for production deployment"

**Watch Canary Rollout:**
```bash
# Monitor canary deployment
watch -n 2 'oc get pods -n podinfo-prod -L harness.io/track'
```

**Narrate:**
- ✅ "Deploying canary - 25% of traffic"
- ✅ "Health checks passing - metrics look good"
- ⏸️ "Pausing for approval before 50%"
- (Approve) ✅ "Scaling to 50%"
- (Approve) ✅ "Full rollout complete - 100%"

### Part 5: Demonstrate Rollback (2 min)

**Option A: Simulate QA Failure**
```bash
# Scale down QA deployment
oc scale deployment podinfo --replicas=0 -n podinfo-qa

# Re-trigger pipeline
# Watch automatic rollback when health check fails
```

**Option B: Manual Production Rollback**
```bash
# Show rollout history
oc rollout history deployment/podinfo -n podinfo-prod

# In Harness UI, click "Rollback"
# Or via CLI:
oc rollout undo deployment/podinfo -n podinfo-prod
```

**Narrate:**
- ❌ "Deployment detected unhealthy state"
- 🔄 "Automatic rollback triggered"
- ✅ "Application restored to previous stable version"
- ⏱️ "Total downtime: < 30 seconds"

## 🎯 Key Demo Talking Points

### During Build Stage
> "This is our CI phase - similar to your Jenkins pipeline, but fully integrated. We're running Go tests, building the Docker image, and pushing to your registry. Notice how AIDA (Harness AI) is monitoring for any issues."

### During DEV Deployment
> "DEV deployment is fully automated - no human intervention needed. This replaces your Jenkins deployment scripts. We're doing health checks, smoke tests, and if anything fails, automatic rollback kicks in."

### During QA Deployment
> "QA also auto-deploys when DEV succeeds. This is where you'd run your integration tests. Notice we have automated test steps built right into the pipeline."

### At Production Approval
> "Now we hit the approval gate - this is your governance checkpoint. In Octopus, you manually click 'Deploy' for each environment. Here, we have proper approval workflows with audit trails."

### During Canary Deployment
> "This is progressive delivery - something Octopus doesn't offer. We're gradually shifting traffic: 25%, then 50%, then 100%. At each stage, we verify metrics. If anything looks wrong, instant rollback. This is how Netflix and Amazon deploy to production."

### During Rollback Demo
> "Watch this - I'm simulating a failure. Harness detects it immediately and triggers automatic rollback. Your application is back to the stable version in seconds. No manual intervention, no war room, no panic."

## 📊 ROI Comparison

### Current State (Jenkins + Octopus)
| Component | Annual Cost |
|-----------|-------------|
| Jenkins License | $30K-$40K |
| Octopus Deploy License | $60K-$80K |
| Maintenance (2 FTE × 50%) | $95K-$100K |
| **Total** | **$185K-$220K** |

### With Harness
| Component | Annual Cost |
|-----------|-------------|
| Harness Platform | $75K |
| Maintenance (reduced) | Included |
| **Total** | **$75K** |
| **Savings** | **$110K-$145K (60-66%)** |

### Additional Benefits
- ⏱️ **40% faster deployments** (minutes vs hours)
- 🤖 **AI-powered error detection** (AIDA)
- 🔒 **Built-in governance** (audit trails, approvals)
- 📈 **Progressive delivery** (canary, blue-green)
- 🔄 **Automatic rollback** (< 30 seconds)
- 🎯 **Unified platform** (CI + CD + GitOps)

## 🔧 Troubleshooting During Demo

### Pipeline Stuck at Build
```bash
# Check connector
harness connector test --identifier docker_hub_connector
```

### Deployment Fails
```bash
# Check namespace
oc get namespace podinfo-dev

# Check pods
oc get pods -n podinfo-dev

# Check events
oc get events -n podinfo-dev --sort-by='.lastTimestamp' | tail -20
```

### Approval Not Showing
- Check you're in the "Execution Details" view
- Refresh the page
- Check notification email

### Canary Pods Not Starting
```bash
# Check canary pods
oc get pods -n podinfo-prod -l harness.io/track=canary

# Check logs
oc logs -l harness.io/track=canary -n podinfo-prod

# Check deployment
oc describe deployment podinfo -n podinfo-prod
```

## 🎤 Backup Talking Points (if demo fails)

### If Build Fails
> "This is actually perfect - let me show you AIDA, our AI assistant. Watch how it analyzes the error and suggests a fix. Compare this to spending 30 minutes digging through Jenkins logs."

### If Deployment Fails
> "Great example of automatic rollback in action. The deployment detected an issue and rolled back automatically. With Octopus, you'd be manually coordinating the rollback across multiple screens."

### If Live Demo Completely Fails
> "Let me show you a recorded run from yesterday..." (have screenshots/video ready)
> OR
> "Let's look at the pipeline definition and I'll walk through what would happen..."

## 📝 Post-Demo Discussion Points

### Expected Questions

**Q: "How does this work with our on-prem Bitbucket?"**
A: "Harness has native Bitbucket connectors. We'd create a connector pointing to your Bitbucket server, just like we did with GitHub. Same for your Nexus artifactory - native integration."

**Q: "Can we customize the approval workflow?"**
A: "Absolutely. You can configure multi-level approvals, require specific users or groups, add custom approval criteria, integrate with ServiceNow or Jira for change tickets."

**Q: "What about our 20+ microservices?"**
A: "You'd create a pipeline template with all these stages, then each microservice gets its own pipeline based on that template. Change the template once, all 20 pipelines update automatically."

**Q: "How long to migrate from Jenkins + Octopus?"**
A: "Typical migration takes 4-6 weeks for 20 microservices. We'd start with 2-3 pilot services, prove it works, then roll out to the rest. Harness Professional Services can help accelerate this."

**Q: "What about our existing Jenkins pipelines?"**
A: "We can import your Jenkinsfiles and auto-convert them to Harness pipelines. Not 100% automatic, but gets you 70-80% of the way there. Plus, you can run Jenkins and Harness side-by-side during migration."

## ✅ Success Criteria

After demo, the audience should understand:
- ✅ Harness unifies CI and CD (replaces Jenkins + Octopus)
- ✅ Automated multi-environment deployments
- ✅ Progressive delivery reduces production risk
- ✅ Automatic rollback prevents outages
- ✅ 60-66% cost savings
- ✅ Works with existing tools (Bitbucket, Nexus, OpenShift)

## 🎯 Call to Action

> "Here's what I propose: Let's start with a 2-3 microservice pilot. We'll migrate those from Jenkins + Octopus to Harness, prove the value, and then roll out to your remaining services. Based on what we've seen today, you'll have this running in production within 4-6 weeks, and you'll see immediate benefits: faster deployments, fewer incidents, lower costs."

> "I'll send you the pipeline YAML, setup scripts, and documentation. You can start testing this today in your environment. Questions?"
