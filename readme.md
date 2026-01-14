
### Развёртыванеи проекта на новом сервере (VPS/VDS Ubuntu)

Обновляем и устанавливаем пакеты:
```shell
# apt update && apt upgrade
# apt install -y mc git python3-virtualenv python3-pip jq
```
Создаём пользователя и выполняем подготовительные действия, скачиваем проект из github.com:

```shell
# adduser vtext
# mkdir /opt/vtext
# chown vtext /opt/vtext
# su -l vtext
$ cd /opt/vtext
$ git clone https://github.com/gtlhbkkj/vtext.git .
$ mkdir -p logs
$ make install
```

Проверяем запуск веб-приложения в теством режиме, чтобы увидеть возможные ошибки:
```shell
$ make run
```
Прерываем выполение: Ctrl + C


Дальнейшие действия выполняем под root.

Делаем настройки для nginx:

Создаём файл /etc/nginx/sites-available/testsrv24.de.conf:
```
map $uri $redirect_https {
    "~^/.well-known/acme-challenge/"   0;
    default                            1;
}

server {
    listen 0.0.0.0:80;
    charset  utf-8;
    server_name testsrv24.de;

    location /.well-known/acme-challenge {
        default_type "text/plain";
        alias /var/lib/letsencrypt/webroot/.well-known/acme-challenge;
    }

    if ($redirect_https = 1) {
        return 301 https://$host$request_uri;
    }
}
```

Создаём synlink для аквтивации конф-файла в nginx:
```shell
# ln -sf /etc/nginx/sites-available/testsrv24.de.conf /etc/nginx/sites-enabled/testsrv24.de.conf
```

Создаём служебную директорию для работы скрипта certbot:
```shell
# mkdir -p /var/lib/letsencrypt/webroot
````

Пробуем получить SSKL-сертификат:
```shell
# certbot certonly -d testsrv24.de --webroot --webroot-path /var/lib/letsencrypt/webroot
```
Если нет ошибок и проблем - продолжаем.
Если есть - разбираемся и пробуем исправить.

Дописываем ф файл
/etc/nginx/sites-available/testsrv24.de.conf:
```
map $uri $redirect_https {
    "~^/.well-known/acme-challenge/"   0;
    default                            1;
}

server {
    listen 0.0.0.0:80;
    charset  utf-8;
    server_name testsrv24.de;

    location /.well-known/acme-challenge {
        default_type "text/plain";
        alias /var/lib/letsencrypt/webroot/.well-known/acme-challenge;
    }

    if ($redirect_https = 1) {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 0.0.0.0:443 ssl;
    charset  utf-8;
    server_name testsrv24.de;

    ssl_certificate /etc/letsencrypt/live/testsrv24.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/testsrv24.de/privkey.pem;

    ssl_session_timeout 5m;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "HIGH:!aNULL:!MD5 or HIGH:!aNULL:!MD5:!3DES";
    ssl_prefer_server_ciphers on;

    location  / {
        proxy_pass  http://127.0.0.1:18080;
        proxy_set_header Host  $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        access_log off;
    }
}
```

Для запувска веб-сервера приложения воспользуемся механизмом systemd.

Создаём (под root) файл
/etc/systemd/system/vtext.service:
````
[Unit]
Description=vtext service
After=network.target

[Service]
User=vtext
Group=vtext
WorkingDirectory=/opt/vtext
ExecStart=/opt/vtext/.venv/bin/gunicorn -w 4 -k uvicorn.workers.UvicornWorker app.main:app --bind 0.0.0.0:18080 --error-logfile=/tmp/vtext-error.log
Restart=always

[Install]
WantedBy=multi-user.target
```

Применяем настройку:
```shell
# systemctl daemon-reload
# systemctl eneble vtext
# systemctl start vtext
```

Проверяем наличие/отсутствие ошибок:
```shell
# systemctl status vtext
```
