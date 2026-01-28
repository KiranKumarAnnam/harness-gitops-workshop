# Harness CI/CD Demo Presentation - Speaking Points
## January 28, 2026

---

## 🎯 WHAT WE BUILT (1 minute)

**4 Pipeline Iterations in 3 Days:**
- Complete CI/CD pipeline: Build → DEV → QA → PROD
- Docker image build and deployment to OpenShift
- Canary and Blue-Green deployment strategies
- Approval gates for QA and Production
- Automated rollback capabilities

**Tech Stack:**
- Application: Podinfo (Go microservice)
- Container: Docker (kannam/podinfo)
- Platform: OpenShift on-premises
- Repository: GitHub (demo-fixed-pipeline branch)

---

## ✅ HARNESS ADVANTAGES (3-4 minutes)

### 1. **Unified CI/CD Platform**
- **What:** Single tool for build + deployment (replaces Jenkins + Octopus)
- **Benefit:** One pipeline YAML, one UI, one execution view
- **Demo:** Show complete-demo-pipeline-v4.yaml flowing through all stages
- **Impact:** Reduced tool complexity and integration overhead

### 2. **Multi-Environment Deployment with Approvals**
- **What:** DEV (auto) → QA (approval) → PROD (approval + canary)
- **Benefit:** Governance built-in, no custom scripting
- **Demo:** Show approval gates and execution waiting for approval
- **Impact:** Production safety without sacrificing speed

### 3. **Built-in Deployment Strategies**
- **What:** Canary (25% → 50% → 100%), Blue-Green, Rolling
- **Benefit:** No manual scripting, native Kubernetes integration
- **Demo:** Show canary progression with health checks
- **Impact:** Advanced deployment patterns in minutes, not days

### 4. **Automated Rollback**
- **What:** Automatic revert on deployment failure
- **Benefit:** Fast recovery, no manual intervention
- **Demo:** Show failureStrategies with StageRollback
- **Impact:** Reduced MTTR, production stability

### 5. **Smart Artifact Management**
- **What:** Pipeline sequence ID auto-tags images (`<+pipeline.sequenceId>`)
- **Benefit:** Same image version across all environments
- **Demo:** Show tag propagation DEV → QA → PROD
- **Impact:** Traceability, no manual versioning errors

### 6. **Expression Language for Dynamic Config**
- **What:** `<+pipeline.sequenceId>`, `<+codebase.branch>`, `<+pipeline.triggeredBy.email>`
- **Benefit:** Dynamic configuration without hardcoding
- **Demo:** Show expressions in YAML and execution output
- **Impact:** Flexible, reusable pipelines

### 7. **Cloud CI Execution**
- **What:** Harness Cloud runners for builds (no agents to manage)
- **Benefit:** Zero infrastructure setup for CI
- **Demo:** Show CI stage running on Harness Cloud
- **Impact:** Instant build capacity, no maintenance

### 8. **Pipeline as Code with Git Integration**
- **What:** YAML stored in Git, version controlled
- **Benefit:** Track changes, rollback, collaboration
- **Demo:** Show Git history with multiple pipeline versions
- **Impact:** True GitOps for pipelines

---

## ❌ CHALLENGES WE FACED (3-4 minutes)

### 1. **Service Config Not in Git** ⚠️ CRITICAL
- **Problem:** Artifact configuration lives in Harness UI, not pipeline YAML
- **Impact:** Can't reproduce from Git alone, manual UI setup required
- **Real Example:** Service had `tagRegex: <+input>` causing runtime prompts
- **Solution:** Had to manually fix in Harness UI (Service → Artifacts)
- **Learning:** Service configuration is source of truth, overrides pipeline YAML
- **Time Lost:** 3 hours debugging across multiple pipeline versions

### 2. **Bidirectional Git Sync Conflicts** ⚠️ MAJOR
- **Problem:** Harness overwrites Git changes silently
- **Impact:** Lost work multiple times, changes reverted
- **Real Example:** Pushed pipeline updates to main branch → disappeared in minutes
- **Solution:** Created separate branch (demo-fixed-pipeline), disabled sync
- **Learning:** Use feature branches, not obvious sync was enabled
- **Time Lost:** 2+ hours, created 3 pipeline versions

### 3. **Kubernetes Security Context Complexity** ⚠️ MAJOR
- **Problem:** Error: "Cannot find property 'fsGroup' on V1SecurityContext"
- **Impact:** Deployment failed, confusing error message
- **Real Example:** fsGroup is pod-level, we put it in container-level
- **Solution:** Modified Helm chart to support podSecurityContext separately
- **Learning:** Harness docs unclear on pod vs container distinction
- **Time Lost:** 4 hours researching Kubernetes API + modifying Helm chart
- **Files Changed:** deployment.yaml, values.yaml (Git commit 0f3ecd9)

