job "bigslackslash" {
  datacenters = ["alpha"]
  type        = "service"

  update {
    max_parallel      = 2
    min_healthy_time  = "10s"
    healthy_deadline  = "3m"
    progress_deadline = "10m"
    auto_revert       = false
    canary            = 0
  }

  migrate {
    max_parallel     = 2
    health_check     = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }

  group "bigslackslash" {
    count = 1

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "bigslackslash" {
      driver = "docker"

      env {
        IMGUR_CLIENT_ID = "c0b16bac15fdd9d"
        IMGUR_API_URL = "https://api.imgur.com/3/upload"
        MINIO_ENDPOINT="https://minioext.veverka.net"
      }

      config {
        image        = "registry.veverka.net/slackslash"

        auth {
          username = "test"
          password = "test"
        }

        network_mode = "bridge"


        port_map {
          bigslackslash = 9292
        }

        labels {}
      }

      env {
        PUID = "1000"
        PGID = "995"
        TZ   = "America/New_York"
      }

      resources {
        cpu    = 500  # 500 MHz
        memory = 1024 # 1G

        network {
          mbits = 100
          port  "bigslackslash"{}
        }
      }

      service {
        name = "bigslackslash"
        port = "bigslackslash"

        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
