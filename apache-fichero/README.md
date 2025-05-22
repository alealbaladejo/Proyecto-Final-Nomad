# Despliegue de Apache en Nomad

En este tutorial se explica como desplegar Apache con Nomad Hashicorp en un contenedor Docker, usando Debian 12 como Host y pasando un fichero local al contenedor.

## Requisitos

- Nomad.- [*Instalación Nomad*](https://developer.hashicorp.com/nomad/docs/install)

- Docker.- [*Instalación Docker*](https://docs.docker.com/engine/install/debian/)


## Clonar repositorio

Lo primero que realizamos será la clonación del repositorio donde encontraremos los ficheros necesarios:

~~~
git clone https://github.com/alealbaladejo/Proyecto-Final-Nomad.git
~~~

~~~
cd Proyecto-Final-Nomad/apache-fichero
~~~

## Job
El fichero que vamos a montar como index.html es el siguiente:

~~~
cat web/index.html

<h1>Proyecto Nomad Hashicorp<h1>
<h4>Alejandro</h4>
~~~

En Nomad, para especificar un volumen en un job, antes tendremos que configurar el fichero de configuración, añadiendo el volumen en el cliente:
 
 ~~~
cat /etc/nomad.d/nomad.hcl 
…
client {
  enabled = true
  servers = ["127.0.0.1"]

  host_volume "webapache" {
    path = "/home/ale/Proyecto-Final-Nomad/apache-fichero/web"
    read_only = false
  }
}
~~~

En este caso habrá que añadir la **ruta absoluta** dónde se encuentra el fichero **index.html** que vamos a utilizar en este caso.
Ahora reiniciamos el servicio:

~~~
sudo systemctl restart nomad.service
~~~

Y ahora nos fijamos en el job creado:
~~~
cat apache.hcl 
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
~~~

Lo nuevo añadido aquí sería:

**volume “webapache”:** Especifica el nombre que va a tener este volumen.

**type = “host”:** Indica que va a ser una ruta en el sistema de archivo del host.

**read_only = "false":** El contenedor tendrá permiso de escritura y lectura sobre el volumen.

**source = "webapache":** Debe coincidir con el nombre que hemos registrado en el cliente en /etc/nomad.d/nomad.hcl.

Y por otra parte:

**volume_mount:** Esta parte decide dónde se va a montar el volumen dentro del contenedor.

**volume = “webapache”:** Especifica el nombre del volumen (declarado arriba) que se va a montar en esta tarea.

**destination = “/usr/local/apache2/htdocs”:** Indica la ruta dentro del contenedor donde se va a montar el volumen.

**read_only = false:** El contenedor podrá modificar los archivos en esa ruta.


Una vez que tengamos esto claro y bien configurado, podemos pasar a lanzar el job a Nomad:
~~~
nomad job run apache.hcl 
…
  ✓ Deployment "81ae82e1" successful
    
    2025-05-19T17:30:43+02:00
    ID          = 81ae82e1
    Job ID      = apache
    Job Version = 6
    Status      = successful
    Description = Deployment completed successfully
    
    Deployed
    Task Group  Desired  Placed  Healthy  Unhealthy  Progress Deadline
    apache      1        1       1        0          2025-05-19T17:32:49+02:00
~~~

Y podemos comprobar que se ha configurado correctamente si accedemos a la url:
~~~
curl 192.168.122.66:8085

<h1>Proyecto Nomad Hashicorp<h1>
<h4>Alejandro</h4>
~~~

Si ahora añadimos una línea a este fichero desde el host, veremos como automáticamente cambia en el contenedor:
~~~
echo "<h5>Línea añadida</h5>" >> web/index.html 
curl 192.168.122.66:8085

<h1>Proyecto Nomad Hashicorp<h1>
<h4>Alejandro</h4>
<h5>Línea añadida</h5>
~~~

Con esto tendremos un servidor web apache desplegado con una página html desplegada desde el propio host a la máquina virtual.