### 4. **Helm Chart Limitations**
- **Problem:** Podinfo chart had no podSecurityContext support
- **Impact:** Couldn't set security via Helm values, needed chart modification
- **Real Example:** Chart had `securityContext: null` by default
- **Solution:** Added conditional podSecurityContext block to template
- **Learning:** Helm chart quality matters, may need customization

### 5. **Learning Curve for Harness Expressions**
- **Problem:** Expression language different from Jenkins/Octopus
- **Impact:** Trial and error to find right expressions
- **Real Example:** Not clear which expressions work in which contexts
- **Solution:** Consulted docs and experimented
- **Learning:** Better autocomplete and examples needed

### 6. **Setup Time Reality Check**
- **Claim:** "Deploy in minutes"
- **Reality:** 2-3 days (15 hours total)
- **Breakdown:**
  - Day 1: Initial setup, tag input debugging (6h)
  - Day 2: Git sync issues, Service config fixes (5h)
  - Day 3: Security context fixes, Helm chart mods (4h)
- **Learning:** Real-world requires troubleshooting, docs alone insufficient

### 7. **Documentation Gaps**
- **Missing:** Service artifact config relationship to pipeline YAML
- **Missing:** Clear pod vs container security context examples
- **Missing:** Bidirectional Git sync warnings
- **Impact:** Had to discover through debugging and trial-error

---

## 📊 HONEST SCORING (1 minute)

| Category | Score | Reasoning |
|----------|-------|-----------|
| **Features** | 9/10 | Everything we needed (canary, approvals, rollback) |
| **Setup** | 5/10 | Multiple troubleshooting hurdles |
| **Documentation** | 6/10 | Good examples, missing critical details |
| **Debugging** | 5/10 | Error messages not actionable |
| **Approvals** | 10/10 | Excellent, simple, effective |
| **Multi-Env** | 9/10 | Great DEV/QA/PROD flow |
| **GitOps** | 6/10 | Partial - Service config in UI only |
| **Overall** | **7/10** | Powerful but has learning curve |

---

## 💼 COMPARISON: HARNESS vs JENKINS+AI (2-3 minutes)

### Financial (3-Year Total Cost of Ownership)

| Platform | Year 1 | Year 2-3 | 3-Year Total |
|----------|--------|----------|--------------|
| **Harness** | $105K-155K | $130K-230K | **$235K-385K** |
| **Jenkins+Jenix AI** | $110K-120K | $80K | **$190K-200K** |
| **Savings with Jenkins** | - | - | **$35K-185K** |

### Integration Effort for Jenix AI

