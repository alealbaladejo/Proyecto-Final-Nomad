job "mariadb" {
  datacenters = ["dc1"]
  type        = "service"

  group "db" {
    count = 1

    network {
      port "db" {
        to = 3306
      }
    }

    task "mariadb" {
      driver = "docker"

      config {
        image = "mariadb:latest"
        ports = ["db"]
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/db.env"
        env         = true
        change_mode = "restart"

        data = <<EOT
MYSQL_ROOT_PASSWORD={{ with nomadVar "nomad/jobs/mariadb/db/mariadb" }}{{ .MYSQL_ROOT_PASSWORD }}{{ end }}
MYSQL_DATABASE={{ with nomadVar "nomad/jobs/mariadb/db/mariadb" }}{{ .MYSQL_DATABASE }}{{ end }}
MYSQL_USER={{ with nomadVar "nomad/jobs/mariadb/db/mariadb" }}{{ .MYSQL_USER }}{{ end }}
MYSQL_PASSWORD={{ with nomadVar "nomad/jobs/mariadb/db/mariadb" }}{{ .MYSQL_PASSWORD }}{{ end }}
EOT
      }
#para crear las variables usamos:
#nomad var put nomad/jobs/mariadb/db/mariadb  \
# MYSQL_ROOT_PASSWORD=root_password \   
# MYSQL_DATABASE=database \
# MYSQL_USER=usuario \
# MYSQL_PASSWORD=my_password


      service {
        provider = "nomad"
        name     = "mariadb"
        port     = "db"
        tags     = ["db", "mariadb"]
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}
