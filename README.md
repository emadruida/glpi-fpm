# GLPI Dockerized

[![Docker Image CI](https://github.com/emadruida/glpi-fpm/actions/workflows/main.yml/badge.svg)](https://github.com/emadruida/glpi-fpm/actions/workflows/main.yml)

Docker container that serves GLPI via php-fpm.

A proxy server is needed to redirect traffic to the php-fpm gateway.

## How to use this image

A sample configuration using compose could be the following `docker-compose.yml` file:

```yml
version: '3.9'

services:
  glpi:
    container_name: glpi
    image: emadruida/glpi-fpm
    volumes:
      - ./glpi/files:/var/www/html/glpi/files
      - ./glpi/config:/var/www/html/glpi/config
      - ./glpi/plugins:/var/www/html/glpi/plugins
      - ./glpi/marketplace:/var/www/html/glpi/marketplace
  
  nginx:
    container_name: nginx
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./glpi-nginx.conf:/etc/nginx/conf.d/default.conf
  
  db:
    image: mysql
    container_name: db
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=mysupersecurepassword
      - MYSQL_DATABASE=glpi
    volumes:
      - ./mysql/data:/var/lib/mysql
```

In the same folder as the `docker-compose.yml` file, create the following directories:

- `glpi/files`
- `glpi/config`
- `glpi/plugins`
- `glpi/marketplace`

For the mysql container, create the `mysql/data` directory in the same folder where the
`docker-compose.yml` file is located.

The `glpi-nginx.conf` file is the configuration for the nginx server to serve the glpi site:

```conf
server {
    listen 0.0.0.0:80;

    server_name glpi.localhost;

    root /var/www/html/glpi/public;

    location / {
        try_files $uri /index.php$is_args$args;
    }

    location ~ ^/index\.php$ {
        fastcgi_pass glpi:9000;

        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;

        fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
    }
}
```

Execute docker compose up:

```bash
docker compose up -d
```

In this example we mount as bind volumes the directories used by GLPI both for
configuration and user data.

These directories are thus saved between GLPI installations, allowing us to upgrade
to newer versions of GLPI without loosing our data.
