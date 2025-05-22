job "guestbook" {
  datacenters = ["dc1"]

  group "guestbook-group" {
    network {
      port "http" {
        to = 5000
        static = 8083
      }
      port "redis" {
        static = 6379
        to = 6379
      }
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis"
        command = "redis-server"
        args = ["--appendonly", "yes"]
        ports = ["redis"]
      }

      volume_mount {
        volume      = "redis_data"
        destination = "/data"
        read_only   = false
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }

    task "app" {
      driver = "docker"

      config {
        image = "iesgn/guestbook"
        ports = ["http"]
      }
      env {
        REDIS_SERVER = "${NOMAD_IP_redis}"

      }

      resources {
        cpu    = 200
        memory = 256
      }

      service {
        provider = "nomad"
        name = "guestbook"
        port = "http"
      }
    }

    volume "redis_data" {
      type      = "host"
      read_only = false
      source    = "redis_volume"
    }
  }
}
