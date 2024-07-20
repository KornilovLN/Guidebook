## Начало работы с Docker. Часть шестая
#### Заимствовано:         https://tokmakov.msk.ru/blog/item/490    18.03.2020


У нас сейчас запущены два контейнера на основе образа ubuntu:latest:
```
$ docker ps
CONTAINER ID    IMAGE            COMMAND        CREATED        STATUS        PORTS    NAMES
85417e60b40d    ubuntu:latest    "/bin/bash"    2 hours ago    Up 2 hours             laughing_clarke
157ffc6166fc    ubuntu:latest    "/bin/bash"    2 hours ago    Up 2 hours             eloquent_goodall  
```

Выполним команду ping google.com изнутри первого контейнера. А снаружи будем отслеживать ping с помощью утилиты tcpdump на виртуальном интерфейсе veth59134c1:
```
$ sudo tcpdump -i veth59134c1 icmp # на основной системе
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on veth59134c1, link-type EN10MB (Ethernet), capture size 262144 bytes
15:12:49.026100 IP 172.17.0.2 > lq-in-f138.1e100.net: ICMP echo request, id 372, seq 1, length 64
15:12:49.067953 IP lq-in-f138.1e100.net > 172.17.0.2: ICMP echo reply, id 372, seq 1, length 64
15:12:50.027507 IP 172.17.0.2 > lq-in-f138.1e100.net: ICMP echo request, id 372, seq 2, length 64
15:12:50.055363 IP lq-in-f138.1e100.net > 172.17.0.2: ICMP echo reply, id 372, seq 2, length 64
15:12:51.028917 IP 172.17.0.2 > lq-in-f138.1e100.net: ICMP echo request, id 372, seq 3, length 64
15:12:51.055577 IP lq-in-f138.1e100.net > 172.17.0.2: ICMP echo reply, id 372, seq 3, length 64  
```
```
# apt install -y iputils-ping
# ping -c 3 google.com # внутри контейнера
PING google.com (173.194.73.138) 56(84) bytes of data.
64 bytes from lq-in-f138.1e100.net (173.194.73.138): icmp_seq=1 ttl=42 time=42.0 ms
64 bytes from lq-in-f138.1e100.net (173.194.73.138): icmp_seq=2 ttl=42 time=27.9 ms
64 bytes from lq-in-f138.1e100.net (173.194.73.138): icmp_seq=3 ttl=42 time=26.7 ms
--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 26.738/32.239/42.028/6.942 ms  
```

Аналогично можно выполнить пинг от одного контейнера к другому. Сначала посмотрим, какие ip-адреса у контейнеров в сети bridge
```
$ docker network inspect bridge  
[
    {
        "Name": "bridge",
        "Id": "4db4885e345cbad5662da7cc0fe753e2f323a84fd2ba01947067cb1cca2b70c5",
        "Created": "2020-03-30T08:56:17.5621013+03:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "157ffc6166fc55506cd971c9b731e7a32cf17935a8176dc9ad0ea8c0d17f1f22": {
                "Name": "eloquent_goodall",
                "EndpointID": "6c9f7d4675cec8bf982716bc4a524426462dafbfbbe5ca186174b5d48b4ab339",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            },
            "85417e60b40d2dc2b1a92ba0ca4f1ffc00c7911b8bea2884b4be3db426b281e5": {
                "Name": "laughing_clarke",
                "EndpointID": "2006fd9dd9627863312261215e909887be461b54d54f1dfad1b786473d5db035",
                "MacAddress": "02:42:ac:11:00:03",
                "IPv4Address": "172.17.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]  
```

Запускаем tcpdump на хосте
```
$ sudo tcpdump -ni docker0 host 172.17.0.2 and host 172.17.0.3
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on docker0, link-type EN10MB (Ethernet), capture size 262144 bytes
15:30:52.638834 IP 172.17.0.2 > 172.17.0.3: ICMP echo request, id 374, seq 1, length 64
15:30:52.638925 IP 172.17.0.3 > 172.17.0.2: ICMP echo reply, id 374, seq 1, length 64
15:30:53.643881 IP 172.17.0.2 > 172.17.0.3: ICMP echo request, id 374, seq 2, length 64
15:30:53.643935 IP 172.17.0.3 > 172.17.0.2: ICMP echo reply, id 374, seq 2, length 64
15:30:54.668023 IP 172.17.0.2 > 172.17.0.3: ICMP echo request, id 374, seq 3, length 64
15:30:54.668095 IP 172.17.0.3 > 172.17.0.2: ICMP echo reply, id 374, seq 3, length 64  
```

