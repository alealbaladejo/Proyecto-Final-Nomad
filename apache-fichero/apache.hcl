job "apache" {
  datacenters = ["dc1"]
  type = "service"

  group "apache" {
    count = 1

    volume "webapache" {
      type = "host"
      read_only = "false"
      source = "webapache"
    }

    network {
      port "http" {
        static = 8085
        to = 80
      }
    }

    task "apache" {
      driver = "docker"

      config {
        image = "httpd:2.4"
        ports = ["http"]
      }

      volume_mount {
        volume = "webapache"
        destination = "/usr/local/apache2/htdocs"
        read_only = false
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
