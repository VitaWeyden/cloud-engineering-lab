variable "cluster_name" {
  description = "Name of the k3d cluster"
  type        = string
  default     = "cloud-engineering-lab"
}

resource "null_resource" "k3d_cluster" {
  # "triggers" tells Terraform when this resource should be considered
  # "changed" and re-run. Here we only care about the cluster name changing.
  triggers = {
    cluster_name = var.cluster_name
  }

  # Runs when the resource is created. We check first whether the cluster
  # already exists, so re-running `terraform apply` is safe (idempotent) —
  # same idea as cluster_exists() in kubernetes/setup.py.
  #
  # NOTE: this assumes Windows + PowerShell (interpreter is set explicitly
  # below). On macOS/Linux you'd drop the `interpreter` line and write this
  # in plain sh (`if k3d cluster list ... >/dev/null 2>&1; then ...`).
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<-EOT
      k3d cluster list ${var.cluster_name} *> $null
      if ($LASTEXITCODE -eq 0) {
        Write-Host "Cluster '${var.cluster_name}' already exists, skipping"
      } else {
        k3d cluster create ${var.cluster_name} `
          --port 8110:8110@loadbalancer `
          --port 8111:8111@loadbalancer `
          --port 3344:3344@loadbalancer `
          --port 3010:3010@loadbalancer `
          --port 9099:9099@loadbalancer
        if ($LASTEXITCODE -ne 0) { exit 1 }
      }
    EOT
  }

  # Runs when you do `terraform destroy`. self.triggers is used because the
  # variable itself may no longer be available at destroy time.
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["PowerShell", "-Command"]
    command     = "k3d cluster delete ${self.triggers.cluster_name}"
  }
}