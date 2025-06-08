# PROYECTO FINAL NOMAD

## Alejandro Albaladejo Gago

Este repositorio contiene ejemplos prácticos de despliegues en Nomad, para el proyecto Final del Grado Superior de ASIR, cursado en **IES Gonzalo Nazareno**, *Dos Hermanas, Sevilla*

A continuación proporciono los enlaces directos a las carpetas de cada despliegue:

- [despliegue-nginx](./despliegue-nginx)
: Despliegue básico de un servidor **Nginx** como servicio en Nomad.

- [apache2](./apache-fichero)
: Despliegue de **Apache** sirviendo un archivo HTML local a través de un volumen montado desde el host.

- [mariadb-variables](./mariadb-variables)
: Despliegue de **MariaDB** con paso de variables de entorno sensibles y configuración personalizada.

- [guestbook-redis-1](./guestbook-redis-vol-persistente)
: Despliegue de la aplicación **guestbook** usando una base de datos **redis**

- [guestbook-redis-2](./guestbook-redis-jobs-separados/)
: Despliegue de la aplicación **guestbook** usando una base de datos **redis** en dos ficheros distintos, usando Consul.

## Requisitos para poder realizar este tutorial
- Nomad
- Docker
- Consul
- Prometheus
- Nomad-autoscaler
