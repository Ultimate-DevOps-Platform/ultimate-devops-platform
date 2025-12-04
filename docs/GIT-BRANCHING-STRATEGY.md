# Git Branching Strategy

## Branch Structure

```
main (production)
  ↑
staging (pre-production)
  ↑
develop (active development)
  ↑
feature/* (individual features)
hotfix/* (emergency fixes)
```

## Branch Descriptions

### main
- **Purpose:** Production-ready code
- **Protection:** Required PR reviews, status checks must pass
- **Deployment:** Auto-deploys to AWS production (EKS)
- **Merges from:** staging, hotfix/*
- **Never commit directly**

### staging
- **Purpose:** Pre-production testing and UAT
- **Protection:** Required PR reviews
- **Deployment:** Auto-deploys to staging environment
- **Merges from:** develop
- **Testing:** Integration tests, performance tests, security scans

### develop
- **Purpose:** Active development, latest changes
- **Protection:** CI must pass
- **Deployment:** Auto-deploys to dev environment
- **Merges from:** feature/*
- **Default branch for development**

### feature/*
- **Purpose:** Individual feature development
- **Naming:** `feature/service-name` or `feature/feature-description`
- **Examples:**
  - `feature/user-service`
  - `feature/payment-integration`
  - `feature/ml-recommendation-engine`
- **Merges to:** develop
- **Lifetime:** Delete after merge

### hotfix/*
- **Purpose:** Emergency production fixes
- **Naming:** `hotfix/issue-description`
- **Examples:**
  - `hotfix/security-vulnerability`
  - `hotfix/payment-gateway-error`
- **Merges to:** main AND develop
- **Lifetime:** Delete after merge

## Workflow

### Starting New Feature
```bash
# Update develop
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/user-service

# Work on feature
git add .
git commit -m "feat: implement user authentication"

# Push to remote
git push -u origin feature/user-service

# Create PR to develop
```

### Merging to Staging
```bash
# After features tested in develop
git checkout staging
git pull origin staging
git merge develop
git push origin staging

# Or create PR: develop → staging
```

### Releasing to Production
```bash
# After staging validation
git checkout main
git pull origin main
git merge staging
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin main --tags

# Or create PR: staging → main
```

### Emergency Hotfix
```bash
# Create from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug

# Fix and commit
git add .
git commit -m "fix: resolve critical payment issue"

# Merge to main
git checkout main
git merge hotfix/critical-bug
git tag -a v1.0.1 -m "Hotfix v1.0.1"
git push origin main --tags

# Merge to develop
git checkout develop
git merge hotfix/critical-bug
git push origin develop

# Delete hotfix branch
git branch -d hotfix/critical-bug
git push origin --delete hotfix/critical-bug
```

## Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types:
- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation changes
- **style:** Code style changes (formatting)
- **refactor:** Code refactoring
- **test:** Adding/updating tests
- **chore:** Maintenance tasks
- **perf:** Performance improvements
- **ci:** CI/CD changes

### Examples:
```bash
git commit -m "feat(user-service): add JWT authentication"
git commit -m "fix(payment): resolve Stripe webhook validation"
git commit -m "docs: update API documentation"
git commit -m "test(order-service): add integration tests"
git commit -m "ci: configure GitHub Actions workflow"
```

## Branch Protection Rules

### main
- ✅ Require pull request reviews (2 approvers)
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Require signed commits
- ✅ Include administrators
- ✅ Restrict who can push

### staging
- ✅ Require pull request reviews (1 approver)
- ✅ Require status checks to pass
- ✅ Require branches to be up to date

### develop
- ✅ Require status checks to pass
- ⚠️ Allow direct commits (for rapid development)

## Environment Mapping

| Branch | Environment | URL | Auto-Deploy |
|--------|-------------|-----|-------------|
| main | Production | https://api.example.com | ✅ |
| staging | Staging | https://staging.example.com | ✅ |
| develop | Development | https://dev.example.com | ✅ |
| feature/* | Local | http://localhost:8000 | ❌ |

## CI/CD Pipeline per Branch

### main (Production)
1. Run all tests (unit, integration, e2e)
2. Security scan (Trivy, Bandit)
3. Build Docker images
4. Push to ECR
5. Deploy to EKS production
6. Run smoke tests
7. Notify team

### staging (Pre-Production)
1. Run all tests
2. Security scan
3. Build Docker images
4. Deploy to staging EKS
5. Run integration tests
6. Performance tests
7. Notify QA team

### develop (Development)
1. Run unit tests
2. Lint and format check
3. Build Docker images
4. Deploy to dev environment
5. Basic smoke tests

### feature/* (Feature Branches)
1. Run unit tests
2. Lint and format check
3. Code coverage report
4. PR preview comment

## Version Tagging

### Semantic Versioning: MAJOR.MINOR.PATCH

- **MAJOR:** Breaking changes (v2.0.0)
- **MINOR:** New features (v1.1.0)
- **PATCH:** Bug fixes (v1.0.1)

### Tagging Commands:
```bash
# Create tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag
git push origin v1.0.0

# Push all tags
git push origin --tags

# List tags
git tag -l

# Delete tag
git tag -d v1.0.0
git push origin --delete v1.0.0
```

## Quick Reference

```bash
# Setup initial branches
git checkout -b develop
git push -u origin develop

git checkout -b staging
git push -u origin staging

# Set develop as default branch
# (Do this in GitHub repo settings)

# Start new feature
git checkout develop
git pull
git checkout -b feature/my-feature

# Update feature branch with latest develop
git checkout feature/my-feature
git fetch origin
git rebase origin/develop

# Clean up merged branches
git branch --merged | grep -v "\*\|main\|develop\|staging" | xargs -n 1 git branch -d
```

## Best Practices

1. **Never commit directly to main or staging**
2. **Always create PR for code review**
3. **Keep feature branches short-lived (< 1 week)**
4. **Rebase feature branches regularly**
5. **Delete branches after merge**
6. **Use meaningful commit messages**
7. **Tag all production releases**
8. **Test locally before pushing**
9. **Keep commits atomic and focused**
10. **Write descriptive PR descriptions**

## Troubleshooting

### Merge Conflicts
```bash
# Update your branch
git checkout feature/my-feature
git fetch origin
git rebase origin/develop

# Resolve conflicts in files
# Then continue rebase
git add .
git rebase --continue
```

### Undo Last Commit
```bash
# Keep changes
git reset --soft HEAD~1

# Discard changes
git reset --hard HEAD~1
```

### Recover Deleted Branch
```bash
# Find commit hash
git reflog

# Recreate branch
git checkout -b feature/recovered <commit-hash>
```
