job "redis" {
  datacenters = ["dc1"]

  group "redis" {
    count = 1

    network {
      port "db" {
        static = 6379
        to = 6379
      }
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:7"
        ports = ["db"]
      }

      resources {
        cpu    = 100
        memory = 128
      }

      service {
        name = "redis"
        port = "db"
      }
    }
  }
}
