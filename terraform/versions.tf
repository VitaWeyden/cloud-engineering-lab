terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # Manages real Kubernetes objects (Namespace, Secret, ...) once a cluster exists.
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }

    # Generates random passwords / keys, so we don't have to type them by hand
    # like start.py / kubernetes/setup.py currently ask you to.
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    # k3d itself has no official Terraform provider (it's a dev tool, not a
    # cloud API), so we shell out to the k3d CLI via a null_resource instead.
    # "null" just gives us a resource that can run arbitrary provisioners.
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}