И запускаем ping с первого контейнера на второй
```
# ping -c 3 172.17.0.3
PING 172.17.0.3 (172.17.0.3) 56(84) bytes of data.
64 bytes from 172.17.0.3: icmp_seq=1 ttl=64 time=0.180 ms
64 bytes from 172.17.0.3: icmp_seq=2 ttl=64 time=0.270 ms
64 bytes from 172.17.0.3: icmp_seq=3 ttl=64 time=0.191 ms

--- 172.17.0.3 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2031ms
rtt min/avg/max/mdev = 0.180/0.213/0.270/0.043 ms  
```

### Сеть при использовании docker-compose

Давайте запустим три контейнера, которые описаны в docker-compose.yml:
```
$ cd ~/www/
$ cat docker-compose.yml  
version: '3'
services:
  apache:
    build: # инструкции для создания образа
      # контекст (путь к каталогу, содержащему Dockerfile)
      context: ./apache/
      # это необязательно, потому что контекст уже задан
      dockerfile: Dockerfile
    ports:
      # контейнер будет доступен на порту 80 основной системы
      - 80:80
    volumes: # путь указывается от директории, где расположен docker-compose.yml
      # монтируем директорию с php-скриптом внутрь контейнера
      - ./apache/html/:/var/www/html/
      # монтируем файл конфигурации php.ini внутрь контейнера
      - ./apache/php.ini:/usr/local/etc/php/php.ini
      # монтируем файл конфигурации Apache2 внутрь контейнера
      - ./apache/httpd.conf:/etc/apache2/apache2.conf
      # монтируем файл логов доступа Apache2 внутрь контейнера
      - ./apache/logs/access.log:/var/log/apache2/access.log
      # монтируем файл логов ошибок Apache2 внутрь контейнера
      - ./apache/logs/error.log:/var/log/apache2/error.log
  mysql:
    build: # инструкции для создания образа
      # контекст (путь к каталогу, содержащему Dockerfile)
      context: ./mysql/
      # это необязательно, потому что контекст уже задан
      dockerfile: Dockerfile
    environment:
      # пароль пользователя root
      MYSQL_ROOT_PASSWORD: qwerty
    ports:
      - 3306:3306
    volumes: # путь указывается от директории, где расположен docker-compose.yml
      # монтируем файл конфигурации MySQL внутрь контейнера
      - ./mysql/mysql.cnf:/etc/mysql/my.cnf
      # монтируем директорию с базами данных внутрь контейнера
      - ./mysql/data/:/var/lib/mysql/
      # монтируем директорию с логами MySQL внутрь контейнера
      - ./mysql/logs/:/var/log/mysql/
  pma:
    # используем готовый образ phpmyadmin
    image: phpmyadmin/phpmyadmin
    ports:
      - 8080:80
    environment:
      # название хоста в сети www_default
      PMA_HOST: mysql
      MYSQL_USERNAME: root
      MYSQL_ROOT_PASSWORD: qwerty 
```
``` 
$ docker-compose up -d
Creating network "www_default" with the default driver
Creating www_pma_1    ... done
Creating www_apache_1 ... done
Creating www_mysql_1  ... done  
```
```
$ docker ps
CONTAINER ID  IMAGE                  COMMAND                 CREATED             STATUS             PORTS                              NAMES
7bed4b88ceac  www_mysql              "docker-entrypoint.s…"  About a minute ago  Up About a minute  0.0.0.0:3306->3306/tcp, 33060/tcp  www_mysql_1
a9ab191d3f89  phpmyadmin/phpmyadmin  "/docker-entrypoint.…"  About a minute ago  Up About a minute  0.0.0.0:8080->80/tcp               www_pma_1
f736a3a70e05  www_apache             "docker-php-entrypoi…"  About a minute ago  Up About a minute  0.0.0.0:80->80/tcp                 www_apache_1  
```
```
$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
4db4885e345c        bridge              bridge              local
1a425e4362b4        host                host                local
9246f826508b        none                null                local
c3379a4dea9e        www_default         bridge              local  
```

