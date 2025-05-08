job "webapp" {
  datacenters = ["dc1"]
  type = "service"
  
  group "webapp" {
    count = 1

    network {
      port "http" {
        to = 80
      }
    }

    scaling {
      enabled = true
      min     = 1
      max     = 5
      policy {
        cooldown = "60s"
        check "avg_sessions" {
          source = "prometheus"
          query = "avg(nomad_client_allocs_cpu_total_percent{exported_job=\"webapp\", task_group=\"webapp\"})"
          strategy "target-value" {
            target = 60.0
          }
        }
      }
    }

    service {
      name     = "webapp"
      provider = "nomad"
      port     = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.webapp.entrypoints=web",
        "traefik.http.routers.webapp.rule=PathPrefix(`/`)"
      ]
    }

    task "server" {
      driver = "docker"
      
      config {
        image = "nginx:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
