## Начало работы с Docker. Часть третья
#### Заимствовано:         https://tokmakov.msk.ru/blog/item/487    18.03.2020


### Что такое Docker Volumes

Том — это файловая система, которая расположена на хост-машине за пределами контейнеров. Тома представляют собой средства для постоянного хранения информации и могут совместно использоваться разными контейнерами. Созданием и управлением томами занимается Docker.

Попробуем просто создать несколько томов:
```
$ docker volume create --name data-www
$ docker volume create --name data-sql
$ docker volume create --name data-tmp  
```

Для того, чтобы просмотреть список томов:
```
$ docker volume ls
DRIVER              VOLUME NAME
local               data-sql
local               data-tmp
local               data-www  
```

Посмотреть информацию об отдельном томе:
```
$ docker volume inspect data-www
[
    {
        "CreatedAt": "2020-03-20T14:44:01+03:00",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/data-www/_data",
        "Name": "data-www",
        "Options": {},
        "Scope": "local"
    }
]
```
  
Если том больше не нужен, его можно удалить:
```
$ docker volume rm data-tmp  
```

Чтобы удалить все тома, которые не используются контейнерами:
```
$ docker volume prune  
```

Теперь смонтируем том data-www при запуске контейнера:
```
$ docker run -it -v data-www:/var/www ubuntu:latest
# mkdir /var/www/html
# touch /var/www/html/index.php
# exit
```
  
Если вспомнить, что данные тома находятся в /var/lib/docker/volumes/data-www/_data, то теперь в этой директории есть поддиректория html, а внутри поддиректории — файл index.php.


### Инструкция VOLUME в Dockerfile

Эта инструкция устарела и использовать ее не рекомендуется. Но давайте все таки познакомимся с ней поближе для общего понимания. Создадим в домашней директории каталог test и внутри него — файл Dockerfile:
```
$ cd ~
$ mkdir test
$ cd test
$ nano Dockerfile  
```
```
FROM ubuntu:latest
VOLUME /etc  
```

Соберем образ из этого Dockerfile:
```
$ docker build . --tag ubuntu-share-etc  
```

Запустим новый контейнер:
```
$ docker run -it --name share-etc ubuntu-share-etc  
```

Теперь посмотрим, какие тома существуют:
```
$ docker volume ls
DRIVER              VOLUME NAME
local               8bda345c875c99d61f9646a9b0922934a7eaab83366c04159f6023654237f090
local               data-sql
local               data-www  
```

Где физически расположены тома, мы уже знаем. Так что посмотрим содержимое нового тома:
```
$ cd ~
$ sudo ls /var/lib/docker/volumes/8bda345c875c99d61f9646a9b0922934a7eaab83366c04159f6023654237f090/_data/
adduser.conf            debconf.conf    fstab         hosts        ld.so.conf     lsb-release    opt         profile.d  rc5.d        security  subuid
alternatives            debian_version  gai.conf      init.d       ld.so.conf.d   machine-id     os-release  rc0.d      rc6.d        selinux   sysctl.conf
apt                     default         group         issue        legal          mke2fs.conf    pam.conf    rc1.d      rcS.d        shadow    sysctl.d
bash.bashrc             deluser.conf    gshadow       issue.net    libaudit.conf  mtab           pam.d       rc2.d      resolv.conf  shells    systemd
bindresvport.blacklist  dpkg            host.conf     kernel       login.defs     networks       passwd      rc3.d      rmt          skel      terminfo
cron.daily              environment     hostname      ld.so.cache  logrotate.d    nsswitch.conf  profile     rc4.d      securetty    subgid    update-motd.d  
```

Это содержимое каталога /etc контейнера. Так что мы можем, используя инструкцию VOLUME, сохранять на основной системе любые директории контейнера. И при удалении контейнера тома будут по-прежнему существовать. Впрочем, можно вместе с удалением контейнера удалить и связанный с ним том:
```
$ docker container rm -v share-etc  
```

Был удален контейнер share-etc и связанный с ним том 8bda345c875c99d61f9646a9b0922934a7eaab83366c04159f6023654237f090.


### Порты контейнера

Docker позволяет получить доступ к какому-то из портов контейнера, пробросив его наружу — в основную операционную систему. По умолчанию, мы не можем достучаться к какому-либо порту контейнера. Однако, интсрукция EXPOSE в Dockerfile позволяет объявить, к какому из портов можно обратиться из основной системы.

Создадим в домашней директории каталог www и внутри него — файлы Dockerfile и index.php:
```
$ cd ~
$ mkdir www
$ cd www  
```
```
$ nano Dockerfile  
```
```
#Образ с DockerHub, включает Apache и PHP
FROM php:7.2-apache
#Копируем все файлы проекта в контейнер
COPY . /var/www/html
#Сообщаем, какие порты контейнера слушать
EXPOSE 80  
```
```
$ nano index.php  
<h1>Hello from Apache</h1>
<?php phpinfo(); ?>  
```

