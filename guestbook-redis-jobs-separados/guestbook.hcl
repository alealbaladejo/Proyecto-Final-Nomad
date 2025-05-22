job "guestbook" {
  datacenters = ["dc1"]

  group "guestbook-group" {
    network {
      port "http" {
        to     = 5000
        static = 8087
      }
    }

    task "app" {
      driver = "docker"

      config {
        image = "iesgn/guestbook"
        ports = ["http"]
      }

      template {
        data = <<EOF
      REDIS_SERVER={{ with service "redis" }}{{ (index . 0).Address }}{{ end }}
      EOF
        destination = "secrets/env"
        env         = true
      }

      resources {
        cpu    = 200
        memory = 256
      }

      service {
        provider = "nomad"
        name     = "guestbook"
        port     = "http"
      }
    }
  }
}
