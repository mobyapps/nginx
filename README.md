# Dockerfile for nginx

Usage
-------------
docker-compose.yml

```
version: "3"

services:
  nginx:
    image: frontbear/fastnginx:1.15.3.0
    volumes:
      - vhosts:/usr/local/nginx/vhosts
    ports:
      - "80:80"
      - "443:443"
    networks:
      - nginx
    depends_on:
      - php
    logging:
      driver: "json-file"
      options:
        max-size: "500k"
        max-file: "20"

networks:
  nginx:
    driver: bridge

volumes:
  vhosts:
    driver: local
```
