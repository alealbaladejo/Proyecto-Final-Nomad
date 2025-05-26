job "mariadb" {
  datacenters = ["dc1"]

  group "db" {
    network {
      port "db" {
        static = 3306
      }
    }

    volume "db-wp" {
      type      = "host"
      read_only = false
      source    = "mariadb_volume"
    }

    task "mariadb" {
      driver = "docker"

      config {
        image = "mariadb:10.11"
        ports = ["db"]
      }

      volume_mount {
        volume      = "db-wp"
        destination = "/var/lib/mysql"
        read_only   = false
      }

      template {
        data = <<EOF
MYSQL_ROOT_PASSWORD={{ with nomadVar "nomad/jobs" }}{{ .MYSQL_ROOT_PASSWORD }}{{ end }}
MYSQL_DATABASE={{ with nomadVar "nomad/jobs" }}{{ .MYSQL_DATABASE }}{{ end }}
MYSQL_USER={{ with nomadVar "nomad/jobs" }}{{ .MYSQL_USER }}{{ end }}
MYSQL_PASSWORD={{ with nomadVar "nomad/jobs" }}{{ .MYSQL_PASSWORD }}{{ end }}
EOF
        destination = "secrets/env"
        env         = true
      }

      service {
        name = "mariadb"
        port = "db"
        tags = ["db"]
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 300
        memory = 256
      }
    }
  }
}


