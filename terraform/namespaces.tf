# A "set" of strings -> Terraform will create one kubernetes_namespace per
# entry. This is the for_each pattern: instead of copy-pasting 3 almost
# identical resource blocks, we write it once and loop over the values.
resource "kubernetes_namespace" "this" {
  for_each = toset(["violetboard", "echoo", "monitoring"])

  metadata {
    name = each.value
  }

  # Wait for the cluster to actually exist before trying to talk to it.
  depends_on = [null_resource.k3d_cluster]
}