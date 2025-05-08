job "traefik" {
  datacenters = ["dc1"]
  
  group "traefik" {
    count = 1

    network {
      port "web" {
        static = 8050
      }
      port "admin" {
        static = 8090
      }
    }

    task "traefik" {
      driver = "docker"
      
      config {
        image = "traefik:v2.10"
        args = [
          "--api.dashboard=true",
          "--api.insecure=true",
          "--entrypoints.web.address=:${NOMAD_PORT_web}",
          "--entrypoints.traefik.address=:${NOMAD_PORT_admin}",
          "--ping=true",
          "--metrics.prometheus=true",
          "--metrics.prometheus.addServicesLabels=true",
          "--providers.nomad=true",
          "--providers.nomad.exposedByDefault=false",
          "--providers.nomad.endpoint.address=http://192.168.1.136:4646"
        ]
        ports = ["web", "admin"]
      }

      resources {
        cpu    = 200
        memory = 128
      }

      service {
        provider = "nomad"
        name     = "traefik"
        port     = "web"
      }
    }
  }
}
