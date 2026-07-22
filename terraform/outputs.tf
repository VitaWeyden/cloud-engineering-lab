output "grafana_password" {
  description = "Login password for the Grafana admin user"
  value       = random_password.grafana.result
  sensitive   = true # hidden by default; reveal with: terraform output grafana_password
}

output "urls" {
  description = "Where to reach each service once everything is up"
  value = {
    violetboard = "http://localhost:8110"
    echoo       = "http://localhost:8111"
    grafana     = "http://localhost:3010"
    prometheus  = "http://localhost:9099"
  }
}