Создадим новый образ из Dockerfile:
```
$ docker build . --tag apache-php72  
```

Запустим контейнер и укажем, что порт 80 контейнера будет связан с портом 8080 хоста:
```
$ docker run -p 8080:80 apache-php72
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.17.0.4. Set the 'ServerName' directive globally to suppress this message
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.17.0.4. Set the 'ServerName' directive globally to suppress this message
[Sat Mar 21 10:19:35.224973 2020] [mpm_prefork:notice] [pid 1] AH00163: Apache/2.4.38 (Debian) PHP/7.2.29 configured -- resuming normal operations
[Sat Mar 21 10:19:35.233317 2020] [core:notice] [pid 1] AH00094: Command line: 'apache2 -D FOREGROUND'  
```

Запускаем браузер и открываем http://localhost:8080:



### Установка Docker Compose

Docker применяется для управления отдельными контейнерами (сервисами), из которых состоит приложение. Docker Compose используется для одновременного управления несколькими контейнерами, входящими в состав приложения. Этот инструмент предлагает те же возможности, что и Docker, но позволяет работать с более сложными приложениями.
```
#--- Более новая версия 
$ sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose  
```
```
$ docker-compose --version
docker-compose version 1.25.4, build 8d51620a  
```


### Файл docker-compose.yml

Набор сервисов, которые нужны для работы приложения, определяется с помощью файла docker-compose.yml. У нас уже есть директория www — создадим в ней еще один файл:
```
$ nano docker-compose.yml  
```
```
version: '3'
services:
  app:
    build:
      context: .
    ports:
      - 8080:80  
```

Теперь построчно разберёмся с параметрами:

* version — какая версия docker-compose.yml используется
* services — контейнеры, которые нужно запустить
* app — имя сервиса, может быть любым, но осмысленным
* build — шаги, описывающие процесс билдинга
* context — где находится Dockerfile для контейнера
* ports — соответствие портов хоста и контейнера

Теперь проект надо собрать — это похоже на сборку образа в Docker, но здесь идет сборка нескольких образов. Хотя в нашем случае образ всего один:
```
$ docker-compose build  
```

Проверим, что был создан новый образ:
```
$ docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
--------------------------------------------------------------------------------------------
www_app                   latest              ce3c26a2cb52        17 seconds ago      410MB
apache-php72              latest              eb9a7fb87880        22 hours ago        410MB
ubuntu-share-etc          latest              ebc1eef0eca3        42 hours ago        64.2MB
php                       7.2-apache          4e96f7d06518        2 days ago          410MB
php-cli-script            latest              9fff2bf618ad        2 days ago          398MB
tokmakov/apache2_ubuntu   latest              18073a80c28b        3 days ago          191MB
php                       7.2-cli             555ec78042a1        3 weeks ago         398MB
ubuntu                    latest              72300a873c2c        4 weeks ago         64.2MB
hello-world               latest              fce289e99eb9        14 months ago       1.84kB  
```

Теперь запустим эти сервисы, которые создали (хотя у нас всего один сервис):
```
$ docker-compose up
Creating network "www_default" with the default driver
Creating www_app_1 ... done
Attaching to www_app_1
app_1  | AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.18.0.2. Set the 'ServerName' directive globally to suppress this message
app_1  | AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.18.0.2. Set the 'ServerName' directive globally to suppress this message
app_1  | [Sun Mar 22 08:31:46.482140 2020] [mpm_prefork:notice] [pid 1] AH00163: Apache/2.4.38 (Debian) PHP/7.2.29 configured -- resuming normal operations
app_1  | [Sun Mar 22 08:31:46.486761 2020] [core:notice] [pid 1] AH00094: Command line: 'apache2 -D FOREGROUND'  
```

Запускаем браузер и открываем http://localhost:8080:



Остановим работу контейнера с помощью Ctrl+C и посмотрим на список контейнеров:
```
$ docker container ls -a
CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS                      PORTS   NAMES
--------------------------------------------------------------------------------------------------------------------------------
d06fb87577e6   www_app          "docker-php-entrypoi…"   13 minutes ago   Exited (0) 27 seconds ago           www_app_1
a6e37dee6924   apache-php72     "docker-php-entrypoi…"   2 hours ago      Exited (0) 2  hours ago             beautiful_turing
................................................................................................................................
8aa1a9458932   php-cli-script   "php /script.php 8"      2 days ago       Exited (0) 2 days ago               optimistic_maxwell
37def446ae84   ubuntu           "/bin/bash"              4 days ago       Exited (0) 2 days ago               apache2_ubuntu  
```

```
Начало работы с Docker. Часть четвертая
Начало работы с Docker. Часть вторая
Начало работы с Docker. Часть первая
Начало работы с Docker. Часть пятая
Начало работы с Docker. Часть шестая
Создание SSH-туннеля. Часть 3 из 4
Установка DHCP-сервера на Ubuntu Server 18.04 LTS
```
