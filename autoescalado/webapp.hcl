job "webapp" {
  datacenters = ["dc1"]
  type = "service"
  
  group "webapp" {
    count = 3

    network {
      port "http" {
        to = -1
      }
    }

    scaling {
      enabled = true
      min     = 1
      max     = 5
      policy {
        cooldown = "30s"
        check "avg_sessions" {
          source = "prometheus"
          query = "avg(nomad_client_allocs_cpu_total_percent{exported_job=\"webapp\", task_group=\"webapp\", task=\"server\"})"
          strategy "target-value" {
            target = 30.0
	    lookback = "30s"
	    interval = "10s"
          }
        }
      }
    }

    service {
      name     = "webapp"
      port     = "http"
      check {
	type = "http"
	path = "/"
	interval = "2s"
	timeout = "2s"
      }
    }

    task "server" {
      driver = "docker"
      
      env {
	PORT = "${NOMAD_PORT_http}"
	NODE_IP = "${NOMAD_IP_http}"	
      }
      config {
        image = "hashicorp/demo-webapp-lb-guide"
        ports = ["http"]
      }
    }
  }
}
