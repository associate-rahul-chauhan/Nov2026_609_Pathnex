# Day 18: Argo CD basics

Argo CD watches a Git repo and keeps a Kubernetes cluster in sync with it (GitOps).

Files in this folder:

| File | Purpose |
|------|---------|
| `deployment.yaml` | Runs 2 nginx pods |
| `service.yaml` | Exposes the pods inside the cluster on port 80 |
| `application.yaml` | Tells Argo CD which repo, branch and folder to deploy |

## 0. Fix these before you start

1. `application.yaml`: change `repoUrl` to `repoURL` and give it your repo URL, e.g. `https://github.com/<user>/<repo>.git`.
2. `deployment.yaml`: change `ports:` content to a list item: `- containerPort: 80`.
3. `service.yaml`: indent `targetPort: 80` so it lines up with `port: 80`.
4. `path: apps/nginx` must exist in your repo. Either copy `deployment.yaml` and `service.yaml` to `apps/nginx/` in the repo root, or change `path` to where they actually live (e.g. `coding-practice/week3/day18`). Do not point `path` at a folder holding `application.yaml`, or Argo CD will try to deploy the Application itself.
5. Commit and push these changes. Argo CD reads from Git, not from your laptop.

## 1. Prerequisites

You need a running cluster (minikube, kind, Docker Desktop or EKS) and `kubectl` pointing at it.

```powershell
kubectl cluster-info                  # confirm the cluster is reachable
kubectl get nodes                     # nodes should be Ready
```

## 2. Install Argo CD

```powershell
kubectl create namespace argocd       # namespace where Argo CD lives
kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml   # install Argo CD
kubectl get pods -n argocd            # wait until all pods are Running
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s   # block until ready
```

## 3. Open the UI

Run this in its own terminal and leave it open:

```powershell
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Browse to https://localhost:8080 and accept the self-signed certificate warning.

Get the initial password for user `admin` (PowerShell):

```powershell
$p = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($p))
```

## 4. (Optional) Install the CLI and log in

```powershell
winget install argoproj.argocd        # or: choco install argocd-cli
argocd login localhost:8080 --username admin --password <password> --insecure
argocd account update-password        # change the initial password
```

## 5. Create the Application

```powershell
kubectl apply -f application.yaml     # run from this folder; creates the Application in the argocd namespace
```

The same thing with the CLI, without the YAML file:

```powershell
argocd app create nginx-demo `
  --repo https://github.com/<user>/<repo>.git `
  --path apps/nginx `
  --revision main `
  --dest-server https://kubernetes.default.svc `
  --dest-namespace demo `
  --sync-policy automated --auto-prune --self-heal `
  --sync-option CreateNamespace=true
```

## 6. Check status and sync

```powershell
kubectl get applications -n argocd    # list Applications and their Sync/Health status
argocd app list                       # same, via CLI
argocd app get nginx-demo             # details and resource tree
argocd app sync nginx-demo            # manual sync (not needed with automated policy)
kubectl get all -n demo               # the deployed pods, service and deployment
```

You want `Synced` and `Healthy`.

## 7. Try GitOps

1. Change `replicas: 2` to `replicas: 3` in `deployment.yaml`, commit and push.
2. Argo CD detects the change (about 3 minutes by default, or click Refresh) and applies it.
3. Check: `kubectl get pods -n demo`.

Test self-heal by changing the cluster by hand. Argo CD reverts it:

```powershell
kubectl scale deployment nginx -n demo --replicas=5   # manual change
kubectl get pods -n demo -w                           # watch it return to the Git value
```

Test prune: delete `service.yaml` from Git, push, and the Service disappears from the cluster.

## 8. Access nginx

```powershell
kubectl port-forward svc/nginx -n demo 8081:80
```

Browse to http://localhost:8081.

## 9. Troubleshooting

```powershell
argocd app get nginx-demo                         # shows sync errors
kubectl describe application nginx-demo -n argocd # events and conditions
kubectl logs -n argocd deploy/argocd-repo-server  # Git or manifest errors
kubectl logs -n argocd deploy/argocd-application-controller
```

Common causes: wrong `repoURL`, wrong `path`, YAML errors, or a private repo with no credentials added (`argocd repo add <url> --username <u> --password <token>`).

## 10. Clean up

```powershell
kubectl delete -f application.yaml    # removes the Application (and its resources, if the finalizer is set)
kubectl delete namespace demo         # remove the app namespace
kubectl delete namespace argocd       # remove Argo CD
```