Проверим сеть, через которую взаимодействуют контейнеры:
```
$ docker network inspect www_default  
[
    {
        "Name": "www_default",
        "Id": "c3379a4dea9e54238418f256c408598eeaa47ead9333213a51ac32dff917e565",
        "Created": "2020-03-30T15:36:57.477223789+03:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.22.0.0/16",
                    "Gateway": "172.22.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": true,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "7bed4b88ceacc4ea8b0beba043648a0c647dbe3e663278bc8364e0e213062fc5": {
                "Name": "www_mysql_1",
                "EndpointID": "fdda9874a47774392148ab1b2bf3d1a6d34d6f8001167c918d2cefc608de3534",
                "MacAddress": "02:42:ac:16:00:03",
                "IPv4Address": "172.22.0.3/16",
                "IPv6Address": ""
            },
            "a9ab191d3f89f1f333966f18202e00df5826a0d2ed7ffe1752348b7b54dfa4a7": {
                "Name": "www_pma_1",
                "EndpointID": "1a82eea63694b0d63481eda742ff584804b9715b0c4a9992a1ccbae584590dba",
                "MacAddress": "02:42:ac:16:00:04",
                "IPv4Address": "172.22.0.4/16",
                "IPv6Address": ""
            },
            "f736a3a70e050fbdef9bd0a85d30e786acf2cf0e36f7378b084135c91e5243f3": {
                "Name": "www_apache_1",
                "EndpointID": "258c5e73a366db9afc69d10394746cea286b1838eebb1749a17c0eb024f9fda8",
                "MacAddress": "02:42:ac:16:00:02",
                "IPv4Address": "172.22.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {
            "com.docker.compose.network": "default",
            "com.docker.compose.project": "www",
            "com.docker.compose.version": "1.25.4"
        }
    }
]
```  

Здесь мы видим ip-адреса контейнеров: 172.22.0.2/16, 172.22.0.3/16 и 172.22.0.4/16. Но внутри сети контейнер доступен не только по ip-адресу, но и по имени службы. Давайте заглянем внутрь контейнера www_apache_1 (служба apache из YAML-файла):
```
$ docker-compose exec apache /bin/bash
# apt update
# apt install -y iputils-ping
# ping -c 3 mysql # имя службы из YAML-файла
PING mysql (172.22.0.3) 56(84) bytes of data.
64 bytes from www_mysql_1.www_default (172.22.0.3): icmp_seq=1 ttl=64 time=0.200 ms
64 bytes from www_mysql_1.www_default (172.22.0.3): icmp_seq=2 ttl=64 time=0.202 ms
64 bytes from www_mysql_1.www_default (172.22.0.3): icmp_seq=3 ttl=64 time=0.215 ms

--- mysql ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 10ms
rtt min/avg/max/mdev = 0.200/0.205/0.215/0.017 ms
# exit  
```

Просмотр логов в Docker
Для начала посмотрим, какие контейнеры запущены в работу:
```
$ docker ps
CONTAINER ID  IMAGE                  COMMAND                 CREATED              STATUS             PORTS                              NAMES
756794a08941  phpmyadmin/phpmyadmin  "/docker-entrypoint.…"  About a minute ago   Up About a minute  0.0.0.0:8080->80/tcp               www_pma_1
d4e1f0ab03c4  www_mysql              "docker-entrypoint.s…"  About a minute ago   Up About a minute  0.0.0.0:3306->3306/tcp, 33060/tcp  www_mysql_1
cff6fc8e9f03  www_apache             "docker-php-entrypoi…"  About a minute ago   Up About a minute  0.0.0.0:80->80/tcp                 www_apache_1  
```

Посмотрим логи Apache:
```
$ docker logs www_apache_1
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.23.0.3. Set the 'ServerName' directive globally to...
[Tue Mar 31 12:01:51.924142 2020] [mpm_prefork:notice] [pid 1] AH00163: Apache/2.4.38 (Debian) PHP/7.4.4 configured -- resuming normal operations
[Tue Mar 31 12:01:51.924294 2020] [core:notice] [pid 1] AH00094: Command line: 'apache2 -D FOREGROUND'  
```

Посмотрим логи MySQL:
```
$ $ docker logs www_mysql_1
2020-03-31 12:01:52+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.19-1debian10 started.
2020-03-31 12:01:52+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
2020-03-31 12:01:52+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.19-1debian10 started.  
```

