# Despliegue de Guestbook conectada a una BD Redis con Nomad en dos ficheros distintos. Uso de Consul

En este tutorial se explica como desplegar la aplicación guestbook que se conecta a una base de datos Redis, con Nomad Hashicorp en un contenedor Docker, usando Debian 12 como Host.

## Requisitos

- Nomad.- [*Instalación Nomad*](https://developer.hashicorp.com/nomad/docs/install)

- Docker.- [*Instalación Docker*](https://docs.docker.com/engine/install/debian/)

- Consul.- [*Instalación Consul*](https://developer.hashicorp.com/consul/install)

## Clonar repositorio

Lo primero que realizamos será la clonación del repositorio donde encontraremos los ficheros necesarios:

~~~
git clone https://github.com/alealbaladejo/Proyecto-Final-Nomad.git
~~~

~~~
cd Proyecto-Final-Nomad/guestbook-redis-jobs-separados
~~~

## Problema identificado

A continuación vamos a desplegar la aplicación Guestbook conectada a una base de datos Redis, desde dos ficheros distintos.

Ahora pasamos a dividir el job anterior en dos jobs distintos. Esto nos va a causar un problema, ya que por defecto Nomad no es capaz de averiguar la IP de un servicio, que está desplegado en otro job distinto, por lo que va en contra de las buenas prácticas, ya que tendríamos que poner en el propio job de Guestbook, la dirección IP de la máquina donde corre redis. Lo podemos ver en el siguiente ejemplo:

A continuación vemos el fichero de redis:
~~~
cat redis.hcl 

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
	provider = "nomad"
        name = "redis"
        port = "db"
      }

    }
  }
}

~~~

Y ahora vemos el de guestbook
~~~
cat guestbook.hcl 
job "guestbook" {
  datacenters = ["dc1"]

  group "guestbook-group" {
    network {
      port "http" {
        to     = 5000
        static = 8087
      }
    }

    task "app" {
      driver = "docker"

      config {
        image = "iesgn/guestbook"
        ports = ["http"]
      }

      # Establecemos la IP del servidor Redis manualmente
      template {
        data = <<EOF
REDIS_SERVER=192.168.122.66
EOF
        destination = "secrets/env"
        env         = true
      }

      resources {
        cpu    = 200
        memory = 256
      }

      service {
        provider = "nomad"
        name     = "guestbook"
        port     = "http"
      }
    }
  }
}
~~~


Como hemos dicho esto no está correctamente, ya que la IP puede ser dinámica y nos puede dar un quebradero de cabeza. Para evitar esto Hashicorp proporciona una herramienta llamada Consul que nos ayuda al descubrimiento de servicios.

## Solución
Ahora vamos a modificar el fichero de configuración de Consul:

~~~
cat /etc/consul.d/consul.hcl 

datacenter = "dc1"
data_dir = "/opt/consul"
log_level = "INFO"

server = true
bootstrap_expect = 1
ui_config{
  enabled = true
}

client_addr = "0.0.0.0"
bind_addr = "192.168.122.66" 
advertise_addr = "192.168.122.66"

addresses {
  http = "0.0.0.0"
}

connect {
  enabled = true
}
~~~

Y pasamos a iniciar Consul
~~~
sudo systemctl start consul.service
~~~

Es posible que este comando se quede colgado, pero podemos cancelarlo y comprobar que esté funcionando

~~~
sudo systemctl status consul.service
● consul.service - "HashiCorp Consul - A service mesh solution"
     Loaded: loaded (/lib/systemd/system/consul.service; disabled; preset: enabled)
     Active: activating (start) since Thu 2025-05-22 16:51:12 CEST; 14s ago
       Docs: https://developer.hashicorp.com/
   Main PID: 19791 (consul)
      Tasks: 11 (limit: 5710)
     Memory: 27.9M
        CPU: 361ms
     CGroup: /system.slice/consul.service
             └─19791 /usr/bin/consul agent -config-dir=/etc/consul.d/
~~~

Otra forma en desarrollo podría ser con el comando siguiente en una pestaña distinta

~~~
consul agent -dev
~~~

Una vez tengamos Consul bien configurado, pasamos a modificar los jobs para el despliegue. En el de redis.hcl únicamente vamos a eliminar la línea de **provider = “nomad”**
Por lo que quedaría:

~~~
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

~~~

Y en el job de guestbook.hcl quitaremos la IP como hemos dicho y añadiremos:

**REDIS_SERVER={{ with service "redis" }}{{ (index . 0).Address }}{{ end }}**

Esta línea lo que hace es consultar en Consul un servicio que se llame "*redis*" y accede a la primera instancia (**index . 0**) para recibir la dirección IP (**.Address**)

Quedaría así el fichero:
~~~
job "guestbook" {
  datacenters = ["dc1"]

  group "guestbook-group" {
    network {
      port "http" {
        to     = 5000
        static = 8087
      }
    }

    task "app" {
      driver = "docker"

      config {
        image = "iesgn/guestbook"
        ports = ["http"]
      }

      # Establecemos la IP del servidor Redis manualmente
      template {
        data = <<EOF
REDIS_SERVER={{ with service "redis" }}{{ (index . 0).Address }}{{ end }}
EOF
        destination = "secrets/env"
        env         = true
      }

      resources {
        cpu    = 200
        memory = 256
      }

      service {
        provider = "nomad"
        name     = "guestbook"
        port     = "http"
      }
    }
  }
}job "guestbook" {
  datacenters = ["dc1"]

  group "guestbook-group" {
    network {
      port "http" {
        to     = 5000
        static = 8087
      }
    }

    task "app" {
      driver = "docker"

      config {
        image = "iesgn/guestbook"
        ports = ["http"]
      }

      # Establecemos la IP del servidor Redis manualmente
      template {
        data = <<EOF
REDIS_SERVER={{ with service "redis" }}{{ (index . 0).Address }}{{ end }}
EOF
        destination = "secrets/env"
        env         = true
      }

      resources {
        cpu    = 200
        memory = 256
      }

      service {
        provider = "nomad"
        name     = "guestbook"
        port     = "http"
      }
    }
  }
}
~~~

Ahora podemos desplegar los dos servicios
~~~
nomad job run redis.hcl 
nomad job run guestbook.hcl 
~~~

Y podemos comprobar que funciona correctamente accediendo al navegador web.

![Consul-guestbook](./img/Consul.png)