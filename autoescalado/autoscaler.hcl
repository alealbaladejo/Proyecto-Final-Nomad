nomad {
  address = "http://localhost:4646"
}

telemetry {
  prometheus_metrics = true
  disable_hostname   = true
}

apm "prometheus" {
  driver = "prometheus"
  config = {
    address = "http://localhost:9090"
  }
}

strategy "target-value" {
  driver = "target-value"
}