Эта команда работает только для контейнеров, запускаемых с драйвером ведения журнала json-file или journald.
Логи монтируются на хост, поэтому легко понять, где они лежат:
```
$ docker inspect www_apache_1 | grep LogPath
"LogPath": "/var/lib/docker/containers/cff...253/cff...253-json.log",  
$ sudo cat /var/lib/docker/containers/cff...253/cff...253-json.log
{"log":"AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.23.0.3. Set the 'ServerName' directive globally to suppress this message\n","stream":"stderr","time":"2020-03-31T12:01:51.900770702Z"}
{"log":"[Tue Mar 31 12:01:51.924142 2020] [mpm_prefork:notice] [pid 1] AH00163: Apache/2.4.38 (Debian) PHP/7.4.4 configured -- resuming normal operations\n","stream":"stderr","time":"2020-03-31T12:01:51.927844571Z"}
{"log":"[Tue Mar 31 12:01:51.924294 2020] [core:notice] [pid 1] AH00094: Command line: 'apache2 -D FOREGROUND'\n","stream":"stderr","time":"2020-03-31T12:01:51.927901498Z"}
{"log":"192.168.110.18 - - [31/Mar/2020:12:02:54 +0000] \"GET / HTTP/1.1\" 200 390 \"-\" \"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:74.0) Gecko/20100101 Firefox/74.0\"\n","stream":"stdout","time":"2020-03-31T12:02:54.454904936Z"}  
```

Логи можно просматривать в режиме реального времени:
```
$ docker logs www_pma_1 --follow  
```

Docker включает несколько механизмов ведения журналов, которые называются драйверами регистрации. По умолчанию используется драйвер json-file, но можно использовать journald, syslog и другие. Изменить драйвер можно глобально, через файл /etc/docker/daemon.json:
```
$ sudo nano /etc/docker/daemon.json  
{
    "log-driver": "journald"
}  
```
```
$ sudo systemctl restart docker.service  
```

Либо при запуске контейнера:
```
$ docker run -d -p 80:80 --name apache-server --log-driver=journald httpd:latest  
```

Либо в файле docker-compose.yml:
```
apache:
  image: httpd:latest
  logging:
    driver: journald
    options:
      tag: http-daemon  
```

При использовании драйвера journald логи можно смотреть так:
```
$ journalctl -u docker.service CONTAINER_NAME=apache-server
-- Logs begin at Sat 2020-02-29 16:06:12 MSK, end at Tue 2020-03-31 16:09:53 MSK. --
мар 31 16:26:37 test-server 2f5f00f1e480[14225]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the 'Serv
мар 31 16:26:37 test-server 2f5f00f1e480[14225]: [Tue Mar 31 13:26:37.904324 2020] [mpm_event:notice] [pid 1:tid 139724697171072] AH00489: Apache/2.4.43 (Unix) configu
мар 31 16:26:37 test-server 2f5f00f1e480[14225]: [Tue Mar 31 13:26:37.904729 2020] [core:notice] [pid 1:tid 139724697171072] AH00094: Command line: 'httpd -D FOREGROUN
$ journalctl -u docker CONTAINER_TAG=http-daemon
-- Logs begin at Sat 2020-02-29 16:06:12 MSK, end at Tue 2020-03-31 16:17:05 MSK. --
мар 31 16:16:55 test-server http-daemon[14225]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the 'Serve
мар 31 16:16:55 test-server http-daemon[14225]: [Tue Mar 31 13:16:55.540692 2020] [mpm_event:notice] [pid 1:tid 140145144452224] AH00489: Apache/2.4.43 (Unix) configur
мар 31 16:16:55 test-server http-daemon[14225]: [Tue Mar 31 13:16:55.541064 2020] [core:notice] [pid 1:tid 140145144452224] AH00094: Command line: 'httpd -D FOREGROUND  
```

Для фильтрации логов по тегу, надо задать тег в файле docker-compose.yml или при запуске контейнера:
```
$ docker run -d -p 80:80 --name apache-server --log-opt tag=http-daemon httpd:latest  
```

```
Начало работы с Docker. Часть пятая
Начало работы с Docker. Часть четвертая
Начало работы с Docker. Часть третья
Начало работы с Docker. Часть вторая
Начало работы с Docker. Часть первая
Создание SSH-туннеля. Часть 2 из 4
Linux. Команда top
```
