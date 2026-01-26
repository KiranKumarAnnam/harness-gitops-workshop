#!/bin/bash

# Complete Demo Environment Setup Script
# This script sets up all necessary OpenShift namespaces and validates prerequisites

set -e

echo "=========================================="
echo "Harness Complete CI/CD Demo - Setup"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "$1"
}

# Check if oc is installed
echo "Step 1: Checking prerequisites..."
if ! command -v oc &> /dev/null; then
    print_error "OpenShift CLI (oc) not found. Please install it first."
    exit 1
fi
print_success "OpenShift CLI (oc) found"

# Check if logged into OpenShift
if ! oc whoami &> /dev/null; then
    print_error "Not logged into OpenShift. Please run 'oc login' first."
    exit 1
fi
print_success "Logged into OpenShift as: $(oc whoami)"

echo ""
echo "Step 2: Creating namespaces..."

# Create DEV namespace
if oc get namespace podinfo-dev &> /dev/null; then
    print_warning "Namespace podinfo-dev already exists"
else
    oc create namespace podinfo-dev
    print_success "Created namespace: podinfo-dev"
fi

# Create QA namespace
if oc get namespace podinfo-qa &> /dev/null; then
    print_warning "Namespace podinfo-qa already exists"
else
    oc create namespace podinfo-qa
    print_success "Created namespace: podinfo-qa"
fi

# Create PROD namespace
if oc get namespace podinfo-prod &> /dev/null; then
    print_warning "Namespace podinfo-prod already exists"
else
    oc create namespace podinfo-prod
    print_success "Created namespace: podinfo-prod"
fi

echo ""
echo "Step 3: Verifying Harness delegate..."

# Check for delegate
DELEGATE_POD=$(oc get pods -n gitness-demo -l app=kubernetes-delegate --field-selector=status.phase=Running -o name 2>/dev/null | head -n 1)
if [ -n "$DELEGATE_POD" ]; then
    print_success "Harness delegate is running: $DELEGATE_POD"
else
    print_error "Harness delegate not found or not running in gitness-demo namespace"
    echo "Please ensure the delegate is deployed and connected"
fi

echo ""
echo "Step 4: Checking GitOps agent (if enabled)..."

# Check for GitOps pods
GITOPS_PODS=$(oc get pods -n gitness-demo -l app.kubernetes.io/name=argocd-application-controller --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
if [ "$GITOPS_PODS" -gt 0 ]; then
    print_success "GitOps agent is running ($GITOPS_PODS pods)"
else
    print_warning "GitOps agent not found (module may not be enabled yet)"
fi

echo ""
echo "Step 5: Verifying namespace access..."

# Test if we can create resources in each namespace
for ns in podinfo-dev podinfo-qa podinfo-prod; do
    if oc auth can-i create deployments -n $ns &> /dev/null; then
        print_success "Can create resources in $ns"
    else
        print_error "Cannot create resources in $ns - check permissions"
    fi
done

echo ""
echo "Step 6: Creating test service accounts (optional)..."

# Create service accounts for each namespace
for ns in podinfo-dev podinfo-qa podinfo-prod; do
    if oc get sa podinfo-sa -n $ns &> /dev/null; then
        print_warning "Service account podinfo-sa already exists in $ns"
    else
        oc create sa podinfo-sa -n $ns
        print_success "Created service account: podinfo-sa in $ns"
    fi
done

echo ""
echo "Step 7: Summary of created resources..."

echo ""
print_info "Namespaces:"
oc get namespace | grep podinfo

echo ""
print_info "Delegate status:"
oc get pods -n gitness-demo -l app=kubernetes-delegate 2>/dev/null || echo "No delegate pods found"

echo ""
print_info "GitOps agent status:"
oc get pods -n gitness-demo -l app.kubernetes.io/name=argocd-application-controller 2>/dev/null || echo "No GitOps pods found"

echo ""
echo "=========================================="
print_success "Setup complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Create environments in Harness:"
echo "   - QA Environment"
echo "   - Production Environment"
echo ""
echo "2. Create infrastructure definitions:"
echo "   - OpenShift QA Infrastructure"
echo "   - OpenShift Production Infrastructure"
echo ""
echo "3. Update podinfo_service with new manifests:"
echo "   - deployment-canary.yaml"
echo "   - deployment-bluegreen.yaml"
echo "   - values-dev.yaml, values-qa.yaml, values-prod.yaml"
echo ""
echo "4. Create the pipeline in Harness:"
echo "   - Import complete-demo-pipeline.yaml"
echo ""
echo "5. Run the pipeline and test all scenarios!"
echo ""
echo "For detailed instructions, see: COMPLETE_DEMO_SETUP.md"
