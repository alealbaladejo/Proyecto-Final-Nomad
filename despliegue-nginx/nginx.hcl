job "nginx" {
  datacenters = ["dc1"]
  type = "service"

  group "nginx" {
    count = 1

    network {
      port "http" {
        static = 8086
        to = 80
      }
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:latest"
        ports = ["http"]
      }

      service {
        provider = "nomad"
        name = "nginx"
        port = "http"
      }
    }
  }
}
