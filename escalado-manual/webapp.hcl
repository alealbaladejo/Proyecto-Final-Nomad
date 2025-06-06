job "demo-webapp" {
  datacenters = ["dc1"]

  group "demo" {
    count = 6

    network {
      port "http" {
        to = -1
      }
    }

    service {
      name = "demo-webapp"
      port = "http"

      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "server" {
      driver = "docker"

      env {
        PORT    = "${NOMAD_PORT_http}"
        NODE_IP = "${NOMAD_IP_http}"
      }

      config {
        image = "hashicorp/demo-webapp-lb-guide"
        ports = ["http"]
      }
    }
  }
}
