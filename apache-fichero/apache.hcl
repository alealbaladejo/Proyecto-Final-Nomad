job "apache" {
  datacenters = ["dc1"]
  type = "service"

  group "apache" {
    count = 1

    network {
      port "http" {
        static = 8086
        to = 80
      }
    }

    task "apache" {
      driver = "docker"

      config {
        image = "httpd:2.4"
        ports = ["http"]

        volumes = [
          "/home/ale/proyecto/pruebas/apache-fichero/web:/usr/local/apache2/htdocs"
        ]
      }

      resources {
        cpu    = 500
        memory = 256
      }

      service {
        name     = "apache"
        port     = "http"
        provider = "nomad"
      }
    }
  }
}
