# When k3d creates a cluster, it automatically writes/updates an entry in
# your local kubeconfig (~/.kube/config) under the context "k3d-<name>".
# We point the Kubernetes provider at that same context.
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k3d-${var.cluster_name}"
}