| Factor | Harness | Jenkins | Winner |
|--------|---------|---------|--------|
| **AI Integration Time** | 6-10 weeks | 5-9 weeks | Jenkins |
| **Coverage** | 75-80% (API limits) | 100% (full control) | Jenkins |
| **Jenix Capabilities** | Limited (can't clear caches) | Full (native integration) | Jenkins |
| **Maintenance** | Medium | Low | Jenkins |

### Strategic Fit

| Factor | Harness | Jenkins+Jenix |
|--------|---------|---------------|
| **Team Knowledge** | New learning curve | ✅ Already know Jenkins |
| **AI Priority** | ⚠️ Wrapper approach | ✅ Native, full control |
| **Vendor Lock-In** | ⚠️ Yes | ✅ No |
| **3-Year ROI** | Lower | ✅ 15-48% savings |
| **IP Ownership** | No | ✅ Yes (can commercialize) |

---

## 🎯 FINAL RECOMMENDATION (1 minute)

### **BUILD with Jenkins + Jenix AI** ✅

**Why:**
1. **Cost:** Save $35K-185K over 3 years
2. **AI Integration:** 100% Jenix capabilities vs 75-80% with Harness
3. **Team Fit:** Already Jenkins experts, no migration risk
4. **Control:** Full flexibility, no vendor lock-in
5. **Strategic:** Own AI IP, can extend to other tools

**Trade-Off:**
- Harness: Faster initial setup (2-3 days vs 2-3 weeks)
- Jenkins: Better long-term value, full AI control

**Confidence:** 90%

---

## 🎤 KEY MESSAGES FOR STAKEHOLDERS

### For Engineering Leadership:
- "Harness has great features but requires Kubernetes expertise"
- "Service config in UI is a GitOps gap we need to address"
- "Jenkins + our AI gives us 100% control vs 75% with Harness API"

### For Finance:
- "3-year savings: $35K-185K with Jenkins+AI approach"
- "Harness has recurring licensing costs that grow with team size"
- "One-time investment in Jenkins+AI pays off in Year 2"

### For DevOps Team:
- "Harness approval workflows are excellent - we can replicate"
- "Real setup took 15 hours, not 'minutes' as claimed"
- "Team already knows Jenkins - lower learning curve"

### For Executive:
- "Harness demo validated our requirements are achievable"
- "Building with Jenkins+AI gives us strategic advantage"
- "We own the AI IP and can commercialize it"

---

## 📋 DEMO FLOW SUGGESTIONS (5 minutes)

### Opening (30 seconds)
"We spent 3 days setting up a complete CI/CD pipeline in Harness to evaluate it against our Jenkins+AI approach. Let me show you what we built and what we learned."

### Show Pipeline (1 minute)
1. Open complete-demo-pipeline-v4.yaml in editor
2. Highlight: CI stage → DEV → QA (approval) → PROD (approval + canary)
3. Point out: Tag propagation, health checks, rollback steps

### Show Execution (1 minute)
1. Open Harness UI execution view
2. Show: Build stage → Docker push → DEV deployment
3. Highlight: Approval gates waiting for manual action
4. Show: Canary progression (25% → 50% → 100%)

### Show Challenges (1.5 minutes)
1. Open Service artifact config in UI
2. Explain: "This isn't in Git - that's a problem"
3. Show Git history: "We created 4 versions debugging issues"
4. Show Helm chart modifications: "Had to fix security context support"

### Show Comparison (1 minute)
1. Open HARNESS_VS_JENKINS_AI_DECISION_REPORT.md
2. Highlight 3-year cost table: "$35K-185K savings"
3. Highlight Jenix integration: "100% capabilities vs 75%"

### Closing (30 seconds)
"Harness is powerful but has challenges. Our recommendation: Build with Jenkins+Jenix AI for better ROI, full control, and strategic advantage."

---

## ❓ ANTICIPATED QUESTIONS & ANSWERS

### Q: "Why not just use Harness if it has more features?"
**A:** "Cost and AI integration. Over 3 years we save $35K-185K, and our Jenix AI works better with Jenkins (100% capabilities vs 75%). Harness features are great but we can build equivalents in 2-3 weeks."

### Q: "What if the team can't maintain Jenkins long-term?"
**A:** "Jenkins is industry standard with huge community. Our team already knows it. Harness introduces new learning curve. Risk is actually lower with Jenkins."

### Q: "How long until Jenkins+AI is production-ready?"
**A:** "2-3 weeks for basic CI/CD (vs 2-3 days with Harness). AI features add 4-6 weeks. But we get 100% control and better long-term ROI."

### Q: "What about Harness's advanced features like Security Testing?"
**A:** "We can use Trivy, Snyk, and SonarQube plugins with Jenkins. Harness STO module costs extra. Our approach is more flexible."

### Q: "Can we switch to Harness later if Jenkins doesn't work?"
**A:** "Yes. Jenix AI can be adapted to Harness in 6 months if needed. We're not locked in. Harness demo was valuable learning."

### Q: "What's the biggest risk with Jenkins approach?"
**A:** "AI development complexity. Mitigation: Start with MVP (4 months, 60% value), evaluate before committing to full build."

---

## 🎯 ONE-SLIDE SUMMARY

**HARNESS EVALUATION: 3-DAY HANDS-ON EXPERIENCE**

**✅ ADVANTAGES:**
- Unified CI/CD (no Jenkins + Octopus needed)
- Built-in approvals and deployment strategies (canary, blue-green)
- Automated rollback and health checks
- Cloud CI (no agent management)

**❌ CHALLENGES:**
- Service config in UI, not Git (15h debugging)
- Git sync conflicts (lost work multiple times)
- Security context complexity (4h Helm chart fixes)
- Real setup: 2-3 days, not "minutes"

**💰 DECISION:**
- Build Jenkins+Jenix AI: **$35K-185K savings** (3 years)
- 100% Jenix capabilities vs 75% with Harness
- Team knows Jenkins, no migration risk
- Own AI IP, full control

**🎯 CONFIDENCE: 90%**

---

**Preparation Tips:**
1. ✅ Have Harness UI open with execution history
2. ✅ Have VS Code open with pipeline YAML and Git history
3. ✅ Have cost comparison spreadsheet ready
4. ✅ Prepare to show Helm chart modifications (commit 0f3ecd9)
5. ✅ Have HARNESS_REAL_EXPERIENCE_REPORT.md and decision reports open as backup

**Timing:**
- Total presentation: 10-12 minutes
- Q&A: 5-10 minutes
- Demo walkthrough: 5 minutes (optional)

---

**Document Created:** January 27, 2026  
**Demo Date:** January 28, 2026  
**Presenter:** DevOps Team  
**Audience:** Engineering Leadership, Stakeholders
