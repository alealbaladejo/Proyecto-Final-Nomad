job "wordpress" {
  datacenters = ["dc1"]

  group "web" {
    network {
      port "http" {
        static = 8080
	to = 80
      }
    }

    task "wordpress" {
      driver = "docker"

      config {
        image = "wordpress:6.8"
        ports = ["http"]
      }

      template {
        data = <<EOF
WORDPRESS_DB_NAME={{ with nomadVar "nomad/jobs" }}{{ .MYSQL_DATABASE }}{{ end }}
WORDPRESS_DB_USER={{ with nomadVar "nomad/jobs" }}{{ .MYSQL_USER }}{{ end }}
WORDPRESS_DB_PASSWORD={{ with nomadVar "nomad/jobs" }}{{ .MYSQL_PASSWORD }}{{ end }}
WORDPRESS_DB_HOST={{ with service "mariadb" }}{{ (index . 0).Address }}:{{ (index . 0).Port }}{{ end }}
EOF
        destination = "secrets/env"
        env         = true
      }

      service {
        name = "wordpress"
        port = "http"
        tags = ["web"]
        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}
